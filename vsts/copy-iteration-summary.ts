type Url = string;

type Relation = { id: string; url: Url };

type Iteration = { name: string; path: string; url: Url };

type WorkItem = {
  source: Relation | null;
  target: Relation;
};

type HydratedIteration = {
  _links: {
    workitems: { href: Url };
  };
};

type PartitionedIteration = Record<WorkItemState, FormattedWorkItem[]>;

type HydratedWorkItem = {
  fields: {
    "System.Title": string;
    "System.State": WorkItemState;
    "Microsoft.VSTS.Scheduling.StoryPoints": number;
    "System.WorkItemType": string;
    _links: {
      html: { href: Url };
    };
  };
};

type FormattedWorkItem = {
  title: string;
  state: WorkItemState;
  points: number;
  type: string;
  link: Url;
};

enum WorkItemState {
  Closed,
  New,
  Active,
  Resolved
}

type AsyncFunction<T> = (args: any) => Promise<T> | T;

// var asyncMap = <T>(fun: AsyncFunction<T>) => (items: any[]) =>
//   Promise.all(items.map(fun));

var tap = <T>(fun: Function) => (input: T) => {
  fun(input);
  return input;
};

var { assign, keys } = Object;

var organisation = "";

var product = "";

var fetchJson = (url: Url) => fetch(url).then(response => response.json());

var copyToClipboard = (message: string) => {
  const el = document.createElement("textarea");
  el.value = message;
  el.setAttribute("readonly", "");
  (el as any).style = { position: "absolute", left: "-9999px" };
  document.body.appendChild(el);
  el.select();
  document.execCommand("copy");
  document.body.removeChild(el);
  console.log(message);
};

var getIterationNameFromUrl = () =>
  decodeURI(window.location.href)
    .replace(/\\/g, "/")
    .split("/")
    .pop()
    .replace(/%20/g, " ");

var filterToStoryUrl = (workItems: WorkItem[]) =>
  workItems.filter(item => item.source === null).map(item => item.target.url);

var getWorkItemsFromIteration = (
  iteration: HydratedIteration
): Promise<WorkItem[]> =>
  Promise.resolve(iteration["_links"].workitems.href)
    .then(fetchJson)
    .then(json => json.workItemRelations);

var getIterationsList = (): Promise<Iteration[]> =>
  fetchJson(
    `https://${organisation}.visualstudio.com/Products/${product}/_apis/work/teamsettings/iterations?api-version=5.1`
  ).then(iterations => iterations.value);

var partitionWorkItems = (workItems: FormattedWorkItem[]) =>
  workItems.reduce(
    (acc, each) => {
      const key = each.state;
      const existing = acc[key] || [];
      return assign(acc, {
        [key]: existing.concat(each)
      });
    },
    {} as PartitionedIteration
  );

var countPartitionPoints = partition =>
  partition.reduce((acc, each) => acc + each.points, 0);

var partitionAsBlurb = (state, partition) => {
  const total = countPartitionPoints(partition);
  const points = total > 0 ? `(${total} points)` : "";
  const items = partition
    .map(({ title, type, link }) => `${title} _(${type})_ ${link}`)
    .join("\n\n");

  return `${stateToEmoji(state)} ${points}\n\n${items}`;
};

var stateToEmoji = (state: WorkItemState) => {
  const emoji = {
    Closed: ":balloon: *Closed*",
    New: ":sparkles: *New stories*",
    Active: ":hammer_and_wrench: *Carried over*",
    Resolved: ":ok_hand: *Resolved*"
  };

  return emoji[state] || state;
};

var partitionSummary = partitionedWorkItems =>
  keys(partitionedWorkItems)
    .reduce(
      (acc, key) =>
        acc.concat(
          `${key} ${
            partitionedWorkItems[key].length
          } stories (${countPartitionPoints(partitionedWorkItems[key])} points)`
        ),
      []
    )
    .join("\n");

var partitionSummaryWithItems = (partitionWorkItems: PartitionedIteration[]) =>
  keys(partitionWorkItems)
    .reduce(
      (acc, key) => acc.concat(partitionAsBlurb(key, partitionWorkItems[key])),
      []
    )
    .join("\n\n\n");

var formatWorkItems = (workItems: HydratedWorkItem[]): FormattedWorkItem[] =>
  workItems.map(item => ({
    title: item.fields["System.Title"].trim(),
    state: item.fields["System.State"],
    points: item.fields["Microsoft.VSTS.Scheduling.StoryPoints"] || 0,
    type: item.fields["System.WorkItemType"],
    link: item["_links"].html.href
  }));

var partitionIteration = (iteration: HydratedIteration) =>
  getWorkItemsFromIteration(iteration)
    .then(filterToStoryUrl)
    .then(asyncMap<HydratedWorkItem>(fetchJson))
    .then(formatWorkItems)
    .then(partitionWorkItems);

var filterIteration = (
  partitionedIteration: PartitionedIteration,
  predicate: (key: string) => boolean
) =>
  keys(partitionedIteration).reduce(
    (acc, key) =>
      predicate(key) ? assign(acc, { [key]: partitionedIteration[key] }) : acc,
    {} as PartitionedIteration
  );

var closedPartitionedPredicate = key =>
  ["Closed", "Resolved"].indexOf(key) !== -1;

var couldNotFindIterationError = (name, iterations) => {
  alert(
    `Could not find this iteration "${name}", check console log for more details`
  );
  console.error(`Could not find iteration "${name}" within`, iterations);
  return Promise.reject(`Could not find iteration "${name}"`);
};

var stringEquals = (string1: string, string2: string) =>
  string1.toUpperCase() === string2.toUpperCase();

var getCurrentAndPrevoiusIterations = () =>
  getIterationsList().then(iterations => {
    const currentInterationName = getIterationNameFromUrl();
    const currentIteration = iterations.find(iteration =>
      stringEquals(iteration.name, currentInterationName)
    );

    if (!currentIteration) {
      return couldNotFindIterationError(currentInterationName, iterations);
    }

    const previousIteration =
      iterations[iterations.indexOf(currentIteration) - 1];

    return [currentIteration, previousIteration];
  });

var hydrateIteration = (iteration: Iteration): Promise<HydratedIteration> =>
  fetchJson(iteration.url);

getCurrentAndPrevoiusIterations()
  .then(asyncMap(hydrateIteration))
  .then(asyncMap(partitionIteration))
  .then(([current, previous]) => [
    current,
    filterIteration(previous, closedPartitionedPredicate)
  ])
  .then(
    tap<PartitionedIteration[]>(([current, previous]) =>
      console.log("Previous", previous, "Current", current)
    )
  )
  .then(iterations =>
    Promise.resolve(iterations)
      .then(asyncMap(partitionSummaryWithItems))
      .then(formatted => formatted.reverse().join("\n\n\n"))
      .then(copyToClipboard)
      .then(_ => iterations)
      .then(([current, _]) => current)
      .then(partitionSummary)
      .then(summary =>
        alert(`${summary}\n\n(Copied full summary to clipboard)`)
      )
  )
  .catch(e => console.error("There was an error :(", e));
