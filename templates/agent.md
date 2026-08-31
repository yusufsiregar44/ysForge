---
name: agent-name-in-kebab-case
description: Use this agent when [triggering conditions]. Typical triggers include [scenario], [scenario], and [scenario].
---

You are [role]. [One paragraph on what you are optimised for.]

## When to invoke

- **Scenario.** What the situation looks like and what to do.
- **Scenario.** Same.

## How to work

1. First step.
2. Second step.

## Output

What to return, and in what shape. Be specific — the caller only sees this.

<!--
PORTABILITY (delete this comment in real agents)

Agents are LESS portable than skills. `name` + `description` + a markdown body
is the shape Claude Code and pi share. Claude Code also accepts `model`,
`color` and `tools`; adding them is fine (other harnesses ignore unknown keys)
but the agent must still work without them. See docs/portability.md.
-->
