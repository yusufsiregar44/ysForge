# Hooks

Skills and agents are things an agent *may* use. A hook is something the
harness *runs*, whether the agent likes it or not — which makes hooks the only
place in this repo that can enforce a rule rather than suggest one.

`hooks/` holds one script per policy. Each reads a hook payload on stdin and
writes a decision to stdout.

## Why hooks are wired, not symlinked

Everything else here is a file the harness discovers by looking in a directory,
so a symlink is enough. A hook has to be *registered*: the harness only runs it
because a config file names it. That config file — `~/.claude/settings.json` —
also holds the model, theme, permissions and everything else about the machine,
none of which this repo should own.

So `install.sh` does both halves:

1. symlinks `hooks/*.sh` into `~/.claude/hooks/`, so edits here are live
   immediately, same as a skill;
2. merges one entry per policy into `~/.claude/settings.json`, keyed on the
   command string, leaving every other key untouched.

Re-running is a no-op. The pre-merge file is kept as
`settings.json.ysforge.bak`. Registration needs `jq`; without it `install.sh`
says so loudly and exits non-zero rather than skipping the policy in silence.

## Harness support

| | Claude Code | Codex | pi |
|---|---|---|---|
| Hook config | `settings.json` `hooks` | not supported | not verified |
| Pre-tool event | `PreToolUse` | — | — |
| Deny a call | `permissionDecision: "deny"` | — | — |

Hooks are **the least portable thing in this repo** — further from portable
than agents. There is no vendor-neutral hook format and no `~/.agents`
equivalent, so `install.sh` wires Claude Code only. The scripts stay generic
where it is free (stdin JSON in, JSON out, no harness vocabulary in the logic)
so that a second harness needs a new wire-up, not a rewrite.

## The policies

### `no-nested-agents.sh` — maximum agent depth of one

```
main session (orchestrator)  ->  may spawn subagents
  subagent (worker)          ->  may not spawn anything
```

Registered on `PreToolUse` with matcher `Agent|Task`. It denies the call when
the payload carries an `agent_id`, which the harness sets only when the tool
call originates inside a subagent; the main session's payload has no such key.
Anything else exits 0 silently and leaves the decision alone.

Why: fan-out is a cost and control decision, and it belongs to the session a
human is actually watching. A worker that spawns workers turns one delegated
task into a tree nobody sized.

Verify it end to end by asking a subagent to spawn one:

> Call the Agent tool once with subagent_type "Explore" and prompt "Reply OK".
> Do not retry. Report the verbatim result or denial.

The subagent should come back denied, while the main session keeps spawning
normally. Testing the script alone is weaker but faster:

```bash
echo '{"agent_id":"x","tool_name":"Agent"}' | bash hooks/no-nested-agents.sh   # deny JSON
echo '{"tool_name":"Agent"}'                | bash hooks/no-nested-agents.sh   # nothing
```

Claude Code also needs to notice the config change: it re-reads settings.json
on its own, but a session that had no settings file when it started may need
`/hooks` opened once, or a restart.

## Adding a policy

1. `cp hooks/no-nested-agents.sh hooks/my-policy.sh` and rewrite the body.
   Read stdin, print a decision or nothing, **always exit 0** — a non-zero exit
   means something different to the harness than "allow".
2. Pipe-test both branches by hand before wiring it. A hook that silently does
   nothing is worse than no hook.
3. Add a `register_claude_hook` call in `scripts/install.sh` next to the
   existing one, and document the policy in the section above.
4. `./scripts/install.sh`

Keep each script to one policy, and keep the deny message actionable — it is
addressed to a model that will otherwise try the same call again.

## Removing a policy

Delete the entry from `~/.claude/settings.json` and the symlink from
`~/.claude/hooks/`. `install.sh` re-adds it on the next run, so drop the script
from `hooks/` (or its `register_claude_hook` line) if the removal is meant to
stick.
