# Bootstrap: stand up the autonomous-dev loop in a project

A language-agnostic checklist to instantiate the loop. Copy what you need; the only hard
requirement is a test command that **exits 0 on pass, non-zero on fail**.

## 1. Choose the test command

The heartbeat of the loop. Pick the simplest thing that gives a pass/fail exit code:

| Language | Command | Notes |
|---|---|---|
| Python | `pytest -q` | usually already available |
| JS/TS | `npm test` / `node --test` | keep core logic framework-free |
| Go | `go test ./...` | built in |
| Rust | `cargo test` | built in |
| Swift | `swift test` (needs Xcode) or a `swift run <Runner>` executable | with only Command Line Tools, use a dependency-free runner that `exit(1)`s on failure |
| anything | a tiny hand-rolled runner | collect failures, print them, exit non-zero |

Write the command down (in `WORKFLOW.md` and in the pre-commit hook).

## 2. Create the pure-core boundary

Make a module/package/target that imports **no I/O** (no UI, network, disk, clock, RNG). Move or
write the first piece of real logic there. The rule of thumb: *if you can't call it with plain
data and assert on the return value, it doesn't belong in the core yet.*

Typical layout:
```
<project>/
├── core/            # pure logic — the loop's autonomous territory
├── app/ (or src/)   # the I/O shell — thin; calls into core
└── tests/           # spec-as-tests + fixtures/ (data files read by path)
    └── fixtures/
```

## 3. First spec + fixtures (red → green)

Pick one real behavior that actually hurts. Capture **real** input as a fixture (a real API
response, a real log line, a real screenshot/dump — sanitized). Write the assertions first, run
to **red**, then implement until **green**. Commit.

## 4. Enforce the gate

Install the pre-commit hook so a red suite can't be committed:

```bash
mkdir -p .githooks
cp pre-commit .githooks/pre-commit
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
# edit TEST_CMD in the hook to your command from step 1
```

(Optional, later: a CI job running the same command on every push = L4.)

## 5. Document it

Drop a short `WORKFLOW.md` in the repo so the loop survives across sessions and agents. Minimum
contents: the test command, the six-step loop, the five guardrails, and where fixtures live.
The `autonomous-dev-loop` skill's SKILL.md is a fine structure to adapt.

## 6. Privacy check for captured fixtures

Real-world captures often carry sensitive data (chat content, tokens, PII). Before committing:
keep only the fields the test needs (sanitize), and gitignore the raw dumps. Commit only the
reduced fixtures.

---

When this is in place you're at **L2** (disciplined loop + enforced gate). To reach **L3**, do one
deliberately hands-off run: hand over a spec with "only edit `core/`, make `<test command>`
green, commit when green," and don't intervene — then harden whichever guardrail the run exposed.
