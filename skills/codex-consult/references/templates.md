# Consultation prompt templates

Fill one of these in and write it to a temporary file for
[`../scripts/consult.sh`](../scripts/consult.sh). Every prompt must be
self-contained — Codex has no memory of the conversation — and must identify
the drafting model by name. Keep the closing stdout instruction: it is what
prevents Codex from trying (and failing, in read-only) to write a file.

If the user names a template, use that one verbatim; raise a mismatch rather
than silently swapping.

---

## Template A — Architectural review

```
You are being consulted as an architectural peer reviewer. A software
architect (<your model name>) has analyzed the following challenge and formed
recommendations. Please provide an independent consultation report.

ARCHITECTURAL CHALLENGE:
<summarize the request and the codebase context>

PRELIMINARY ANALYSIS:
<summarize your own architectural findings and recommendations>

Please provide your consultation report covering:
1. AGREEMENT/DISAGREEMENT: Where do you agree or disagree with the preliminary analysis?
2. BLIND SPOTS: What considerations might have been missed?
3. ALTERNATIVE APPROACHES: Any viable alternatives not yet considered?
4. RISK ASSESSMENT: What are the key risks of the proposed approach?
5. RECOMMENDATION: Your independent architectural recommendation.

Format as a structured consultation report in markdown.

IMPORTANT: Output your FULL detailed response directly to stdout. Do NOT write
your response to any file. Print the entire consultation report directly as
your output.
```

## Template B — Test-plan review

```
You are being consulted as a QA peer reviewer. A quality assurance engineer
(<your model name>) has investigated the following system and drafted test
cases. Please provide an independent consultation report reviewing the test
plan for completeness.

SYSTEM/FEATURE UNDER TEST:
<describe the system, file paths, relevant code snippets, architecture context>

ISSUE/BUG BEING INVESTIGATED (if applicable):
<describe bug, symptoms, reproduction steps>

DRAFTED TEST CASES:
<list all drafted test cases with rationale>

API ENDPOINTS/PAYLOADS INVOLVED (if applicable):
<list endpoints, example payloads, expected responses>

Please provide your consultation report covering:
1. COVERAGE ASSESSMENT: Are the proposed test cases comprehensive? Rate overall coverage (Low/Medium/High).
2. MISSING TEST CASES: Identify gaps — missing edge cases, boundary conditions, error scenarios, race conditions, security concerns.
3. SUGGESTED ADDITIONS: For each gap, propose a specific test case with rationale.
4. REDUNDANCY CHECK: Flag any test cases that are redundant or low-value and can be removed.
5. PRIORITY RANKING: Rank the combined test cases (original + suggested) by importance.

Format as a structured consultation report in markdown.

IMPORTANT: Output your FULL detailed response directly to stdout. Do NOT write
your response to any file. Print the entire consultation report directly as
your output.
```

## Template C — Ad-hoc peer review

```
You are being consulted as a peer reviewer on <TOPIC>. <DESCRIPTION OF MY
ROLE> (<your model name>) has drafted the following
<ANALYSIS/RECOMMENDATION/PLAN>.

CONTEXT:
<self-contained context — the reviewer has no memory of this conversation>

DRAFT:
<your draft, including any specific claims to be validated>

QUESTIONS TO ANSWER:
1. <specific question 1>
2. <specific question 2>
3. <specific question 3>

Format as a structured markdown consultation report.

IMPORTANT: Output your FULL detailed response directly to stdout. Do NOT write
your response to any file. Print the entire consultation report directly as
your output.
```
