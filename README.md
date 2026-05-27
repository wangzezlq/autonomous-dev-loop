# Autonomous Dev Loop

A small, framework-neutral discipline for building software features as a tight,
self-correcting test loop — one an AI coding agent can drive **red → green largely on its
own** without drifting or gaming the tests, while a human stays responsible for the one thing
only a human can do: **judging reality and freezing its failures into the test corpus.**

Works in any language, any project, with any capable coding agent — or with no agent at all
(it's just good engineering discipline that happens to make autonomy safe).

> Distilled from a real project where most of the value lived in an *untestable* live-UI layer
> (screenshot + OCR of another app's meeting subtitles). A hard case — which is exactly why the
> discipline had to be explicit. See `PLAYBOOK.md` for that worked example.

## The one idea that makes it work

> **A loop needs a signal it can read. An agent only knows "tests pass / fail" — it does NOT
> know "works in reality." Green ≠ working. The loop only *converges* because every real-world
> failure gets frozen into a permanent fixture; after that the same failure can't recur, and the
> test corpus creeps toward reality over time.**

So the human's one irreplaceable job is **translating real failures into fixtures.** Everything
else is the agent's. Skip the fixture step and "keep going until it works" either spins forever
or stops at a green that doesn't hold up in the world.

## Split the code into two halves

The loop can only **autonomously** cover the part that's checkable without the world. So the
highest-leverage move is to push as much behavior as possible into **pure functions**
(data in → data out) behind a thin I/O shell. Whatever genuinely needs the world stays in the
shell and is verified by a human + recorded fixtures.

| | Pure logic — loop covers it automatically | Live / external — loop stops here |
|---|---|---|
| Examples | parsing, transforms, dedup/merge, validation, formatting, decisions over a captured snapshot | real UI, network/API, filesystem, devices, clock, randomness, other apps |
| "Done" signal | feed input, assert output — fast, deterministic | needs a human + the real thing |
| Strategy | drop straight into the loop | first **capture reality as a fixture**, push the judgment into a pure function over that fixture; leave the irreducible bit for manual verification |

When a new requirement arrives, first ask: *can this become a function that eats data and
returns data?* If yes → pure half, make it testable. If no → carve out the testable core and
keep the I/O shell as thin as possible.

## One iteration (the loop body)

1. **Locate/extract the pure function** for the behavior you're adding or fixing.
2. **Write the spec as tests** — assertions that encode the intended behavior. Spec first,
   implementation second.
3. **Build fixtures from real data, not imagination.** The fastest way to be confidently wrong
   is to mock your assumptions and pass against the fiction.
4. **Run → red.** A test that can't fail is testing nothing; seeing it fail first proves it's wired up.
5. **Make it green by editing only the implementation — never the tests.** Re-run, read the
   failure, fix, repeat until green. This is the part an agent can grind on its own.
6. **Reality gate** — exercise it for real. On any gap, **capture that real case as a new
   fixture** and go back to step 4. This is how reality enters the loop.

## Guardrails (and why each exists)

1. **Tests are read-only to the implementer.** If the make-it-green step can edit the tests, the
   shortest path to green is to weaken them — not from malice, just optimization. Keep tests in a
   path the implementer is told not to touch; changing the spec is a separate, deliberate step.
2. **Spec before implementation** — or you'll rationalize whatever you produced into "done".
3. **Commit on every green** — cheap rollback, bisectable history; each green is a save point.
4. **Scope fence** — the loop edits only the directories it should, so it can't wander off.
5. **Reality gate is non-negotiable** — green is a gate, not a finish line.

**Make the guardrails structural, not just intentions:** a **pre-commit hook or CI** that runs
the tests turns "green = gate" into something enforced rather than trusted. See
[`scaffold/pre-commit`](scaffold/pre-commit).

## Anti-patterns

- **Mocking from assumptions** instead of captured reality — you pass against a fiction, and the
  mock hides exactly the bug reality would have shown.
- **Letting the implementer relax the tests** to reach green.
- **Building loop infrastructure for a throwaway** — match rigor to stakes.
- **Treating green as shipped** — skipping the reality gate.
- **A pure surface so thin the loop covers nothing that matters.**

## Maturity ladder (self-assess; take the cheapest next step)

- **L1 — Testable:** pure core split from I/O; one command gives a pass/fail verdict.
- **L2 — Disciplined human-driven loop:** the six steps + guardrails + reality→fixture habit, a
  human driving each step. (Most teams that "do TDD" live here.)
- **L3 — Hands-off iteration:** hand over a spec and "make it green, only edit `<impl>`, commit
  when green", and the agent grinds unattended; the human only does the reality gate.
- **L4 — Continuous:** CI runs tests on every change, regressions are caught automatically.

The cheapest move toward real autonomy is usually the **pre-commit hook** (makes the gate real)
and then **one deliberately hands-off run** to find where it breaks.

## Use it

- **Stand it up in a project:** follow [`scaffold/BOOTSTRAP.md`](scaffold/BOOTSTRAP.md).
- **With an AI agent generally:** point it at [`AGENTS.md`](AGENTS.md) (or just this README +
  `PLAYBOOK.md`). The method is the method regardless of tool.
- **With Claude Code specifically:** install the bundled skill —
  [`dist/autonomous-dev-loop.skill`](dist/) — or copy `dist/autonomous-dev-loop/` into
  `~/.claude/skills/`. Then it triggers automatically on relevant dev tasks.

## Files

| Path | What |
|---|---|
| `README.md` | the method (this file) |
| `PLAYBOOK.md` | deep dive: the reasoning + a worked example + per-language test-runner notes |
| `AGENTS.md` | instructions for an AI agent applying the method |
| `scaffold/BOOTSTRAP.md` | step-by-step to instantiate the loop in a new/existing project |
| `scaffold/pre-commit` | an enforced gate: refuse a commit if tests are red |
| `dist/` | the Claude Code skill package (`.skill`) for one-click install |

## License

[MIT](LICENSE).
