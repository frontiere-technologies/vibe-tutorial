---
title: "NASA Systems Engineering Handbook (SP-2016-6105 Rev2) — TRL excerpt"
type: source
tags: [nasa, systems-engineering, trl, technology-assessment]
date: 2026-11-10
source_file: docs/second-brain/raw/examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf
---

## Summary
A 15-page excerpt of the [[NASASystemsEngineeringHandbook]] (NASA/SP-2016-6105 Rev2, which supersedes Rev 1 of December 2007), chosen for its material on [[TechnologyReadinessLevel]]s. It holds the cover and imprint, the Preface, §1.0 Introduction, Table 2.2-1 (project life-cycle phases), the glossary entries for Technology Maturity Assessment and Technology Readiness Level, and Appendix G §G.1–G.4 (*Technology Assessment/Insertion*) up to Figure G.4-3. Its core is the nine-level TRL scale, a question-driven process for assigning a TRL, and how TRLs feed the [[TechnologyAssessment]] products required at each [[KeyDecisionPoint]].

Page numbers below are the handbook's own (viii, 1–2, 9, 195, 206–213); PDF page numbers of the full handbook are 10 higher. The excerpt stops at Figure G.4-3: anything after it in Appendix G (e.g. the detailed AD² method) is not covered.

## Key Claims
- The handbook gives top-level guidance for good systems engineering practice and "is not intended in any way to be a directive"; it is a companion to NPR 7123.1, *Systems Engineering Processes and Requirements* (Preface, §1.1).
- It applies to NASA space flight projects of all sizes and to research and development programs; all 17 SE processes apply to every project, with formality, depth of documentation and timescales scaled to the project's type, size and complexity (§1.2). See [[SystemsEngineering]].
- The [[ProjectLifeCycle]] runs Pre-Phase A (Pre-Formulation), Phases A–B (Formulation), Phases C–F (Implementation) (Table 2.2-1, p. 9).
- TRLs range from 1 (basic technology research) to 9 (systems test, launch and operations); typically a TRL of 6 — technology demonstrated in a relevant environment — is required for a technology to be integrated into an SE process (Glossary, p. 195).
- A [[TechnologyAssessment]] has two parts: a [[TechnologyMaturityAssessment]] (TMA), which sets the current TRL, and an [[AdvancementDegreeOfDifficulty]] (AD²) assessment of what it takes to raise it (§G.1, §G.3).
- TAs are conducted at several stages to provide the products needed at each [[KeyDecisionPoint]]; KDP C requires a Technology Readiness Assessment Report (TRAR) showing that all systems, subsystems and components have demonstrated evidence of qualification in a relevant environment (Table G.1-1).
- The final TMA is performed just before the Preliminary Design Review (PDR) and is the basis of the TRAR (§G.1).
- The TA must be defined at the beginning of the program/project and performed from the earliest stage (concept development) through PDR (§G.2).
- The TMA is performed against the [[ProductBreakdownStructure]] (PBS), at system, subsystem and component level (§G.1, §G.3).
- A subsystem's TRL is based on the lowest TRL of its components and the TRL state of integration; a system's on the lowest TRL of its subsystems and the state of integration (Figure G.3-1, §G.4).
- Integration lowers the TRL: elements that have never been integrated as a unit give the unit a lower TRL, by an amount that depends on the complexity of the integration and is a matter of judgment (§G.4).
- [[HeritageSystems]] reused in a different architecture or environment initially drop to TRL 5; after analysis they may reach TRL 6 or 7, but are no longer TRL 9 (§G.4).
- A uniform TRL assessment needs consistent terminology, a way of quantifying judgment calls (form, fit and function) and a balanced, experienced assessment team (§G.4).
- Schedule slips and cost overruns are often blamed on inadequate requirements, but a dominant factor is the lack of understanding of the maturity of the required technology (§G.1).
- Appendix G is interim guidance: a NASA TRA Handbook (in work) will replace it; questions on TRL/TRA go to [[StevenHirshorn]] at NASA HQ (§G.1).
- Software TRL definitions are in NPR 7123.1 (§G.4).

## Key Quotes
> "It is impossible to understand the magnitude and scope of a development program without having a clear understanding of the baseline technological maturity of all elements of the system." — §G.4, p. 210

> "Typically, a TRL of 6 (i.e., technology demonstrated in a relevant environment) is required for a technology to be integrated into an SE process." — Glossary, p. 195

> "... the most important thing to realize is that it is no longer at TRL 9." — §G.4, Heritage Systems, p. 212

## Connections
- [[NASA]] — publisher; TRLs were first described at NASA HQ in the 1980s
- [[NASASystemsEngineeringHandbook]] — the document this excerpt comes from
- [[OfficeOfTheChiefEngineer]] — sponsor of the handbook update and of the 2014 TRL/TRA study
- [[StevenHirshorn]] — contact for comments on the handbook and for TRL/TRA questions
- [[TechnologyReadinessLevel]] — the nine-level scale and the rules for assigning it
- [[TechnologyMaturityAssessment]] — the TMA thought process (Figure G.4-2) and assessment matrix (Figure G.4-3)
- [[TechnologyAssessment]] — TMA + AD², its inputs and products
- [[AdvancementDegreeOfDifficulty]] — the second half of a TA
- [[KeyDecisionPoint]] — TA products required at KDP A, B and C
- [[ProjectLifeCycle]] — phases the KDPs sit between
- [[ProductBreakdownStructure]] — the framework the assessment runs on
- [[HeritageSystems]] — how reuse in a new context affects TRL
- [[SystemsEngineering]] — the discipline and its 17 processes

## Contradictions
- None with existing wiki content (first source ingested).
- Inside the source: §G.1 says "Technical Readiness Level" while the glossary and the rest of Appendix G say "Technology Readiness Level"; they are the same concept.
- Inside the source: Figure G.4-2 asks the heritage question (→ TRL 5) before the "flight qualified" question (→ TRL 8), so the flowchart is not in strictly descending TRL order. See [[TechnologyMaturityAssessment]].
- Inside the source: the phase brackets of Figure G.4-1 (basic technology research, technology development, …) overlap and their exact TRL boundaries are not stated in the text.
