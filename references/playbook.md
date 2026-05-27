# Autonomous Dev Loop — Playbook (deep reference)

This is the long-form companion to `SKILL.md`. Read it for the reasoning behind the loop, a
worked end-to-end example, and practical notes for instantiating it in different languages.

## Table of contents

1. Why "machine-checkable done" is the whole game
2. Reality enters only as fixtures (the convergence argument)
3. The pure/impure split in depth
4. The single iteration, annotated
5. Guardrails: failure modes they prevent
6. Worked example: a live-UI-heavy app (hard case)
7. Per-language test-runner notes
8. Bootstrapping checklist (expanded)
9. Maturity ladder, with upgrade moves

---

## 1. Why "machine-checkable done" is the whole game

An autonomous loop is just: *act → check → correct → repeat until the check passes.* The check
is the entire load-bearing element. If the check is a human eyeballing output, the loop can't
run unattended. If the check is `tests pass / fail` (a process exit code), the implementer can
run it thousands of times and self-correct with no one watching.

So the work of "making development autonomous" is mostly the work of **turning 'is this right?'
into a command that returns an exit code.** Everything else follows.

The trap: not all of "right" can be turned into an exit code. That's not a flaw to fix; it's a
fact to design around (sections 2–3).

## 2. Reality enters only as fixtures (the convergence argument)

Claude cannot perceive "works in the real world." It perceives test results. Therefore a green
suite is a *claim* about reality, only as true as the fixtures behind it. Two consequences:

- **A loop with poor fixtures converges fast to a wrong place.** It will confidently reach green
  against assumptions and declare done.
- **The only way new truth enters the loop is a human observing reality and encoding what they
  saw as a fixture.** Once encoded, that truth is permanent — the implementer can never again
  regress it, because the test now fails if it does.

This is why "let it keep going until it works" feels broken in practice: people expect the model
to *notice* reality. It can't. You notice; you freeze what you noticed into a fixture; then the
model can chase it. Run this enough and the fixture corpus asymptotically approaches reality —
the suite becomes a faithful proxy, and the loop becomes trustworthy. There is no shortcut that
removes the human-observation step; there is only making that step cheap (good capture tooling)
and making its product durable (fixtures in version control).

## 3. The pure/impure split in depth

"Pure" = output is a function of input, no hidden state, no I/O, deterministic. Pure code is
trivially loop-testable: build inputs, assert outputs.

"Impure / live" = depends on the world: UI, network, disk, clock, RNG, GPUs, other processes,
human input. You cannot make these deterministic without either (a) capturing a real sample and
replaying it, or (b) faking them — and faking is dangerous because you tend to fake your
*assumptions*, reproducing your blind spots.

The design move: **shrink the impure shell to the thinnest possible boundary, and express all
judgment as pure functions over data the shell hands them.** Example shapes:

- Don't test "does it correctly read the widget from the live tree" — instead, capture the live
  tree once as data, and test "given this tree snapshot, does `locate()` return the right node".
- Don't test "does the HTTP client get the right answer" — test "given this captured response
  body, does `parse()` extract the right fields".
- Don't test "does it render correctly" — test "given this state, does `viewModel()` produce the
  right view description".

The impure shell (the actual AX call, the actual HTTP request, the actual render) stays small
and is checked by the reality gate, not by unit tests.

## 4. The single iteration, annotated

1. **Locate/extract the pure function.** If the behavior is tangled into an I/O class, first do a
   behavior-preserving extraction into a pure unit. This refactor is itself loop-friendly: the
   "spec" is "compiles + existing behavior unchanged".
2. **Spec as tests, first.** Writing the assertions before the code forces you to define done in
   observable terms. If you can't write the assertion, you don't yet understand the requirement.
3. **Fixtures from real data.** Capture real inputs (a recorded API response, a screenshot, a
   real event log, a dump of an accessibility tree). When you must synthesize, mark it clearly
   and treat it as provisional until a real sample replaces it.
4. **Red.** Run and watch it fail. If it passes before you've implemented anything, the test is
   not exercising the code — fix the test, not your mood.
5. **Green, implementation-only.** Iterate. The implementer may touch only the implementation
   directory. Each loop: run → read failure → edit → run.
6. **Reality gate.** Use the feature for real. Every discrepancy is a gift: it's a fixture you
   didn't know you needed. Capture it, add the assertion, return to step 4.

## 5. Guardrails: the failure modes they prevent

- **Tests read-only to implementer →** prevents the single most common autonomous-loop
  degeneration: reaching green by deleting/loosening assertions. If the model can edit the
  oracle, the oracle is worthless.
- **Spec first →** prevents post-hoc rationalization of whatever was produced.
- **Commit per green →** every green is a checkpoint; a later mistake costs one `git reset`, not a
  debugging session.
