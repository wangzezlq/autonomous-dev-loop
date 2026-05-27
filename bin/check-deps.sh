#!/usr/bin/env bash
# Dependency check for the autonomous-dev-loop skill.
# This skill is mostly docs + a pre-commit template, so it needs almost nothing —
# your *project's own* test runner is what actually matters.
set -uo pipefail

missing=0
for c in git bash; do
    if ! command -v "$c" >/dev/null 2>&1; then
        echo "❌ missing: $c"
        missing=1
    fi
done

if [ "$missing" -eq 0 ]; then
    echo "✅ autonomous-dev-loop: dependencies OK."
    echo "   Next: read SKILL.md. To stand the loop up in a project, follow assets/scaffold/BOOTSTRAP.md."
else
    echo "→ install the missing tool(s) above, then re-run this script."
    exit 1
fi
