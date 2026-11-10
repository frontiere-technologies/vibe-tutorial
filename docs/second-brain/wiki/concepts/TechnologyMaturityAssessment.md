---
title: "Technology Maturity Assessment (TMA)"
type: concept
tags: [trl, technology-assessment, process]
sources: [nasa-systems-engineering-handbook-0-excerpt-trl]
last_updated: 2026-11-10
---

# Technology Maturity Assessment (TMA)

A process to determine a system's technological maturity based on [[TechnologyReadinessLevel]]s (Glossary). It is the first part of a [[TechnologyAssessment]]; the second is the [[AdvancementDegreeOfDifficulty]] (AD²) assessment. Source: [[nasa-systems-engineering-handbook-0-excerpt-trl]] (§G.1, §G.4).

- The initial TMA sets the baseline maturity of the required technologies at program/project outset and allows monitoring progress.
- The final TMA is performed just before the Preliminary Design Review (PDR) and is the basis of the Technology Readiness Assessment Report (TRAR).
- It is performed against the hierarchical [[ProductBreakdownStructure]], at system, subsystem and component level.

## Three prerequisites (§G.4)
1. **Terminology** — one consistent set of definitions (breadboard, relevant environment, …) for the whole program/project.
2. **Judgment calls** — quantified on past experience, describing each element by form, fit and function.
3. **Assessment team** — balanced and experienced; members need not be discipline experts, but must understand the current state of the art in applications. Human factors (HFE) personnel evaluate user considerations.

## TMA thought process (Figure G.4-2)

Ask the questions in this order; the first "yes" gives the TRL.

| # | Question | Yes → |
|---|---|---|
| 1 | Has an identical unit been successfully operated/launched in identical configuration/environment? | TRL 9 |
| 2 | Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched? | TRL 5 (initially, until differences are evaluated) |
| 3 | Has an identical unit been flight qualified but not yet operated in space or the target environment or launched? | TRL 8 |
| 4 | Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched? | TRL 7 |
| 5 | Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment? | TRL 6 |
| 6 | Has a breadboard unit been demonstrated in a relevant environment? | TRL 5 |
| 7 | Has a breadboard unit been demonstrated in a laboratory environment? | TRL 4 |
| 8 | Has analytical and experimental proof-of-concept been demonstrated? | TRL 3 |
| 9 | Has concept or application been formulated? | TRL 2 |
| 10 | Have basic principles been observed and reported? | TRL 1 |
| — | No to all | "Rethink position regarding this technology!" |

Question 2 is the [[HeritageSystems]] case. Because it comes before question 3, the flowchart is not in strictly descending TRL order: a heritage unit is caught at TRL 5 before the flight-qualified question is asked.

## TRL assessment matrix (Figure G.4-3)

A table with one row per system, subsystem and component under assessment, and columns recording what has been demonstrated (an "X" where it exists):

- **Demonstration units:** concept, breadboard, brassboard, developmental model, prototype, flight qualified
- **Environment:** laboratory, relevant, space, space launch operation
- **Unit description:** form, fit, function, appropriate scale
- **Overall TRL**, colour-coded: red = below TRL 3, yellow = TRL 3–5, green = TRL 6 and above, white = unknown

The system's TRL is the lowest TRL present in it (see [[TechnologyReadinessLevel]]). Elements at low TRLs are then handled by the AD² process.
