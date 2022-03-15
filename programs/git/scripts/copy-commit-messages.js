/*
 * Get, format and copy commit messages
 *
 * This script can be run as a bookmarklet within the browser (from a VSTS pull request)
 * or directly from the commandline on a particular branch.
 *
 * `node programs/git/scripts/copy-commit-messages.js test`
 */

const {argv0} = require("process");

const IN_NODE = typeof window === "undefined";
const TRUNK = IN_NODE && process.argv.slice(2).pop();
const TESTING = IN_NODE && process.argv.slice(2).pop() === "test";

//
// Commits from command line
//

const getCommitsFromCommandline = () => {
  const {spawn} = require("child_process");

  return new Promise((resolve, reject) => {
    let data = "";
    const divider = "<DIVIDER>";
    const git = spawn("git", [
      "log",
      `${TRUNK}..`,
      `--format=format:${divider}%B`
    ]);
    git.stderr.on("data", reject);
    git.stdout.on("data", chunk => {
      data += chunk;
    });
    git.on("close", () => {
      resolve(data.split(divider).filter(commit => commit !== ""));
    });
  });
};

//
// Commits from VSTS
//

const getCommitsApiUrl = () =>
  new Promise((resolve, reject) => {
    const url = window.location.href;

    if (url.indexOf("pullrequest") === -1) {
      return reject(new Error("This is not a pull request url"));
    }

    resolve(
      url
        .replace("/_git/", "/_apis/git/repositories/")
        .replace("pullrequest", "pullRequests")
        .replace(/\/?\?.*/, "/commits?api-version=5.0")
    );
  });

const getSingleCommitApiUrl = commitId =>
  getCommitsApiUrl().then(url =>
    url.replace(/pullRequest.*/, `commits/${commitId}?api-version=5.0`)
  );

const hydrateCommit = commit =>
  getSingleCommitApiUrl(commit.commitId)
    .then(fetch)
    .then(response => response.json())
    .then(json => json.comment);

const getCommitsFromVSTS = () =>
  getCommitsApiUrl()
    .then(fetch)
    .then(response => response.json())
    .then(result => Promise.all(result.value.map(hydrateCommit)));

//
// Copy to clipboard
//

const copyToClipBoardFromCommandline = message => {
  const pbcopy = require("child_process").spawn("pbcopy");
  pbcopy.stdin.write(message);
  pbcopy.stdin.end();
  console.log("Copied commit messages to clipboard");
  process.exit(1);
};

const copyToClipboardFromBrowser = message => {
  const el = document.createElement("textarea");
  el.value = message;
  el.setAttribute("readonly", "");
  el.style = {position: "absolute", left: "-9999px"};
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
  console.log(message);
  alert("Copied commit messages to clipboard");
};

//
// Format commit messages
//

const bulletPoint = "\n- ";
const spacedBulletPoint = `\n${bulletPoint}`;

const bulletPointsToLines = comments =>
  comments.split("\n").reduce(
    (acc, line) =>
      /^-/.test(line)
        ? acc.concat(line.replace(/^-\s*/, "")) // Append to lines
        : (acc[acc.length - 1] += ` ${line}`) && acc, // Update previous line
    []
  );

const paragraphsToLines = comments =>
  comments
    .split("\n\n") // Break into paragraphs
    .map(line => line.replace(/\n/g, " ")); // Make each paragraph a single line

const formatHighlights = input =>
  input
    // PascalCase
    .replace(/(\s)([A-Z]([A-Z][a-z]+|[a-z]+[A-Z])[^\s]+)(\s)/g, "$1`$2`$4")
    // camelCase
    .replace(/(\s)([a-z]+[A-Z]([A-Z]+|[a-z]+)[^\s]+)(\s)/g, "$1`$2`$4");

const formatCommitWith = (spacing = "  ", joiner = "\n\n") => input => formatCommit(input, joiner, spacing)

const formatCommit = (input, joiner = "\n\n", spacing = "  ") => {
  const message = formatHighlights(input);

  const lines = message
    .trim()
    .split("\n")
    .map(line => line.trim());

  const [firstLine, _secondLine, ...rest] = lines;

  // Only formatted comments
  if (rest.length === 0 || _secondLine != "") {
    return message.trim();
  }

  // Format bullet points or paragraphs
  const comment = rest.join("\n");
  const hasBulletPoints = /^\s*-\s*/.test(comment);
  const comments = hasBulletPoints
    ? bulletPointsToLines(comment).map(line => `${spacing}- ${line}`)
    : paragraphsToLines(comment).map(line => `${spacing}${line}`);

  return `${firstLine}\n\n${comments.join(joiner)}`;
};

const formatCommits = commits => commits.length > 1
  ? `**Commits**${spacedBulletPoint}${commits.reverse().map(formatCommit).join(spacedBulletPoint)}`
  : commits.reverse().map(formatCommitWith("", "\n")).join(bulletPoint)

const setup = () =>
  IN_NODE
    ? {
      getCommits: getCommitsFromCommandline,
      copyCommits: copyToClipBoardFromCommandline
    }
    : {
      getCommits: getCommitsFromVSTS,
      copyCommits: copyToClipboardFromBrowser
    };

//
// Get, format and copy commits!
//

if (!TESTING) {
  const {getCommits, copyCommits} = setup();

  getCommits()
    .then(formatCommits)
    .then(copyCommits)
    .catch(e => {
      if (!IN_NODE) alert(e.message);
      console.error("There was an error copying the commits", e);
    });
}

//
// Testing
//

const test = () => {
  const assert = require("assert");

  // Single line commit
  assert.equal(formatCommit("Single line commit"), "Single line commit");
  assert.equal(formatCommit("Single line commit\n"), "Single line commit");

  // PascalCase
  assert.equal(
    formatCommit("Single PascalCase commit"),
    "Single `PascalCase` commit"
  );
  assert.equal(
    formatCommit("Single IPascalcase commit"),
    "Single `IPascalcase` commit"
  );
  assert.equal(
    formatCommit("Single `AlreadyPascalCase` commit"),
    "Single `AlreadyPascalCase` commit"
  );

  // camelCase
  assert.equal(
    formatCommit("Single camelCase commit"),
    "Single `camelCase` commit"
  );
  assert.equal(
    formatCommit("Single camelReallyCase commit"),
    "Single `camelReallyCase` commit"
  );

  // Paragraph commits
  assert.equal(
    formatCommit(`First line

Then one of these
that goes on

Then another line`),
    `First line

  Then one of these that goes on

  Then another line`
  );

  // Bullet point commits
  assert.equal(
    formatCommit(`First line

 - Then bullet of these
   that goes on
 - Then another bullet`),
    `First line

  - Then bullet of these that goes on

  - Then another bullet`
  );

  // Format commits
  assert.equal(
    formatCommits(["Second", "First"]),
    `**Commits**

- First

- Second`
  );

  // Single commit
  assert.equal(
    formatCommits([`First line

- Then a particularly long bullet pointed item that could wrap
- Then another bullet point`]),
    `First line

- Then a particularly long bullet pointed item that could wrap
- Then another bullet point`)
};

if (TESTING) {
  try {
    test();
    console.log("Pass");
  } catch (e) {
    console.error("Fail", e);
  }
}
