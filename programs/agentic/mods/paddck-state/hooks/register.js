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
 *   - A mod cannot see a permission prompt. `tool.check` fires *before the mode settles an ask*,
 *     and `tool.call`'s `next(e)` spans the prompt and the tool's own run together — so there is no
 *     moment here that means *the human answered*, and `waiting` is not a state this file can tell.
 *     That one is Claude's `Notification`, through a settings hook. See `permissionChecks`.
 */

/** Claude's spelling for the state paddck should land on. See `outcomeFor` in paddck's `hook.ts`. */
const resting = "Stop"
const working = "UserPromptSubmit"
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

/** A question is open — the one thing on this side of the fence that really does hold for a human. */
let isQuestioning = false

/**
 * What the engine decided about each tool call this turn, counted rather than acted on.
 *
 * `ask` does not mean anybody was asked. It means the call went to *the mode's decider*, which in
 * auto mode is a classifier that answers in a second and shows nobody anything — so a turn of
 * fourteen asks and no prompt at all is the ordinary case, and reading `ask` as *a human is wanted*
 * is what used to paint a working pane amber for the length of every tool call it made.
 *
 * It rides along on the events below so paddck's diagnosis file can say what the engine decided
 * beside what the pane looked like, and is the record that keeps this from being re-inferred.
 */
const permissionChecks = { allow: 0, ask: 0, deny: 0 }

/**
 * The soonest Claude raises `Notification` for a prompt that is standing: six seconds when you are
 * away from the pane, a minute or more when you are sitting in it. A tool call that came back
 * faster than this was never prompted, which is what lets the common case stay free above.
 */
const promptFloorMilliseconds = 6_000

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
    permissionChecks.allow = permissionChecks.ask = permissionChecks.deny = 0

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
   * What the engine decided, counted and not otherwise acted on — this hook deliberately says
   * nothing to paddck.
   *
   * It used to. An `ask` here was sent on as a `Notification`, on the reading that the engine had
   * decided to show a prompt. It has not: `ask` means the call goes to the mode's decider, and
   * under auto mode that is a classifier nobody sees. So every tool call raised a prompt that was
   * never shown, and the pane read *waiting for you* for as long as the call took to run — which,
   * for a spec run, is a minute of a working agent asking to be rescued.
   *
   * There is no repair available here, only the tally. The moment a human answers a prompt is not
   * observable from a mod: `tool.check` resolves before the mode settles, and `tool.call`'s
   * `next(e)` covers the prompt and the tool's own run as one span, so nothing distinguishes *they
   * approved it* from *it finished*. Claude's `Notification` is the only honest signal for that and
   * it reaches paddck by the settings hook beside this mod — see `claude.nix`.
   */
  on("tool.check", async ($, e, next) => {
    const decided = await next(e)
    if (decided?.decision in permissionChecks) permissionChecks[decided.decision] += 1

    return decided
  })

  /**
   * A call has run, so the turn is moving. Which only needs saying when something else said
   * otherwise — and the something else is now a writer this file cannot hear: the `Notification`
   * settings hook, which puts the pane amber for a prompt that really stood.
   *
   * That is what `regardless` is for. `announced` records what *this mod* last sent, so a pane the
   * hook turned amber still matches the `working` the mod last sent and would be deduped into
   * silence — leaving the row asking for a human who answered a minute ago.
   *
   * The length of the call is what settles it, and cheaply. Claude raises that notification six
   * seconds after the fact at the very earliest, so a call that came back faster than that cannot
   * have had one and cannot have left the pane amber: it dedupes as before and costs nothing. Only
   * a call slow enough to have been prompted pays for a subprocess, which is the handful a session
   * really is prompted on plus the long ones, where one `tmux set-option` against a minute of
   * waiting is not a cost worth counting.
   */
  on("tool.call", async ($, e, next) => {
    const startedAt = Date.now()
    const result = await next(e)

    if (!isQuestioning) {
      await tell($, { hook_event_name: working }, { regardless: Date.now() - startedAt >= promptFloorMilliseconds })
    }

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
async function tell($, event, { regardless } = {}) {
  const signature = `${event.hook_event_name}:${event.tool_name ?? ""}:${outstanding}`
  if (signature === announced && !regardless) return

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
        permission_checks: { ...permissionChecks },
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
  isQuestioning = false
}
