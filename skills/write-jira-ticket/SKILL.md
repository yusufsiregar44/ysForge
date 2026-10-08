---
name: write-jira-ticket
description: Use when creating or drafting a JIRA ticket - a story/task (Context, Acceptance Criteria, Out of Scope) or a bug report (Precondition, Steps to Reproduce, Expected Result, Current Result). Triggers on writing a ticket description, turning a Slack thread or call into a ticket, or reproducing and filing a defect.
---

# Write JIRA Ticket

## Overview

Tickets follow one of two shapes, by issue type.

**Story / Task / Improvement:** Context states the problem as a Jobs-to-be-Done statement, with a source only when one is confirmed. Acceptance Criteria states testable outcomes. Out of Scope names what the ticket excludes.

**Bug:** Precondition states the setup needed to hit it. Steps to Reproduce is a numbered path to the failure. Expected Result states what should happen. Current Result states what actually happens, with exact error text.

Prose throughout is smart-brevity: short sentences, no filler, conclusion first.

## When to use

- Drafting a new Story, Task, Improvement, or Bug ticket from a Slack thread, a call, a QA session, or a raw idea.
- Rewriting a rough draft ticket into either house shape.
- Pick the shape by issue type, not by content: a Bug always uses Precondition / Steps / Expected / Current, never Out of Scope.

## Story tickets

### Title

`[Area1][Area2] - <Summary>` when the ticket belongs to one or two disciplines or teams: `FE`, `BE`, `Mobile`, `Infra`, or a service/system name. Drop the tags for a cross-cutting or discovery-stage story that will later fan out into its own tagged subtasks.

Example: `[FE][BE] - Notify users when a scheduled job fails`. An untagged discovery story can later fan out into several tagged implementation subtasks.

### Context

Lead with one Jobs-to-be-Done sentence: `When <situation>, <persona> wants to <action>, so that <outcome>.` This states the problem as a need, not as a proposed fix. Add 1-2 more sentences only if the situation needs more detail.

Add a source line only when the source is confirmed and relevant: a Slack thread link with date and names, a named customer, or a dated call, and you can stand behind it as accurate. Skip it when the origin is secondhand, paraphrased, or unverified. A wrong attribution is worse than none.

```
**Context**

When the results list grows past a few dozen items, a user wants to find a
specific item quickly, so that they do not have to scroll the whole list.

Source: Slack thread <link> (Action items, call of <date>, <names>).
```

If a customer drove the ticket, name them and the business impact in one line before the source link.

### Acceptance Criteria

Numbered list of observable outcomes a tester can check true or false against a running system. Not implementation steps. Give a criterion lettered sub-points only when it has distinct supporting cases that belong under it.

```
1. A job that completes successfully sends no alert.
2. A job that fails sends exactly one alert.
   a. The alert names the job and the failure reason.
   b. The alert reaches every assigned recipient.
```

Good: "A job that completes successfully sends no alert." (outcome, testable)
Bad: "Add a check for job status." (describes code, not behavior)

See List formatting below before nesting. When a design link exists (Figma, etc.), it is criterion 1: `1. Follow design >> <link>`.

### Out of Scope

Numbered list naming the specific adjacent thing this ticket will not cover. Add the reason as a lettered sub-point when it is not obvious: usually lower priority, a separate ticket, or blocked on something else. Cite the other ticket by ID and name when one exists.

```
**Out of scope** (separate backlog stories, lower priority)
1. Advanced filtering on the results list (TICKET-456).
2. Bulk tagging across items (TICKET-457).
```

When the exclusion is a clean in/out split of one capability, use a **Scope boundary** line instead: `In: X. Out: Y (TICKET-NNN) - Z (TICKET-MMM).`

## Bug tickets

### Title

`[Environment][Area][Component] - Summary`. Environment is where it was found: `Staging`, `Prod`, or your org's environment names. Example: `[Staging][Settings][Dropdown] - Status control shown as "not supported" for a valid option`.

### Precondition

One or two lines: the state the system or user must already be in before the steps start. Logged-in state, permission state, data setup, which screen or record.

`Precondition: Notification permission for the app is set to "Never allow"; user has an active session with the panel open.`

### Steps to Reproduce

Numbered list, written as actions, not observations. Each step is one click or one input, not a paragraph. Give a step lettered sub-points only for distinct variants to try under that same step.

```
1. Open the settings panel.
2. Select a status from the dropdown.
   a. With a valid option selected, the control enables.
   b. With no option selected, the control stays disabled.
```

See List formatting below before nesting.

### Expected Result

What should happen, stated as behavior. If this traces back to an existing Acceptance Criterion, cite it: `TICKET-123 AC4: "A state with no valid options shows no control."`

### Current Result

What actually happens. Quote the exact error text or stack trace verbatim in a code block, not paraphrased. Add request IDs, record IDs, or job IDs when the bug is backend- or API-facing — they are what engineering greps logs for.

```
**Current Result**

The request fails with HTTP 500. Logs show an unhandled upstream error:

  {"error": "... request_id=...", "code": "INTERNAL_SERVER_ERROR"}
```

No Out of Scope on a bug. The defect's boundary is the Precondition and Steps, not an exclusion list.

## List formatting

Use a numbered list for the main points, with lettered sub-points (`a.`, `b.`) indented under a point that has distinct supporting detail. Keep nesting to one level.

If you create or edit tickets with jira-cli, its markdown-to-ADF conversion has been seen to mangle nested ordered lists, especially on `jira issue edit --no-input -b`, turning them into literal, unformatted text. After creating or editing a ticket with sub-points, open it and confirm they rendered as a list. If they did not, flatten: fold the sub-point into its parent line instead of a separate indented entry.

## Smart brevity, applied

- One idea per sentence. Cut "basically", "simply", "in order to".
- Lead with the conclusion: "Users cannot find what they need." not "As users browse the results, they may find it difficult to locate what they are looking for."
- Bold the section labels. No other formatting flourish.
- A story body under 150 words is normal; length comes from Acceptance Criteria points. A bug's Current Result can run longer when it quotes an error verbatim.

## Quick reference

| Story section | Content | Length |
|---|---|---|
| Context | When/persona/want/so-that; source only if proven | 1-3 sentences |
| Acceptance Criteria | Testable outcomes | 3-8 points |
| Out of Scope | Explicit exclusions + reason or ticket ID | 1-4 points |

| Bug section | Content | Length |
|---|---|---|
| Precondition | Setup/state needed to hit it | 1-2 lines |
| Steps to Reproduce | Numbered actions | 2-6 steps |
| Expected Result | What should happen | 1-3 lines |
| Current Result | What actually happens, verbatim error | 1 line to a short code block |

## Common mistakes

- Writing Context as a loose narrative instead of the When/persona/want/so-that shape.
- Citing a source that is paraphrased, secondhand, or unverified just to fill the line. An unproven attribution is worse than none.
- Writing Acceptance Criteria as tasks ("implement X") instead of outcomes ("X happens when Y").
- Using bullets instead of numbered lists for Acceptance Criteria, Out of Scope, or Steps to Reproduce.
- Nesting more than one level, or not verifying that sub-points rendered correctly (see List formatting above).
- Adding Out of Scope to a bug, or Precondition/Steps to a story. The two shapes do not mix.
- Paraphrasing an error message instead of quoting it verbatim in Current Result.
