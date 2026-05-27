# Autonomous Dev Loop

A reusable, agent-agnostic discipline for building software as a tight, **self-correcting test
loop** — one an AI coding agent can drive **red → green largely on its own** without drifting or
gaming the tests, while a human stays responsible for the one thing only a human can do: **judging
reality and freezing its failures into the test corpus.**

Packaged as a **skill** you clone into any agent that supports a skills directory (Claude Code,
Codex, OpenClaw, …). Works in any language; also useful with no agent at all.

**English** · [中文](#中文)

---

## Install (any agent)

Hand [`INSTALL.md`](INSTALL.md) to your AI assistant and say "install this skill," or do it yourself
— pick your `SKILLS_DIR` and clone:

| Agent | `SKILLS_DIR` |
|-------|--------------|
| Claude Code | `~/.claude/skills` |
| Codex | `${CODEX_HOME:-$HOME/.codex}/skills` |
| OpenClaw | `~/.openclaw/skills` |

```bash
SKILLS_DIR=~/.claude/skills        # change per the table
mkdir -p "$SKILLS_DIR"
git clone https://github.com/wangzezlq/autonomous-dev-loop.git "$SKILLS_DIR/autonomous-dev-loop"
"$SKILLS_DIR/autonomous-dev-loop/bin/check-deps.sh"
```

For agents that use an always-on instructions file instead of a skills directory, copy
[`AGENTS.md`](AGENTS.md) into the project you're working on. The method is identical either way.

## The core idea (one line)

> An agent only knows "tests pass / fail," **not** "works in reality." Green ≠ working. The loop
> only *converges* because a human freezes every real-world failure into a permanent **fixture** —
> after which it can't recur, and the test corpus creeps toward reality.

So the human's one irreplaceable job is **translating real failures into fixtures.** Everything
else is the agent's.

## How to use it

1. Split code into a **pure core** (data in → data out) and a thin **I/O shell**. The loop only
   autonomously covers the pure half.
2. Per feature: extract the pure function → write the **spec as tests** (spec first) → build
   **fixtures from real data** → run to **red** → make it green editing **only the implementation,
   never the tests** → **reality-gate** it; turn any real failure into a new fixture.
3. Enforce the gate with a **pre-commit hook / CI** so "green" isn't just trusted.

Full method in [`SKILL.md`](SKILL.md); the deep dive + a worked example in
[`references/playbook.md`](references/playbook.md); stand it up in a project via
[`assets/scaffold/BOOTSTRAP.md`](assets/scaffold/BOOTSTRAP.md).

## What's inside

| Path | What |
|---|---|
| `SKILL.md` | the method + when an agent should apply it (this is what the agent loads) |
| `references/playbook.md` | deep dive: reasoning, a worked example, per-language test-runner notes |
| `AGENTS.md` | drop-in instructions for an AI agent applying the method |
| `assets/scaffold/BOOTSTRAP.md` | step-by-step to instantiate the loop in a project |
| `assets/scaffold/pre-commit` | an enforced gate: refuse a commit if tests are red |
| `INSTALL.md` · `bin/check-deps.sh` | install instructions + dependency check |

## License

[MIT](LICENSE).

---

<a name="中文"></a>

# 自主开发循环（Autonomous Dev Loop）

一套可复用、与具体 agent 无关的工程纪律：把开发做成一个紧凑的**自我纠错测试循环**——让 AI
编码 agent 能**基本自主地红→绿迭代**，既不跑偏、也不靠改测试蒙混；而人只负责一件机器替代不了的事：
**判断现实，并把现实中的失败固化成测试样本（fixture）。**

它打包成一个 **skill**，克隆进任何支持 skills 目录的 agent（Claude Code、Codex、OpenClaw…）即可用。
任何语言通用；没有 agent 时也能当工程规范用。

## 安装（任意 agent）

把 [`INSTALL.md`](INSTALL.md) 丢给你的 AI 助手说"装一下这个 skill"，或者自己来——选好
`SKILLS_DIR` 再克隆：

| Agent | `SKILLS_DIR` |
|-------|--------------|
| Claude Code | `~/.claude/skills` |
| Codex | `${CODEX_HOME:-$HOME/.codex}/skills` |
| OpenClaw | `~/.openclaw/skills` |

```bash
SKILLS_DIR=~/.claude/skills        # 按上表替换
mkdir -p "$SKILLS_DIR"
git clone https://github.com/wangzezlq/autonomous-dev-loop.git "$SKILLS_DIR/autonomous-dev-loop"
"$SKILLS_DIR/autonomous-dev-loop/bin/check-deps.sh"
```

如果你的 agent 不用 skills 目录、而是读一份常驻指令文件（比如 Codex 读 `AGENTS.md`），那就把本仓库的
[`AGENTS.md`](AGENTS.md) 拷进你正在开发的项目里。两种方式，方法完全一样。

## 核心思想（一句话）

> agent 只知道"测试过没过"，**不知道**"在真实世界里好不好用"。绿 ≠ 能用。这个循环之所以能**收敛**，
> 是因为人把每一次真实世界的失败固化成一条永久 **fixture**——之后它再也不会复发，测试语料一点点逼近现实。

所以人唯一不可外包的活，是**把真实失败翻译成 fixture**。其余都是 agent 的活。

## 怎么用

1. 把代码切成**纯逻辑内核**（吃数据吐数据）和薄薄的 **I/O 外壳**。循环只能自动覆盖纯逻辑那半。
2. 每个功能：抽出纯函数 → **先写 spec＝测试** → 用**真实数据造 fixture** → 跑到**红** →
   只改实现、**绝不动测试**地改到绿 → **reality gate** 真实验证；任何真实失败都回填成新 fixture。
3. 用 **pre-commit / CI** 把门禁做硬，让"绿"不只是靠自觉。

完整方法见 [`SKILL.md`](SKILL.md)；深度版＋实战复盘见
[`references/playbook.md`](references/playbook.md)；在项目里落地见
[`assets/scaffold/BOOTSTRAP.md`](assets/scaffold/BOOTSTRAP.md)。

## 仓库内容

| 路径 | 内容 |
|---|---|
| `SKILL.md` | 方法 + agent 何时该用它（agent 加载的就是它） |
| `references/playbook.md` | 深度版：原理、实战复盘、各语言测试 runner 选型 |
| `AGENTS.md` | 给 AI agent 的即用执行指令 |
| `assets/scaffold/BOOTSTRAP.md` | 在项目里把循环搭起来的分步清单 |
| `assets/scaffold/pre-commit` | 强制门禁：测试红就拒绝提交 |
| `INSTALL.md` · `bin/check-deps.sh` | 安装说明 + 依赖检查 |

## 许可证

[MIT](LICENSE)。
