# PedsFlow v20.1.0 — Full Clinical Suite

## Integrated modules

### Growth Suite
- WHO / CDC / Fenton / INTERGROWTH reference-selection architecture
- Embedded LMS calculation engine with no growth_standards/dart_numerics runtime dependency
- Corrected age for prematurity
- Weight, height, head circumference and BMI entry
- Longitudinal measurements
- Weight trajectory plot
- Weight / height / BMI velocity calculations
- Reference provenance manifest
- Exact percentile/Z-score output is safety-gated until each installed reference table is provenance-validated

### Neonatal Hub
- Existing CPS bilirubin engine
- CPS neonatal hypoglycemia workflow and calculations
- EOS / sepsis assessment framework
- Neonatal fluids and GIR
- Corrected gestational age / PMA
- Feeding-volume and kcal/kg/day calculations
- Neonatal medication-reference safety framework
- 2025 newborn-resuscitation quick reference
- Search-within-hub

### Endocrine Hub
- Existing pediatric DKA calculator
- Adrenal-crisis calculator/reference
- Pediatric hypoglycemia
- DI / SIADH
- Calcium emergencies
- Thyroid emergencies
- Insulin TDD / correction-factor / carb-ratio educational calculators
- Search-within-hub

### Electrolyte Replacement Engine
- Detailed hypokalemia / KCl engine
- Sodium correction safety planning
- Magnesium replacement
- Phosphate replacement
- Calcium replacement safety gate
- Weight-based calculations, route/access guidance, infusion rates,
  renal cautions and monitoring/recheck information where validated

### Search v2
- Full-app ranked global index
- Best match
- Recent searches
- Favorite search results
- Category filters
- Typo / alias handling
- Command weight parsing such as "ketamine dose 25 kg"
- Quick commands
- Search within the new Growth / Neonatal / Endocrine / Electrolyte hubs

## Safety notes
- PedsFlow does not manufacture an exact percentile or medication dose when a validated
  reference dataset/monograph is not installed.
- Local LHSC/PCCU/NICU pharmacy, smart-pump, formulary and institutional policies remain authoritative.
- Calcium replacement and some neonatal medication dosing remain intentionally gated to local
  validated monographs rather than embedding unsupported generic concentrations.
