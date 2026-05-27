---
name: autonomous-dev-loop
description: >-
  A reusable discipline for developing features as a tight, self-correcting test loop
  where Claude iterates red→green largely on its own without drifting or gaming the tests.
  Use this whenever doing or setting up test-driven / spec-first development; when the user
  wants Claude to "make the tests pass" and self-iterate; when hardening a codebase so an
  agent can develop in it safely; when separating testable logic from I/O; when figuring out
  how to test something that depends on live UI, external services, devices, time, or
  randomness; or when standing up an autonomous-dev workflow (test runner, fixtures,
  guardrails, pre-commit/CI) in a new or existing project. Trigger even if the user never
  says "TDD" — e.g. "set up tests so you can iterate on this yourself", "make this repo
  agent-friendly", "how do I test the part that needs a real browser/meeting/API",
  "add a spec and grind it green", "why do my autonomous coding loops cheat the tests or
  spin forever", "let Claude keep developing this until it works".
  This is about building or running the development loop itself, not one-off testing chores —
  do NOT use it for merely writing or debugging a single test, for scheduling or recurring test
  runs (that's the loop/schedule commands), for reviewing a PR for bugs, or for manually
  verifying a fix by launching the app.
---

# Autonomous Dev Loop

A way to build features as a loop: define a **machine-checkable "done"**, let the implementer
(you, Claude) iterate **red → green** mostly unattended, and reserve the human for the one job
only they can do — judging reality and freezing its failures into the test corpus.

Language- and project-agnostic. Most valuable when the goal is to develop with little
hand-holding *without* the loop silently drifting or declaring false victory.

## The one idea that makes it work

> **A loop needs a signal it can read. Claude only knows "tests pass / fail" — it does NOT
> know "works in reality". Green ≠ working. The loop only *converges* because every
> real-world failure gets frozen into a permanent fixture; after that the same failure can't
> recur, and the corpus creeps toward reality over time.**

So the human's one irreplaceable job is **translating real failures into fixtures**.
Everything else is the implementer's. If you skip the fixture step, "keep going until it
works" either spins forever or stops at a green that doesn't hold up in the world.

Internalize this before anything else — the rest of the skill is mechanics in service of it.

## Split the code into two halves

The loop can only **autonomously** cover the part that's checkable without the world. So the
highest-leverage architectural move is to push as much behavior as possible into **pure
functions** (data in → data out) behind a thin I/O shell. Whatever genuinely needs the world
stays in the shell and is verified by a human + recorded fixtures.

| | Pure logic — loop covers it automatically | Live / external — loop stops here |
|---|---|---|
| Examples | parsing, transforms, dedup/merge, validation, formatting, decision logic over a captured snapshot | real UI, network/API, the filesystem, devices, clock, randomness, other apps |
| "Done" signal | feed input, assert output — fast, deterministic | needs a human + the real thing |
| Strategy | drop straight into the loop | first **capture reality as a fixture**, push the judgment into a pure function over that fixture; leave the irreducible bit for manual verification |

When a new requirement arrives, first ask: *can this become a function that eats data and
returns data?* If yes → pure half, make it testable. If no → carve out the testable core and
keep the I/O shell as thin as possible.

## One iteration (the loop body)

1. **Locate/extract the pure function** for the behavior you're adding or fixing.
2. **Write the spec as tests** — assertions that encode the intended behavior. Spec first,
   implementation second.
3. **Build fixtures from REAL data, not imagination.** The fastest way to be confidently wrong
   is to mock your assumptions and then pass against the fiction.
4. **Run → red.** A test that can't fail is testing nothing; seeing it fail first proves it's wired up.
5. **Make it green by editing only the implementation — never the tests.** Re-run, read the
   failure, fix, repeat until green. This is the part Claude can grind on its own.
6. **Reality gate** — exercise it for real. On any gap, **capture that real case as a new
   fixture** and go back to step 4. This is how reality enters the loop.

## Guardrails (and why each exists)

1. **Tests are read-only to the implementer.** If the make-it-green step can edit the tests,
   the shortest path to green is to weaken them — not from malice, just optimization. Keep
   tests in a path the implementer is explicitly told not to touch; changing the spec is a
   separate, deliberate step.
2. **Spec before implementation.** Define "done" before writing code, or you'll rationalize
   whatever you produced into "done".
3. **Commit on every green.** Cheap rollback and a bisectable history; each green is a save point.
4. **Scope fence.** The loop edits only the directories it should, so it can't wander off and
   "helpfully" refactor unrelated code.
5. **Reality gate is non-negotiable.** Green is a gate, not a finish line.

**Make the guardrails structural, not just good intentions:** a **pre-commit hook or CI** that
runs the tests turns "green = gate" into something enforced rather than trusted. See
`assets/scaffold/pre-commit`.

## Anti-patterns to watch for

- **Mocking from assumptions** instead of captured reality — you'll pass against a fiction, and
  the mock will hide exactly the bug reality would have shown.
- **Letting the implementer relax the tests** to reach green.
- **Building loop infrastructure for a throwaway.** Match rigor to stakes; a one-off script
  doesn't need a test harness.
- **Treating green as shipped.** Skipping the reality gate.
- **A pure surface so thin the loop covers nothing that matters** — then you've automated the
  trivial and left all the risk in the unmeasured shell.

## Are you actually autonomous yet? (maturity ladder)

Use this to self-assess and pick the next *cheapest* upgrade — don't skip levels.

- **L1 — Testable:** pure core separated from I/O; a single command gives a pass/fail verdict.
- **L2 — Disciplined human-driven loop:** the six-step loop + guardrails + reality→fixture
  habit, but a human drives each step. (Most teams that "do TDD" live here.)
- **L3 — Hands-off iteration:** hand over a spec and "make it green, only edit <impl dir>,
  commit when green", and the implementer grinds unattended; the human only does the reality gate.
- **L4 — Continuous:** CI runs the tests on every change, regressions are caught automatically,
  tasks are picked up and driven to green without prompting.

A common honest state is **L2**: the scaffolding exists and the cycle has been practiced, but
no run has happened truly unattended and the guardrails are convention, not enforcement. The
cheapest step toward real autonomy is usually the **pre-commit hook** (makes the gate real) and
then **one deliberately hands-off run** to find where it breaks.

## Standing it up in a project

For a new or existing project, follow `assets/scaffold/BOOTSTRAP.md`. The short version:

1. Pick the **test command** — the simplest thing that exits 0 on green, non-zero on red.
   Prefer a dependency-free runner if the language's test framework isn't readily available.
2. Create the **pure-core boundary** (e.g. a `core/` module or library target with no I/O imports).
3. Write the **first spec+fixtures** for one real behavior; get red→green.
4. Install the **pre-commit hook** (`assets/scaffold/pre-commit`) so the gate is enforced.
5. Drop a short **`WORKFLOW.md`** in the repo so the loop is documented for next time (you can
   adapt the structure of this skill).

## Going deeper

`references/playbook.md` has the full rationale, a worked end-to-end example (a macOS subtitle
tool whose core value lived in an untestable live-UI layer — a hard case that shows the
fixture discipline carrying its weight), and notes on per-language test-runner choices.
Read it when you want the "why" in depth or a concrete model to imitate.
