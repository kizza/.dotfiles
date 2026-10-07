import type { On } from "claude-code"
import { expect, test } from "claude-code/testing"

/**
 * The regression this mod was rewritten for: an `ask` from `tool.check` is not a human being asked.
 * Under auto mode the engine answers `ask` for nearly every call and settles it with a classifier
 * nobody sees, so a mod that forwards one as a permission prompt paints a working pane amber for
 * the length of every tool call it makes — which is every row in the paddock, never going green.
 *
 * A test's own hooks sit *beneath* the plugin's, which is what lets it stage the verdict: the mod's
 * `next(e)` reaches the hook below and is handed `ask`, exactly as a session under auto mode hands
 * it one.
 */

/**
 * The bottom of the chain: an ask, the call answered, and every payload the mod sent paddck.
 *
 * `tell` reads the session and the environment before it runs anything, and swallows its own
 * failures by design — a hook is a bystander to the session it observes. So every one of those has
 * to be answered here too, or the mod sends nothing, the assertions pass on an empty list, and the
 * test says the regression is fixed because nothing happened at all.
 */
function staged(on: On): string[] {
  const told: string[] = []

  on("tool.check", () => ({ decision: "ask" as const }))
  on("tool.call", () => ({ result: { stdout: "", stderr: "", interrupted: false, isImage: false } }))
  // A call on `$` answers `{ value }`, not the value — a bare string is skipped as "not a result
  // object", and `tell`'s own catch makes that look like a mod with nothing to say.
  on("env.get", (_$, e) => ({ value: e.name === "PADDCK_ROOT" ? "/paddck" : "/home" }))
  on("session.id", () => ({ value: "test-session" }))
  on("session.cwd", () => ({ value: "/tmp" }))
  on("process.run", (_$, e) => {
    told.push(String(e.init?.stdin ?? ""))

    return {
      value: { exitCode: 0, stdout: "", stderr: "", isStdoutTruncated: false, isStderrTruncated: false },
    }
  })

  return told
}

test("an ask on an ordinary tool call is counted, not reported as a permission prompt", async ($, on) => {
  const told = staged(on)

  // The engine's own order, and both halves are needed: a plugin's `$.tool.call` does not raise the
  // permission chain by itself, so the check is asked for as the engine asks it.
  await $.tool.check({ tool: "Bash", input: { command: "ls" } })
  await $.tool.call({ tool: "Bash", command: "ls" })

  expect(told.some((payload) => payload.includes('"hook_event_name":"UserPromptSubmit"'))).toBe(true)
  expect(told.some((payload) => payload.includes('"hook_event_name":"Notification"'))).toBe(false)
  expect(told.some((payload) => payload.includes('"permission_checks":{"allow":0,"ask":1,"deny":0}'))).toBe(true)
})
