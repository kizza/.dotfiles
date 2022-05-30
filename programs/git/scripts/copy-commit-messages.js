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

const formatCommitWith = (prefix, joiner) => input => formatCommit(input, prefix, joiner)

const formatCommit = (input, prefix, joiner) => {
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
    ? bulletPointsToLines(comment).map(line => `${prefix}- ${line}`)
    : paragraphsToLines(comment).map(line => `${prefix}${line}`);

  return `${firstLine}\n\n${comments.join(joiner)}`;
};

const formatCommits = commits => commits.length > 1
  ? commits
    .reverse()
    .map(formatCommitWith(" ", "\n"))
    .join("\n\n")
  : formatCommitWith("", "\n")(commits[0])

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
  const format = formatCommitWith(" ", "\n")

  // Single line commit
  assert.equal(format("Single line commit"), "Single line commit");
  assert.equal(format("Single line commit\n"), "Single line commit");

  // // PascalCase
  assert.equal(
    format("Single PascalCase commit"),
    "Single `PascalCase` commit"
  );
  assert.equal(
    format("Single IPascalcase commit"),
    "Single `IPascalcase` commit"
  );
  assert.equal(
    format("Single `AlreadyPascalCase` commit"),
    "Single `AlreadyPascalCase` commit"
  );

  // camelCase
  assert.equal(
    format("Single camelCase commit"),
    "Single `camelCase` commit"
  );
  assert.equal(
    format("Single camelReallyCase commit"),
    "Single `camelReallyCase` commit"
  );

  // Paragraph commits
  assert.equal(
    formatCommitWith("", "\n\n")(`First line

  Then comment on
  multiple lines

  Then another line`),
    `First line

Then comment on multiple lines

Then another line`
  );

  // Bullet point commits
  assert.equal(
    formatCommitWith("  ", "\n")(`First line

  - Then bullet on
  multiple lines
  - Then another bullet`),
    `First line

  - Then bullet on multiple lines
  - Then another bullet`
  );

  // Format commits
  assert.equal(
    formatCommits(["Second", "First"]),
    "First\n\nSecond"
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
