/**
 * What this Claude session is doing, told to paddck from inside it.
 *
 * It replaces seven settings hooks that used to do this job. Those hooks were a subprocess with no
 * memory: each one woke up knowing only its own payload, so the two questions that decide the
 * answer — *has the foreground turn ended* and *is this subagent one it waited for* — had to be
 * reconstructed from what the pane already said, over a tmux round trip, every time. A mod is
 * loaded once and stays, so it simply remembers, and paddck is told only when something changed.
 *
 * Paddck is untouched. What goes down the pipe is a Claude lifecycle event of exactly the shape
 * `paddck hook claude` already reads — so this is a better-informed sender of the same vocabulary,
 * not a new protocol. The mod does the deciding; paddck keeps the tmux.
 *
 * Two constraints shape everything below, and both were found by watching a session rather than by
 * reading the documentation:
 *
 *   - `classic.*` events never arrive. The built-in guard bypasses them for a mod at user tier —
 *     `classic.SessionStart bypassed by cc-plugin-sec-default (tier user); beneath runs` — so the
 *     settings hooks' vocabulary is not available here at all, and every signal is mod-native.
 *   - Every mods API call is asynchronous, `$.env.get` included. It returns a promise, and a
 *     promise is truthy, so forgetting to await one does not fail: it spells "[object Promise]"
 *     into a path and the error is swallowed by the catch below.
 */

/** Claude's spelling for the state paddck should land on. See `outcomeFor` in paddck's `hook.ts`. */
const resting = "Stop"
const working = "UserPromptSubmit"
const asking = "Notification"
const questioning = "PreToolUse"
const answered = "PostToolUse"
const started = "SessionStart"
const ended = "SessionEnd"

/** The tool Claude puts a question to you with — the one tool name that is a state. */
const questionTool = "AskUserQuestion"

/** What paddck was last told, so a transition that changes nothing costs nothing. */
let announced = ""

/** Subagents started and not yet finished, background and awaited alike. */
let liveAgents = 0

/** Of those, the ones still running when the foreground turn ended. */
let outstanding = 0

/** The foreground turn has ended. What makes a finishing subagent mean something, or nothing. */
let isResting = false

/** A permission prompt is standing, and a tool call is held behind it. */
let isAsking = false

/** A question is open. It outranks a permission prompt, which Claude words identically. */
let isQuestioning = false

