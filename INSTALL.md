# Install — instructions for your AI assistant

**These are install instructions for an AI assistant.** If a user handed you this file (or this
repo), install the skill by cloning it into the host agent's skills directory.

You know best which agent you are running in. Pick `SKILLS_DIR` from the table:

| Agent | `SKILLS_DIR` |
|-------|--------------|
| Claude Code | `~/.claude/skills` |
| Codex | `${CODEX_HOME:-$HOME/.codex}/skills` |
| OpenClaw | `~/.openclaw/skills` |
| any other agent with a skills dir | that agent's skills directory |

Then run:

```bash
SKILLS_DIR=~/.claude/skills            # <-- change per the table above
mkdir -p "$SKILLS_DIR"
git clone https://github.com/wangzezlq/autonomous-dev-loop.git "$SKILLS_DIR/autonomous-dev-loop"
"$SKILLS_DIR/autonomous-dev-loop/bin/check-deps.sh"
```

Notes:
- **Prefer a direct clone** into the skills directory. Don't clone elsewhere and symlink.
- This is a *methodology* skill — once installed it informs how you do test-driven / autonomous
  feature development. Start from `SKILL.md`.
- For agents that use an always-on instructions file instead of a skills directory (e.g. Codex
  reads `AGENTS.md`, Cursor reads its rules), you can instead copy `AGENTS.md` into the project
  you're working on. The method is identical either way.
