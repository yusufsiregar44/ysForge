# ysForge

A model-agnostic collection of skills and agents, shared across Claude Code,
Codex, pi and anything else that reads the open `SKILL.md` format.

## Layout

```
skills/<skill-name>/SKILL.md    one directory per skill
agents/<agent-name>.md          one file per agent
hooks/<policy>.sh               one script per enforced policy
templates/                      starting points for both
scripts/install.sh              symlinks the above into each harness
docs/portability.md             what the harnesses agree on
docs/hooks.md                   the policies, and how they get wired
```

## Enforced policies

Skills and agents are offered to a model. A hook is run by the harness
regardless of what the model intends, so hooks are the only rules here that are
actually enforced. One is active, and it constrains how you work:

**Maximum agent depth of one.** The main session may spawn subagents; a
subagent may not spawn anything. Do all fan-out from the main session, and never
write a subagent prompt that asks the worker to delegate further — such a call
is denied at the tool boundary, not merely discouraged.

Read `docs/hooks.md` before adding or changing a hook, and pipe-test both
branches before wiring one up.

## Rules for anything added here

**Portability is the constraint, not a nice-to-have.** Read
`docs/portability.md` before adding a skill or agent. The short version:

- Frontmatter is `name` and `description` only. Nothing else is portable.
- `name` is lowercase-kebab and **must match the directory or filename**.
- Reference bundled files by relative path. Never absolute.
- Never name specific tools (`Read`, `Bash`, …) in a skill body — those are one
  harness's vocabulary. Describe the action instead.

**One skill, one concern.** If the description needs an "and", it is probably
two skills.

**The description is load-bearing.** It is the only text an agent sees when
deciding whether to load the skill. Write it with the words a user would
actually type, not an abstract summary.

**Start from the template.** `templates/SKILL.md` and `templates/agent.md`
carry the format and a portability checklist. Delete the trailing comment.

## Adding a skill

```bash
mkdir -p skills/my-skill
cp templates/SKILL.md skills/my-skill/SKILL.md
# edit, then:
./scripts/install.sh
```

Symlinks mean the edit is live in every harness immediately — `install.sh` only
needs re-running when a skill is added or removed, not when one is changed.
