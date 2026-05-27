# AGENTS.md

Instructions for an AI coding agent working in this repository, or applying this method to
another project. Full method: `SKILL.md` / `README.md`. Deep reference: `references/playbook.md`.
The essentials:

- Define "done" as a **command that exits 0 (green) / non-zero (red)**. That command is your only
  reliable signal. **Green ≠ works in reality.**
- Keep **pure logic** (data in → data out) separate from the **I/O shell**. Only the pure half is
  yours to iterate on autonomously; the live/external half needs a human + recorded fixtures.
- Per feature: extract the pure function → **write the spec as tests first** → build fixtures from
  **real captured data** (never mock your assumptions) → run to **red** → make it green by editing
  **only the implementation, never the tests** → stop and let a human **reality-gate** it.
- When the human reports a real-world failure, **add it as a fixture**, then fix to green. That is
  the *only* way reality enters the loop.
- **Commit on every green.** Touch only the directories the task needs.
- **Never reach green by weakening or deleting tests.** If a test seems wrong, flag it for a human
  — changing the spec is a separate, deliberate step, not part of "make it pass".

This skill is about building/running the development loop itself. It is **not** for one-off test
writing, scheduling test runs, PR review, or manually verifying the app by running it.
