---
title: "Technology Readiness Level (TRL)"
type: concept
tags: [trl, technology-assessment, nasa]
sources: [nasa-systems-engineering-handbook-0-excerpt-trl]
last_updated: 2026-11-10
---

# Technology Readiness Level (TRL)

A scale against which to measure the maturity of a technology, from 1 (basic technology research) to 9 (systems test, launch and operations). At its most basic, a TRL describes the performance history of a system, subsystem or component relative to a set of levels first described at [[NASA]] HQ in the 1980s. It is the baseline from which maturity is gauged and advancement defined. Source: [[nasa-systems-engineering-handbook-0-excerpt-trl]] (Glossary; §G.4).

## The nine levels (Figure G.4-1)

| TRL | Description |
|---|---|
| 1 | Basic principles observed and reported |
| 2 | Technology concept and/or application formulated |
| 3 | Analytical and experimental critical function and/or characteristic proof-of-concept |
| 4 | Component and/or breadboard validation in laboratory environment |
| 5 | Component and/or breadboard validation in relevant environment |
| 6 | System/subsystem model or prototype demonstration in a relevant environment (ground or space) |
| 7 | System prototype demonstration in a target/space environment |
| 8 | Actual system completed and "flight qualified" through test and demonstration (ground or flight) |
| 9 | Actual system "flight proven" through successful mission operations |

Figure G.4-1 groups the levels into overlapping bands, bottom to top: basic technology research, research to prove feasibility, technology development, technology demonstration, system/subsystem development, system test, launch and operations. The text gives no exact boundaries for the bands.

## The TRL 6 threshold

Typically a TRL of 6 (technology demonstrated in a relevant environment) is required for a technology to be integrated into an SE process (Glossary). Consistently, [[KeyDecisionPoint]] C requires evidence that every system, subsystem and component has been qualified in a relevant environment.

## How a TRL is assigned

- Through a [[TechnologyMaturityAssessment]]: a fixed sequence of yes/no questions (Figure G.4-2), usually recorded in a TRL assessment matrix (Figure G.4-3).
- **Lowest-TRL rule:** the TRL of a system is determined by the lowest TRL present in it; a system is at TRL 2 if any single element in it is at TRL 2. Subsystems take the lowest TRL of their components, systems the lowest TRL of their subsystems — in both cases also considering the TRL state of integration (Figure G.3-1).
- **Integration:** all elements can be at a higher TRL, but if they have never been integrated as a unit, the unit's TRL is lower. How much lower depends on the complexity of the integration, judged by a cross-section of senior engineers.
- **Heritage:** a heritage system (see [[HeritageSystems]]) used in a different architecture or environment drops initially to TRL 5.
- Assessment runs on the [[ProductBreakdownStructure]], from system level down to components.

## Pitfalls named by the source

- Terminology: words like "breadboard" or "relevant environment" mean different things in different disciplines; define them consistently for the whole program/project before assessing.
- Judgment calls: deciding whether something is "close enough" to a prototype requires describing it in terms of form, fit and function.
- A frequent misconception is that TRLs are too hard to determine or meaningless; the source argues that identifying TRLs is a straightforward process of determining what was demonstrated and under what conditions.
- Software TRL definitions are in NPR 7123.1, not in this appendix.

## Related
- [[TechnologyAssessment]] — TRLs are the first half (TMA) of a TA
- [[AdvancementDegreeOfDifficulty]] — what it takes to move from one TRL to the next
- [[ProjectLifeCycle]] — phases in which TRL is assessed
