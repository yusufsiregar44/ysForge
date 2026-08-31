# Portability

ysForge holds one copy of each skill and agent. `scripts/install.sh` symlinks
that copy into whatever each harness expects. This file records what the
harnesses actually agree on — everything else in the repo follows from it.

## Where each harness looks

| | Claude Code | Codex | pi |
|---|---|---|---|
| Skills (user) | `~/.claude/skills/` | `~/.agents/skills/` | `~/.agents/skills/`, `~/.pi/agent/skills/` |
| Skills (repo) | `.claude/skills/` | `.agents/skills/` | `.agents/skills/`, `.pi/skills/` |
| Agents | `~/.claude/agents/*.md` | not yet verified | `~/.pi/agent/agents/*.md` |
| Instructions | `CLAUDE.md` | `AGENTS.md` | `AGENTS.md` |

**`~/.agents/skills/` is the vendor-neutral path.** Codex and pi both read it
without configuration. Claude Code does not, which is the only reason
`install.sh` needs a Claude-specific branch.

## The portable subset

Write to this and a skill works everywhere, unmodified.

### Skills

Frontmatter — **`name` and `description` only.**

| Field | Rule |
|---|---|
| `name` | lowercase `a-z`, `0-9`, hyphens. Max 64 chars. Must equal the directory name. |
| `description` | Single line, max 1024 chars. |

Everything else is harness-specific. `allowed-tools` is Claude Code and pi;
Codex configures the equivalent in a separate `agents/openai.yaml`. Unknown
keys are ignored rather than rejected, so an extra field is not fatal — but it
is silently inert on two of three harnesses, so treat it as unavailable.

The body is plain markdown. Two rules:

- **Reference bundled files by relative path** (`./scripts/check.sh`). The
  skill directory is symlinked into several locations at once, so an absolute
  path is wrong in at least two of them.
- **Do not hardcode tool names.** `Read`/`Edit`/`Bash` are Claude Code's
  vocabulary; other harnesses name their tools differently. Say "read the
  file", not "use the Read tool".

### Agents

Less portable, and honestly so:

- Claude Code and pi share the shape: markdown body, `name` + `description`
  frontmatter. Claude Code additionally reads `model`, `color` and `tools`.
- Codex's custom-agent format is **not verified**. Third-party write-ups
  describe `.codex/agents/*.toml` with `developer_instructions`, but it is
  absent from the official docs, so `install.sh` deliberately does not
  generate it. Revisit when it lands upstream.

Write agents so they still work with `name` + `description` and nothing else.

## Deciding between the two

- **Skill** — procedural knowledge loaded into the current context on demand.
  Portable. Prefer it.
- **Agent** — a separate context with its own budget, for work whose
  intermediate output you do not want back. Less portable. Use when the
  isolation is the point.

## Sources

- [Codex — Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Codex — AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [pi — Skills](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md)
- [Anthropic — claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
