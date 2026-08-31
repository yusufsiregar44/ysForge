# ysForge

My open-source AI stack for agents, skills, hooks, workflows, and tooling.

Model-agnostic by design: one copy of each skill, symlinked into every agent
harness on the machine. Works with **Claude Code**, **Codex**, **pi**, and
anything else that reads the open `SKILL.md` format.

## Install

```bash
git clone git@github.com:yusufsiregar44/ysForge.git
cd ysForge
./scripts/install.sh
```

`install.sh` detects which harnesses are present and symlinks into each, then
registers the hook policies in `~/.claude/settings.json`. It is idempotent,
refuses to clobber files it does not own, and takes `--dry-run`.

Because it symlinks rather than copies, editing a skill in this repo takes
effect everywhere immediately. Re-run it only when adding or removing a skill.

## Layout

```
skills/<skill-name>/SKILL.md    one directory per skill
agents/<agent-name>.md          one file per agent
hooks/<policy>.sh               one script per enforced policy
templates/                      starting points for both
scripts/install.sh              symlinks into each harness
docs/portability.md             what the harnesses agree on
docs/hooks.md                   the policies, and how they get wired
```

Skills and agents are offered to an agent; hooks are enforced on it by the
harness. Currently enforced: **maximum agent depth of one** — the main session
may spawn subagents, a subagent may not spawn anything. See
[docs/hooks.md](docs/hooks.md).

## Adding a skill

```bash
mkdir -p skills/my-skill
cp templates/SKILL.md skills/my-skill/SKILL.md
$EDITOR skills/my-skill/SKILL.md
./scripts/install.sh
```

Keep to the portable subset — frontmatter is `name` and `description`, nothing
else. See [docs/portability.md](docs/portability.md) for the compatibility
matrix and the reasoning.

## License

[Apache 2.0](LICENSE)
