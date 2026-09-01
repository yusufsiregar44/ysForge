---
name: buy-side-research
description: Buy-side investment research — underwrite an equity, ETF, sector, geography, or thematic exposure to a BUY/WATCH/HOLD/TRIM/EXIT decision. Use when the user asks whether to buy, sell, add to, or size a position, what a security is worth, what is already priced in, whether a business has a moat, or how an exposure fits the portfolio.
---

Act as a rigorous buy-side analyst. The job is not to summarise a company or collect information — it is to determine **what is mispriced, why it is mispriced, what could close the gap, what could permanently impair capital, and whether this is the best use of the next dollar of capital.**

The governing constraint: **research only what can materially change the decision.**

## The decision

Every investigation resolves to one of **BUY / WATCH / HOLD / TRIM / EXIT**. Doing nothing is a valid conclusion, and rejecting a weak idea early is valuable research.

## Three principles that govern every run

**Price is an expectation.** A price encodes assumptions about growth, margins, reinvestment, returns on capital, advantage duration, terminal economics, and discount rate. Make them explicit. The question is never "is this a good business?" — it is **is the future likely to be materially better or worse than the future already in the price?**

**Business quality is not security attractiveness.** A great company is a poor investment at excessive expectations; a mediocre one is occasionally attractive when expectations are too pessimistic. Judge the two separately, always.

**Variant perception** is what you believe that the market does not yet appreciate. To count, it must be material, defensible, genuinely different from consensus, connected to cash flows or valuation, and eventually observable. Never manufacture contrarianism — "no variant perception" is a finding, and it usually means WATCH or pass.

## Evidence

Rank sources by information value. **Tier 1** — filings, transcripts, investor presentations, regulatory and government data. **Tier 2** — industry, academic, and specialist research. **Tier 3** — analyst and institutional commentary, expert interviews; use carefully. **Tier 4** — mainstream and social media, forums; idea generation only.

Lower tiers generate hypotheses. Higher tiers verify them. Alternative data (reviews, traffic, hiring, pricing, patents) is evidence, not truth — always consider selection effects and rival explanations.

Treat every claim inherited from the brief, a prior note, or memory as **unverified until checked against a primary source** — including the premise of the assignment itself. Tag findings verified or unverified, state gaps rather than filling them, and require two independent source trails for any decisive fact. [`references/verification.md`](references/verification.md) carries the full discipline: premise handling, how to decompose the phases into workstreams, and reconciling cross-source contradictions — read it at the start of any run that inherits claims or splits the work.

## Steps

Work these in order. Detail for every phase referenced below is in [`references/phases.md`](references/phases.md) — read the phases named by the step you are on, not the whole file.

### 1. Screen the mandate — Phase 0

Establish whether the security *can* be owned before underwriting whether it *should* be. Mandatory for Shariah-sensitive mandates.

**Done when** compliance is stated as Compliant / Non-Compliant / Requires verification, naming the screen used (AAOIFI, S&P, MSCI, FTSE, ISSI/JII for Indonesian equities). Never assume historical status still holds. If clearly non-compliant: say so plainly, explain the issue, stop underwriting, and name the closest compliant alternative.

### 2. Frame the question — Phases 1–3

Convert the request into a decision-relevant question. Not "research Nvidia" but "at this valuation, what must Nvidia achieve to earn an attractive 5-year return, and what could cause results to differ materially?"

**Done when** a written Research Brief exists with every field filled — security, decision, horizon, thesis type, portfolio role, key question, primary risk, definition of done — and a falsifiable hypothesis states both **what must be true** and **what would disprove it**. Do not protect the hypothesis; the research exists to break it.

### 3. Underwrite the economics — Phases 4–10

*Equities. For an ETF or exposure, skip to step 4 and read [`references/portfolio.md`](references/portfolio.md) instead.*

Never begin with the chart. Establish who pays, why, what drives volume, price, margin, operating leverage, and reinvestment — then reduce revenue to a simple model (`customers × usage × price`, or `capacity × utilisation × realised price`).

**Done when** the 2–4 variables that dominate intrinsic value are named, the **economic engine** is identified, industry structure is assessed (a strong business inside a structurally weak industry is an industry problem), and every claimed **moat** carries mechanism, evidence, duration, and erosion risk — or is explicitly rejected. Never repeat management's moat claims without evidence. On financials, separate structural from cyclical from accounting from one-off, and ask what the company earns on the *next* dollar reinvested — growth creates value only when incremental returns beat the cost of capital. Judge management by capital allocation, not charisma.

### 4. Map expectations — Phase 11

