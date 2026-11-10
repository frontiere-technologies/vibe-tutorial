/// Reference content of the TRL guide page, from the project wiki
/// (docs/second-brain/wiki/concepts/TechnologyReadinessLevel.md,
/// KeyDecisionPoint.md, HeritageSystems.md), itself from the NASA Systems
/// Engineering Handbook, NASA/SP-2016-6105 Rev2, Appendix G.
library;

const String guideSource =
    'NASA Systems Engineering Handbook, NASA/SP-2016-6105 Rev2 — Glossary and Appendix G';

/// Figure G.4-1: the nine levels.
const Map<int, String> trlDescriptions = {
  1: 'Basic principles observed and reported',
  2: 'Technology concept and/or application formulated',
  3: 'Analytical and experimental critical function and/or characteristic proof-of-concept',
  4: 'Component and/or breadboard validation in laboratory environment',
  5: 'Component and/or breadboard validation in relevant environment',
  6: 'System/subsystem model or prototype demonstration in a relevant environment (ground or space)',
  7: 'System prototype demonstration in a target/space environment',
  8: 'Actual system completed and "flight qualified" through test and demonstration (ground or flight)',
  9: 'Actual system "flight proven" through successful mission operations',
};

/// Short band names used on the ladder (the handbook's bands overlap and have
/// no exact boundaries; these are indicative).
String trlBand(int level) => switch (level) {
  <= 3 => 'Research',
  <= 5 => 'Development',
  <= 7 => 'Demonstration',
  _ => 'Flight',
};

typedef Gate = ({String name, String transition, String products});

/// Table G.1-1: technology assessment products at each KDP.
const List<Gate> kdpGates = [
  (
    name: 'KDP A',
    transition: 'Pre-Phase A → Phase A',
    products: 'Technology needs assessed against current and planned TRLs; Technology Development Plan baselined; initial Technology Readiness Assessment.',
  ),
  (
    name: 'KDP B',
    transition: 'Phase A → Phase B',
    products: 'Technology Development Plan and Technology Readiness Assessment updated, in the preliminary project plan.',
  ),
  (
    name: 'KDP C',
    transition: 'Phase B → Phase C/D',
    products: 'Technology Readiness Assessment Report: every system, subsystem and component qualified in a relevant environment — TRL 6.',
  ),
];

typedef Rule = ({String title, String body});

const List<Rule> trlRules = [
  (
    title: 'TRL 6 threshold',
    body: 'Typically a TRL of 6 — technology demonstrated in a relevant environment — is required for a technology to be integrated into an SE process, and is what KDP C asks for.',
  ),
  (
    title: 'Heritage drops to TRL 5',
    body: 'A unit that flew in a different configuration or environment is TRL 5, at least initially. Once the differences are evaluated it may become TRL 6 or 7 — never 9 again.',
  ),
  (
    title: 'Lowest TRL rules',
    body: 'A system is at the lowest TRL present in it: subsystems take the lowest TRL of their components, systems the lowest of their subsystems.',
  ),
  (
    title: 'Integration lowers it further',
    body: 'Elements never integrated as a unit give the unit a lower TRL than its parts; how much lower is judged by senior engineers. This app does not assess integration.',
  ),
];
