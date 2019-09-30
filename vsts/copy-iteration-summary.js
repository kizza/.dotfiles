var { assign, keys } = Object;

var getIterationNameFromUrl = () =>
  new Promise((resolve, _reject) => {
    const url = window.location.href;

    return resolve(
      decodeURI(url)
        .replace(/\\/g, "/")
        .split("/")
        .pop()
        .replace(/%20/g, " ")
    );
  });

var copyToClipboardFromBrowser = message => {
  const el = document.createElement("textarea");
  el.value = message;
  el.setAttribute("readonly", "");
  el.style = { position: "absolute", left: "-9999px" };
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
  console.log(message);
};

var filterToStoryUrl = workItems =>
  workItems.filter(item => item.source === null).map(item => item.target.url);

var getWorkItemsFromIteration = iteration =>
  Promise.resolve(iteration["_links"].workitems.href)
    .then(fetch)
    .then(response => response.json())
    .then(json => json.workItemRelations);

var hydrateWorkItems = urls => Promise.all(urls.map(hydrateWorkItem));

var getIterationByName = name =>
  fetch(
    `https://${organisation}.visualstudio.com/Products/${product}/_apis/work/teamsettings/iterations?api-version=5.1`
  )
    .then(response => response.json())
    .then(iterations => {
      const iteration = iterations.value.find(
        iteration => iteration.name.toUpperCase() === name.toUpperCase()
      );

      if (!iteration) {
        alert(
          `Could not find iteration "${name}", check console log for more details`
        );
        console.error(`Could not find iteration "${name}" within`, iterations);
        throw new Error(`Could not find iteration "${name}"`);
      }

      return iteration;
    })
    .then(iteration => fetch(iteration.url))
    .then(response => response.json());

var partitionWorkItems = workItems =>
  workItems.reduce((acc, each) => {
    const key = each.state;
    const existing = acc[key] || [];
    return assign(acc, {
      [key]: existing.concat(each)
    });
  }, {});

var countPartitionPoints = partition =>
  partition.reduce((acc, each) => acc + each.points, 0);

var partitionAsBlurb = (state, partition) => {
  const total = countPartitionPoints(partition);
  const items = partition
    .map(({ title, type, link }) => `${title} _(${type})_ ${link}`)
    .join("\n\n");

  return `${stateToEmoji(state)} (${total} points)\n\n${items}`;
};

var stateToEmoji = state => {
  const emoji = {
    Closed: ":balloon: *Closed*",
    New: ":sparkles: *New stories*",
    Active: ":hammer_and_wrench: *Carried over*"
  };

  return emoji[state] || state;
};

var formatSummaryResult = partitionWorkItems =>
  Promise.resolve(partitionWorkItems)
    .then(partitioned =>
      keys(partitioned).reduce(
        (acc, key) =>
          acc.concat(
            `${key} ${partitioned[key].length} stories (${countPartitionPoints(
              partitioned[key]
            )} points)`
          ),
        []
      )
    )
    .then(formattedPartitions => formattedPartitions.join("\n"));

var formatDetailedResult = partitionWorkItems =>
  Promise.resolve(partitionWorkItems)
    .then(partitioned =>
      keys(partitioned).reduce(
        (acc, key) => acc.concat(partitionAsBlurb(key, partitioned[key])),
        []
      )
    )
    .then(formattedPartitions => formattedPartitions.join("\n\n\n"));

var formatWorkItems = workItems =>
  workItems.map(item => ({
    title: item.fields["System.Title"].trim(),
    state: item.fields["System.State"],
    points: item.fields["Microsoft.VSTS.Scheduling.StoryPoints"] || 0,
    type: item.fields["System.WorkItemType"],
    link: item["_links"].html.href
  }));

var hydrateWorkItem = workItemUrl =>
  fetch(workItemUrl).then(response => response.json());

getIterationNameFromUrl()
  .then(getIterationByName)
  .then(getWorkItemsFromIteration)
  .then(filterToStoryUrl)
  .then(hydrateWorkItems)
  .then(formatWorkItems)
  .then(partitionWorkItems)
  .then(partitioned =>
    formatDetailedResult(partitioned)
      .then(copyToClipboardFromBrowser)
      .then(() =>
        formatSummaryResult(partitioned).then(summary => {
          alert(`Copied result to clipboard\n\n${summary}`);
        })
      )
  )
  .then(result => console.log(result))
  .catch(e => console.log("There was an error", e));