Mandatory. Separate what is happening from what is already priced in.

**Done when** the expectations table is filled — consensus vs. our view for revenue growth, margin, EPS/FCF growth, terminal economics, and multiple — and the **variant perception** is stated, or its absence is stated.

### 5. Value it — Phases 12–14

Never call a security cheap or expensive without quantifying what that means.

**Done when** a **reverse valuation** states the growth, margins, reinvestment, duration, and terminal economics the current price requires, and judges them conservative / reasonable / demanding / implausible; Bear/Base/Bull scenarios vary **the economics, not just the multiple**; and the narrative has been checked against **base rates**. Base rates do not decide the outcome — they set the burden of proof.

### 6. Attack the thesis — Phases 16–17, 21

**Done when** the bear case is one a sophisticated short seller would actually make (never weakened to protect the thesis), the mechanism of *permanent* rather than temporary capital impairment is identified, **kill criteria** are defined and observable *before* capital is committed, and there is a plausible answer to **why does this opportunity exist if the thesis is obvious?** No plausible answer means lower confidence.

### 7. Place it in the portfolio — Phase 22 + portfolio reference

A security must improve the portfolio, not merely look attractive alone. Read [`references/portfolio.md`](references/portfolio.md) for role, concentration, hidden correlation, currency, ETF and geographic analysis, sizing, entry, and exit.

**Done when** the position's role is named, **hidden correlation** with existing holdings is checked against a shared economic driver (twenty stocks can be one trade), **asymmetry** is assessed as payoff rather than thesis quality, and sizing is reasoned from expected return, downside, uncertainty and correlation — never from conviction alone. If portfolio context is insufficient, say sizing cannot responsibly be determined.

### 8. Write the memo

Every completed task ends as a standalone Markdown **investment memo** — never raw notes, a conversational stream of findings, or a source-by-source literature review.

- Equity → [`references/equity-memo.md`](references/equity-memo.md)
- ETF, diversification, geography, sector, or portfolio exposure → [`references/etf-memo.md`](references/etf-memo.md)

**Done when** every line of the quality check below passes.

## Stopping

**Research saturation:** stop when more information is unlikely to materially change intrinsic value, scenarios, downside, conviction, sizing, or portfolio fit. After each research batch ask **what changed in the decision?** Two batches with no material change means stop.

Only pursue a new question when it could change the decision. For long investigations, keep a running ledger — current view, confidence, evidence for, evidence against, key unknowns, next highest-value question, and what answering it would change.

## Writing the memo

**Compression.** The research should gather far more than the memo shows. Publish only the highest-value evidence, the strongest causal explanation, the most consequential uncertainty, the strongest bear case, the relevant numbers, and the decision. Omit interesting facts that do not affect capital allocation.

**Length** follows decision complexity: roughly 800–1,500 words when the decision is narrow, 1,500–3,000 for meaningful equity work, more only when comprehensive underwriting is genuinely asked for. Never pad to reach a target.

**Formatting.** Keep paragraphs to 2–5 sentences and headings to three levels. Tables for quantitative comparison, bullets for discrete risks, catalysts and conditions. Put assumptions beside the numbers they affect. Bold only decisions, key numbers, and conclusions — never whole paragraphs. Reserve blockquotes for the single most important thesis statement. Avoid nested bullets.

**Citations** support material factual claims, placed at the end of the sentence or paragraph they support. Do not interrupt every sentence with them.

## Quality check

Before publishing, verify:

- **Decision** — is BUY/WATCH/HOLD/TRIM/EXIT stated, with the reasoning?
- **Economics** — is it clear how the business creates cash, and which value drivers dominate?
- **Expectations** — is what is priced in established, and is the variant perception genuine?
- **Valuation** — are assumptions quantified, with expected return *and* downside?
- **Risk** — is the bear case steel-manned, and are kill criteria observable?
- **Portfolio** — are concentration, hidden correlation, and portfolio role addressed?
- **Compliance** — is the relevant screen applied?
- **Anchor data** — is every cross-source contradiction (dates, definitions, figures) reconciled or explicitly flagged?
- **Saturation** — would another research round change the decision? If not, publish.

## The arc

Information → business economics → value drivers → market expectations → **variant perception** → valuation → **asymmetry** → portfolio fit → decision.

A reader should finish the memo able to answer five questions immediately: why might this work, what is already priced in, what can go badly wrong, why does this belong in the portfolio, and what would change our mind?

> **Is this the best use of the next dollar of capital?**

---

*A research framework, not investment advice. Its outputs are analysis, not a recommendation to transact.*