- **Scope fence →** prevents collateral edits; keeps diffs reviewable and the blast radius small.
- **Reality gate →** prevents shipping a confident green that reality never validated.
- **Enforcement (pre-commit/CI) →** converts the above from "the agent was told to" into "the
  system won't let it not". Trust, but verify mechanically.

## 6. Worked example: a live-UI-heavy app (hard case)

Context: a macOS app that captures meeting subtitles by screenshotting a region, OCR-ing it, and
producing meeting notes. Almost all of its value lived in the *impure* half — reading another
app's live UI, OCR, screen capture. A textbook-hard case for autonomy.

What the loop looked like:

- **Extracted pure core:** subtitle text parsing, dedup/merge of streaming captions, noise/
  watermark filtering, and "given a snapshot of the window list, locate the subtitle window".
  All pure, all driven by a dependency-free test runner that exits 0/1.
- **The impure shell stayed thin:** the actual screenshot, the actual OCR call, the actual
  accessibility queries — verified by a human in a real meeting, not by unit tests.
- **Fixtures from reality paid off twice over:**
  - A captured accessibility-tree dump *killed two assumptions on contact*: the subtitle text was
    not in the accessibility tree at all (so "read text directly" was impossible — OCR had to
    stay), and the subtitle window was not titled what the old code searched for. Writing code
    against the *assumed* structure would have been hundreds of wasted lines. The capture cost
    ten minutes.
  - A real meeting run surfaced failures the synthetic fixtures missed: a screen watermark
    bleeding into the text, a footer landing mid-line, and the same utterance recorded twice
    because OCR read the speaker's name inconsistently. Each became a fixture; each fix was then
    a normal red→green; none can regress.
- **Guardrail that mattered most:** keeping the spec/tests out of the make-it-green step. The
  identity bug (duplicate utterances) was fixed by changing the *merge identity* from
  "(speaker, timestamp)" to "(timestamp, overlapping text)" — a real fix — rather than by
  loosening the dedup assertion to make the red go away.

Lesson: even when the *core value* is in the untestable half, the loop still earns its keep — it
makes the pure slice reliable and fast to evolve, and the fixture discipline turns each painful
real-world surprise into a permanent, never-again guarantee.

## 7. Per-language test-runner notes

The runner just needs to **exit 0 on pass, non-zero on fail**, and run fast with no ceremony.

- **Python:** `pytest` (or `python -m unittest`). Already present in most setups.
- **JS/TS:** `vitest` / `node --test`. Keep core logic in framework-free modules.
- **Go:** `go test ./...` — built in, ideal.
- **Rust:** `cargo test` — built in, ideal.
- **Swift:** `swift test` needs full Xcode (XCTest/Swift Testing). With only Command Line Tools,
  neither is available — a **dependency-free executable runner** (a small `main` that runs
  assertions and `exit(1)` on failure, invoked via `swift run <Runner>`) is a clean substitute and
  arguably a *better* loop signal because it has zero setup.
- **Anything:** when the native framework is heavy or unavailable, a tiny hand-rolled runner
  (collect failures, print them, exit non-zero) is a legitimate and portable choice. The loop
  cares about the exit code, not the framework.

For fixtures read at runtime, keep them as plain data files (JSON/CSV/text) the runner loads by
path, and tell the build system not to treat them as bundled resources (e.g. exclude them from
the target) to avoid warnings.

## 8. Bootstrapping checklist (expanded)

1. **Choose the test command.** Write it down; it's the heartbeat of the loop.
2. **Create the pure-core boundary.** A module/package/target that imports no I/O. Move (or
   write) the first pure behavior there.
3. **First spec + fixtures.** Pick one real behavior with real pain. Capture real input. Write
   assertions. Red → green.
4. **Enforce the gate.** Install the pre-commit hook (`assets/scaffold/pre-commit`); point it at
   your test command. Optionally add CI later.
5. **Document it.** Drop a short `WORKFLOW.md` in the repo: the test command, the six steps, the
   guardrails, and where fixtures live. Future-you (and future agents) will follow it.
6. **Privacy check.** If fixtures are captured from real systems, they may contain sensitive
   data — sanitize before committing (keep only the fields the test needs), and gitignore raw
   dumps.

## 9. Maturity ladder, with upgrade moves

- **L1 → L2:** write the guardrails down; start doing the reality→fixture habit deliberately.
- **L2 → L3:** install the pre-commit hook (make the gate real), then do **one** deliberately
  hands-off run — hand over a spec and "only edit <impl>, make it green, commit when green" — and
  watch where it breaks. The breaks tell you which guardrail to harden.
- **L3 → L4:** add CI that runs the suite on every push; wire regressions to block; optionally let
  a scheduled/queued agent pick up specced tasks.

Pick the cheapest next move, not the most impressive one.
