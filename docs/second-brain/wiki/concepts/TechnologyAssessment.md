---
title: "Technology Assessment (TA)"
type: concept
tags: [technology-assessment, process, nasa]
sources: [nasa-systems-engineering-handbook-0-excerpt-trl]
last_updated: 2026-11-10
---

# Technology Assessment (TA)

A systematic process for understanding the technology a program/project needs, described in Appendix G of the [[NASASystemsEngineeringHandbook]] as an example of applying standard systems engineering practice. Source: [[nasa-systems-engineering-handbook-0-excerpt-trl]] (§G.1–G.3).

## Why
New technology — or [[HeritageSystems]] adapted to a new architecture or environment — often causes schedule slips, cost overruns, cancellations or failures. Post-mortems tend to blame "inadequate definition of requirements", but a dominant factor is the lack of understanding of technology maturity and of the cost and schedule reserves needed to advance it. Early, good systems engineering focused on technology requirements, maturity and needed advancement reduces this uncertainty.

## Two parts
1. [[TechnologyMaturityAssessment]] (TMA) — current maturity, as [[TechnologyReadinessLevel]]s.
2. [[AdvancementDegreeOfDifficulty]] (AD²) — the difficulty of moving a technology from one TRL to the next.

## Process (Figure G.3-1)
1. Identify systems, subsystems and components per the hierarchical product breakdown of the WBS (see [[ProductBreakdownStructure]]).
2. Assign a TRL to all components based on assessment of maturity.
3. Assign TRLs to subsystems from the lowest TRL of their components and the TRL state of integration.
4. Assign TRLs to systems from the lowest TRL of their subsystems and the TRL state of integration.
5. Identify all elements at lower TRLs than the program requires → baseline technology maturity assessment.
6. Perform AD² on all elements below the requisite maturity level → Technology Development Plan, cost plan, schedule plan, risk assessment.

The process is iterative: at the conceptual level during Formulation it identifies critical technologies and preliminary cost, schedule and risk mitigation plans; in Phase A it establishes the baseline maturity, the Technology Development Plan and associated costs and schedule. The final TA consists only of the TMA and is used to develop the Technology Readiness Assessment Report (TRAR), which validates that all elements are at the requisite maturity. Even at concept level the PBS formalism is used so that no important technology slips through the cracks.

TA and architectural studies are interwoven (Figure G.3-2): requirements → concepts → architectural studies → system design, all exchanging information with the TRL/AD² assessment and technology maturation. Maturation should flag infeasible requirements and unfruitful development routes; architecture studies should feed requirement changes back.

## Inputs / entry criteria (§G.2)
Define the TA at the beginning of the program/project and perform it from concept development through PDR. At the start of Pre-Phase A provide:
- refinement of TRL definitions
- definition of AD²
- definition of the terms used in the assessment
- meaningful evaluation criteria and metrics to identify gaps and shortfalls in performance
- the TA team
- an independent TA review team

## Products
- Initial AD² output: preliminary cost and schedule plans, preliminary risk assessments; later the Technology Development Plan, alternative paths, fallback positions, performance descope options, milestones and metrics for Earned Value Management.
- Products required at each [[KeyDecisionPoint]] (Table G.1-1).
