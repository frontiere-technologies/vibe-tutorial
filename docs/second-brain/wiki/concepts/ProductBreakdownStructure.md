---
title: "Product Breakdown Structure (PBS)"
type: concept
tags: [systems-engineering, technology-assessment]
sources: [nasa-systems-engineering-handbook-0-excerpt-trl]
last_updated: 2026-11-10
---

# Product Breakdown Structure (PBS)

The hierarchical breakdown of a program/project's hardware and software products into systems, subsystems and components. The [[TechnologyMaturityAssessment]] is performed against it. Source: [[nasa-systems-engineering-handbook-0-excerpt-trl]] (§G.1, §G.3, Figure G.1-1).

Using the PBS as the framework of a [[TechnologyAssessment]] has a twofold benefit:
- it breaks the problem down into systems, subsystems and components that can be assessed more accurately;
- it delivers the results in a form directly usable for program cost and schedule estimates, and for milestones and Earned Value Management metrics.

Even at concept level, when elements are only roughly defined, the PBS formalism keeps important technologies from slipping through the cracks.

Example (Figure G.1-1): a Crew Launch Vehicle (1.3) → Launch Vehicle (1.3.8) → First Stage, Upper Stage, Upper Stage Engine → Upper Stage elements such as MPS, RCS, TVCS, Avionics, Software, Integrated Test H/W → their components.

[[TechnologyReadinessLevel]]s roll up this tree: each level takes the lowest TRL below it, adjusted for the state of integration.
