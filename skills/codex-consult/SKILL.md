---
name: codex-consult
description: Get a peer-AI second opinion — runs OpenAI Codex as a read-only reviewer of an analysis you have drafted and saves its structured consultation report as markdown. Use when the user says "codex consult", "second opinion", "peer review", or "validate my reasoning", or before presenting a non-obvious architectural recommendation, test plan, or technical conclusion.
---

# Codex Consultation — AI Peer Review

## Overview

Runs the OpenAI `codex` CLI as an independent reviewer of an analysis you have
already drafted, then has you weigh its report against your own. Codex runs in
`--sandbox read-only` and is for **read and consultation only** — it never
edits code, applies fixes, runs commands, or writes files. It reads the context
you give it and prints a markdown consultation report; the bundled script saves
that report outside Codex's sandbox.

## When to use

- A non-obvious conclusion is about to be presented — architecture, test plan,
  root-cause analysis — and independent validation is worth one model call.
- The user asks for it: "codex consult", "second opinion", "peer review".
- A project may declare consultation mandatory for certain roles (e.g. an
  architecture agent before presenting, a QA agent before executing a plan).

Not for trivial checks, questions fully answerable by reading the code, or
when there is no draft yet — Codex needs something to react to.

## Critical rules

- **Read-only, always.** Never pass `--full-auto`, `--sandbox workspace-write`,
  or `--sandbox danger-full-access`. If Codex recommends a change, you or a
  designated agent implements it — never Codex.
- **Draft first.** Form your own opinion before consulting; Codex's value is a
  second opinion, not a thinking aid.
- **Present Codex's report verbatim** — no filtering, summarizing, or
  editorializing. Disagreement belongs in the synthesis section, stated with
  reasoning. Treat Codex as a colleague, not an authority.
- **Identify yourself** in the prompt (model name), so Codex knows it is a
  peer-AI discussion, and make the context self-contained — Codex has no
  memory of the conversation.
- **Honor a named template.** If the user names one ("use template B"), use it
  verbatim; surface a mismatch and ask, never swap silently.
- **On failure, degrade honestly:** proceed with your own analysis and tell
  the user the peer review was unavailable.

## Steps

### 1. Draft your analysis

Complete your own analysis of the problem first, independently.

### 2. Build the prompt

Pick the matching template from
[`references/templates.md`](references/templates.md) — A (architecture),
B (test plan), C (ad-hoc) — fill it in, and write it to a temporary file.

**Done when** the prompt is self-contained (challenge, your full draft, the
specific questions) and identifies your model by name.

### 3. Run the consultation

```bash
./scripts/consult.sh <topic-slug> <prompt-file>
```

(kebab-case slug, e.g. `order-service-refactor`.) The script handles the
non-tty hang (`</dev/null`), captures stderr to a sibling `.err` file, applies
a 10-minute cap, and saves the report as `{timestamp}-{slug}.md`.

Settings resolve per key: **environment variable → per-machine config file →
default**. The config file lives at
`${XDG_CONFIG_HOME:-~/.config}/codex-consult/config` and is written by
[`scripts/configure.sh`](scripts/configure.sh) — so each installation can set
its own report destination (e.g. a notes vault) while the skill files stay
identical everywhere:

```bash
./scripts/configure.sh --dir ~/path/to/vault/codex-consult   # this machine
./scripts/configure.sh --show                                # effective config
```

| Env var | Config key | Default |
|---|---|---|
| `CODEX_CONSULT_DIR` | `dir` | `~/Documents/codex-consult` |
| `CODEX_CONSULT_MODEL` | `model` | `gpt-5.5` |
| `CODEX_CONSULT_EFFORT` | `effort` | `high` |
| `CODEX_CONSULT_TIMEOUT` | `timeout` | `600` (empty disables) |

**Done when** the script prints `saved: <path>` and the report is non-empty.

### 4. Present both analyses

```markdown
---
### <Your Role> Analysis
<your independent analysis>

---
### Codex Consultation Report
<verbatim codex output>

> Saved to: `<path>`

---
### Synthesis & Points of Agreement / Divergence
<where you align, where you differ, and why>
```

For architectural recommendations, wait for the user to review both before
proceeding to implementation.

## Failure modes

| Symptom | Action |
|---|---|
| `codex` not found (exit 127) | Ask user to install/`codex login`; proceed without peer review |
| Non-zero exit / empty report | Read the `.err` file the script names; common: expired login, bad model name. Don't retry blindly |
| Timeout (exit 124) | Retry once or lower `CODEX_CONSULT_EFFORT`; then proceed without |
