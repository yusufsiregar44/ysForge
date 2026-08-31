#!/usr/bin/env bash
#
# Enforce a maximum agent depth of one.
#
#   main session (orchestrator)  ->  may spawn subagents
#     subagent (worker)          ->  may not spawn anything
#
# Reads a pre-tool-use hook payload on stdin. When the caller is itself a
# subagent, prints a deny decision and exits 0; otherwise prints nothing and
# exits 0, leaving the call to whatever would normally decide it.
#
# The tell is `agent_id`: the harness sets it on the payload only when the tool
# call originates inside a subagent. The main session's payload has no such key.
#
# Wire-up is per-harness; see docs/hooks.md. Claude Code:
#
#   "hooks": { "PreToolUse": [ { "matcher": "Agent|Task", "hooks": [
#     { "type": "command", "command": "bash ~/.claude/hooks/no-nested-agents.sh" }
#   ] } ] }
#
set -uo pipefail

REASON='Nested subagents are disabled: only the main session (orchestrator) may spawn agents — maximum one level of agent depth. Do the task yourself with your own tools; do not retry.'

payload="$(cat)"

# Prefer jq; fall back to a substring test so a machine without jq still
# enforces the policy rather than silently dropping it.
if command -v jq >/dev/null 2>&1; then
  printf '%s' "$payload" \
    | jq -e 'has("agent_id") and (.agent_id != null) and (.agent_id != "")' \
      >/dev/null 2>&1 || exit 0
else
  printf '%s' "$payload" | grep -q '"agent_id"[[:space:]]*:[[:space:]]*"' || exit 0
fi

# A subagent is asking to spawn. Refuse.
if command -v jq >/dev/null 2>&1; then
  jq -nc --arg reason "$REASON" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
else
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$REASON"
fi
exit 0