export function register(on) {
  // Before the first prompt. Not raised again by `/clear`, `/resume` or `/branch` — the `turn.start`
  // behind each of those is what puts the pane right, which is why identity is read per message
  // rather than cached here.
  on("session.start", async ($, e, next) => {
    forgetTheTurn()
    announced = ""

    await tell($, { hook_event_name: started })

    return next(e)
  })

  // Every `turn.start` is the foreground: a subagent's run raises none.
  on("turn.start", async ($, e, next) => {
    outstanding = 0
    isResting = false

    await tell($, { hook_event_name: working })

    return next(e)
  })

  // Counted rather than read off a payload, because the payload that used to carry it was `Stop`'s
  // and `Stop` does not reach a mod. See `backgroundWork` on the cost of that.
  on("agent.spawn", async ($, e, next) => {
    const result = await next(e)
    if (!result?.deny) liveAgents += 1

    return result
  })

  /**
   * A turn ending — the foreground's, or a subagent's, told apart by `e.agentId`.
   *
   * The foreground's is the resting point: whatever is still running at that moment is what the
   * turn left behind, and an agent that stopped with three reviewers out is working rather than
   * idle. A subagent's says nothing until the foreground has already stopped — one the turn awaited
   * finishes mid-turn, where `idle` would blink the pane between a tool call and the next one.
   * `isResting` is the record that the turn ended, and telling those two apart is the whole of what
   * used to cost a tmux read on every `SubagentStop`.
   */
  on("turn.complete", async ($, e, next) => {
    if (!e.agentId) {
      isResting = true
      outstanding = liveAgents

      await tell($, { hook_event_name: resting, background_tasks: backgroundWork(outstanding) })

      return next(e)
    }

    liveAgents = Math.max(0, liveAgents - 1)
    if (!isResting || outstanding === 0) return next(e)

    outstanding -= 1
    await tell($, { hook_event_name: resting, background_tasks: backgroundWork(outstanding) })

    return next(e)
  })

  // A question, caught as it is asked rather than as a notification a minute later.
  on("tool.call", { tool: questionTool }, async ($, e, next) => {
    isQuestioning = true
    await tell($, { hook_event_name: questioning, tool_name: questionTool })

    // Answered, escaped out of, or failed. The turn has it back either way.
    const result = await next(e)
    isQuestioning = false
    await tell($, { hook_event_name: answered, tool_name: questionTool })

    return result
  })

  /**
   * A permission prompt, at the moment the engine decides to show one. This is the event the old
   * wiring had no access to: it waited on a `Notification` that arrives six seconds late when you
   * are away from the pane and a minute late when you are not, calls itself `permission_prompt`
   * whether it is a question or a tool waiting to be approved, and by then is usually answered.
   */
  on("tool.check", async ($, e, next) => {
    const decided = await next(e)
    if (decided?.decision !== "ask" || isQuestioning) return decided

    isAsking = true
    await tell($, { hook_event_name: asking, notification_type: "permission_prompt" })

    return decided
  })

  // The far end of that prompt: the call has run, so the turn is moving again.
  on("tool.call", async ($, e, next) => {
    const result = await next(e)
    if (!isAsking) return result

    isAsking = false
    await tell($, { hook_event_name: working })

    return result
  })

  /**
   * A session that has really finished, which is the one state no other event can observe. `/clear`
   * and `/resume` end a session too and carry on in the same pane a second later, so they are left
   * alone — the turn that follows is the honest event and will say so.
   */
  on("session.end", async ($, e, next) => {
    if (e.reason !== "clear" && e.reason !== "resume") {
      await tell($, { hook_event_name: ended, reason: e.reason ?? "other" })
    }

    return next(e)
  })
}

/**
 * Hands paddck one lifecycle event, and only when it says something new. The signature it is
 * compared on is the state the event lands on plus the background count that qualifies it, so a
 * subagent finishing out of three is a change and a second `Stop` saying the same thing is not.
 *
 * Identity is read here rather than held, so that a session which carried on under a new id — what
 * `/clear` and `/resume` both do, in the same pane, without raising `session.start` again — is
 * registered under the id it actually has. `transcript_path` is left out: paddck derives it from
 * these two, and a path guessed here would be a worse answer than the one it works out.
 *
 * A hook is a bystander to the session it observes: a failure here loses one update, and that is
 * cheaper than anything it could do about it.
 */
async function tell($, event) {
  const signature = `${event.hook_event_name}:${event.tool_name ?? ""}:${outstanding}`
  if (signature === announced) return

  announced = signature

  try {
    const root = (await $.env.get("PADDCK_ROOT")) || `${await $.env.get("HOME")}/Code/kizza/paddck`

    // Through `state.sh` rather than the shim beneath it: it is the one seam both agents reach
    // paddck by, and it writes the raw payload to the hooks log before anything can go wrong with
    // it — which is the record worth having while a new sender is being trusted.
    await $.process.run([`${root}/scripts/agents/state.sh`, "claude"], {
      stdin: JSON.stringify({
        session_id: await $.session.id(),
        cwd: await $.session.cwd(),
        ...event,
      }),
      timeoutMs: 5000,
    })
  } catch {
    // paddck is not installed, or took too long. The session is not the place to say so.
  }
}

/**
 * The count, in the shape paddck reads it from. It counts the entries that call themselves running,
 * so what it needs is that many of them and nothing else about them.
 *
 * What this no longer covers, and the one thing the move to a mod cost: a Bash command left running
 * in the background. `Stop`'s payload counted those alongside subagents and `Stop` does not reach a
 * mod, so a turn that ends with only a background command out now reads as idle rather than
 * working. Subagents are the common case by far, and they are counted exactly.
 */
function backgroundWork(count) {
  return Array.from({ length: count }, () => ({ status: "running" }))
}

function forgetTheTurn() {
  liveAgents = 0
  outstanding = 0
  isResting = false
  isAsking = false
  isQuestioning = false
}
