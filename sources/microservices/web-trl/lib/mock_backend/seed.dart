/// Sample content so the app never opens empty: a fictional 12U smallsat at
/// the end of Phase B, preparing KDP C (target TRL 6). The answers cover
/// every outcome of the flowchart: TRL 1 to 9, heritage provisional and
/// evaluated, "rethink", and one component not assessed yet.
library;

class SeedComponent {
  const SeedComponent(
    this.id,
    this.name,
    this.subsystem,
    this.description, {
    this.firstYes,
    this.allNo = false,
    this.evaluatedHeritageTrl,
  });

  final String id;
  final String name;
  final String subsystem;
  final String description;

  /// Number of the first question answered "yes" (1–10); null with [allNo]
  /// false means not assessed yet.
  final int? firstYes;
  final bool allNo;
  final int? evaluatedHeritageTrl;

  List<bool> get answers {
    if (allNo) return List.filled(10, false);
    if (firstYes == null) return const [];
    return [...List.filled(firstYes! - 1, false), true];
  }
}

const seedProject = (
  id: 'lyra-pathfinder',
  name: 'Lyra Pathfinder',
  mission: '12U Earth-observation smallsat — fictional sample project',
  phase: 'Phase B · Preliminary Design',
  milestone: 'KDP C',
  targetTrl: 6,
);

const List<SeedComponent> seedComponents = [
  SeedComponent(
    'adcs-star-tracker',
    'Star tracker',
    'ADCS',
    'Flight-proven on a previous LEO mission, now on a new bus and thermal environment. Differences evaluated by the ADCS team.',
    firstYes: 2,
    evaluatedHeritageTrl: 6,
  ),
  SeedComponent(
    'adcs-sun-sensors',
    'Coarse sun sensors',
    'ADCS',
    'Catalogue units, identical model and mounting already flown in the same configuration.',
    firstYes: 1,
  ),
  SeedComponent(
    'adcs-reaction-wheels',
    'Reaction wheel assembly',
    'ADCS',
    'New four-wheel pyramid; prototype passed vibration and thermal-vacuum tests.',
    firstYes: 5,
  ),
  SeedComponent(
    'eps-solar-array',
    'Deployable solar array',
    'Power',
    'Two-wing array with a new hinge; breadboard deployed in thermal vacuum.',
    firstYes: 6,
  ),
  SeedComponent(
    'eps-battery',
    'Li-ion battery pack',
    'Power',
    'Qualified to the launch-vehicle environment, not flown yet.',
    firstYes: 3,
  ),
  SeedComponent(
    'comms-x-band',
    'X-band transponder',
    'Communications',
    'Same unit as a GEO mission, re-used in a LEO architecture. Differences not evaluated yet.',
    firstYes: 2,
  ),
  SeedComponent(
    'comms-patch-antenna',
    'Deployable patch antenna',
    'Communications',
    'Origami-folded patch array; breadboard measured in the anechoic chamber.',
    firstYes: 7,
  ),
  SeedComponent(
    'prop-green-thruster',
    'Green monopropellant thruster',
    'Propulsion',
    '1 N thruster with a new catalyst; proof-of-concept firings in the lab.',
    firstYes: 8,
  ),
  SeedComponent(
    'payload-imager',
    'Hyperspectral imager',
    'Payload',
    'Prototype flown as a hosted payload on a technology-demonstration mission.',
    firstYes: 4,
  ),
  SeedComponent(
    'payload-ai-triage',
    'On-board AI image triage',
    'Payload',
    'Discards cloudy frames before downlink; concept and application formulated.',
    firstYes: 9,
  ),
  SeedComponent(
    'thermal-electrochromic',
    'Electrochromic radiator coating',
    'Thermal',
    'Variable-emittance coating; basic principles reported in the literature.',
    firstYes: 10,
  ),
  SeedComponent(
    'thermal-self-healing',
    'Self-healing radiator film',
    'Thermal',
    'Proposed by a supplier; no basic principles observed or reported yet.',
    allNo: true,
  ),
  SeedComponent(
    'cdh-flight-computer',
    'Flight computer',
    'C&DH',
    'Rad-tolerant single-board computer, selected last week.',
  ),
];
