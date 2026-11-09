# Calcium & Bone Health Hub — Evidence and release safety

Review date: 2026-11-09.
Status: Educational clinical reference. Not an institutional medication order set and not a validated local protocol.

## Material reviewed
The user supplied a 51 MB archive containing historical calcium and bone-health clinic material, patient-care educational handouts, neonatal cardiac calcium guidance, a proposed subcutaneous-fat-necrosis (SCFN) hypercalcemia flowchart, and historical bisphosphonate procedures. Only calcium-relevant reference materials were reviewed. The archive also contains patient lists, documents, legacy administrative material and internal-only resources.

The original source files, patient lists, private data, branded flowcharts, phone numbers, institutional order sheets and draft medication regimens are NOT copied into this public repository. The new modules paraphrase general diagnostic concepts without reproducing restricted instructions.

Clinical source categories and their status:
- Hypocalcemia patient guidance: symptom recognition and urgent assessment.
- Calcium and bone-health management material: historical (2014), useful for broad condition structure but NOT considered current therapy policy.
- Calcium/bone-health nutrition handout (2021): age-targeted intake, fracture evaluation and dietary counseling; infant calcium figures differ slightly from the current Canadian DRIs.
- Neonatal cardiac / suspected 22q11 hypoparathyroidism algorithm: labeled for internal use (2025), not published in the app; only general risk recognition, appropriate lab panels and the need for repeat screening are summarized.
- SCFN algorithm: explicitly marked DRAFT (2025 version) despite the upload filename; no treatment thresholds, doses, feeding prescriptions or fluid orders imported.
- Historical zoledronate/pamidronate documents: different dates and renal/dose instructions; no bisphosphonate dosing or renal adjustment imported.

## Sections implemented
1. Hypocalcemia: urgent symptoms and investigations, magnesium/PTH response, monitoring and specialist escalation.
2. Hypercalcemia and SCFN: symptoms, causes, PTH-dependent/independent approach, serial monitoring, renal complications and cautions.
3. Neonatal hypoparathyroidism / 22q11: infant cardiac risk, early versus late calcium problems, workup and follow-up.
4. Qualitative calcium/PTH lab-pattern aid: clinician first chooses low/normal/high using local assay interval; urgent symptoms override classification.
5. Dietary calcium, spot urine Ca/Cr and product-label elemental calcium arithmetic: source-aware inputs with explicit units and no auto-prescribed supplements.
6. Pediatric bone fragility and rickets: ISCD fracture criteria, biochemistry, DXA and referral considerations.
7. Bisphosphonate safety: pre-infusion checks and adverse-effect recognition, no regimens.

## External verification
Pediatric Endocrine Society — Child With Suspected Hypocalcemia:
https://pedsendo.org/clinical-resource/child-with-suspected-hypocalcemia/
NHS Tayside — Acute Management of Hypocalcaemia in Children:
https://www.rightdecisions.scot.nhs.uk/nhs-tayside-paediatrics-pathways/paediatric-endocrinology/acute-management-of-hypocalcaemia-in-children/
Children's Hospital of Philadelphia — Hypercalcemia:
https://www.chop.edu/conditions-diseases/hypercalcemia
Pediatric calcium disorders review:
https://pmc.ncbi.nlm.nih.gov/articles/PMC11144013/
ISCD official Pediatric Positions (2019):
https://iscd.org/learn/official-positions/pediatric-positions/
Health Canada — Dietary Reference Intakes for Elements:
https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-elements.html
Health Canada — Dietary Reference Intakes for Vitamins:
https://www.canada.ca/en/health-canada/services/food-nutrition/healthy-eating/dietary-reference-intakes/tables/reference-values-vitamins.html

### Calcium DRIs used by calculator
In infants 0–6 months, 200 mg/day AI; 7 to under 12 completed months, 260 mg/day AI. Ages 1–3 years (12–47 months): 700 mg/day RDA; 4–8 years (48–107 months): 1000 mg/day RDA; 9–18 years (108–227 months): 1300 mg/day RDA.

The supplied 2021/2025 institutional handout describes infant AI as 210 and 270 mg/day. The calculator intentionally uses newer Health Canada values 200 and 260 and explicitly states the discrepancy. This is nutrition reference information, NOT a treatment or supplement dose.

### Pediatric osteoporosis
The 2019 ISCD positions specify (a) a vertebral compression fracture without high-energy trauma or local bone disease as sufficient, OR (b) clinically significant fractures (2 long bone fractures by age 10, or 3 by age 19) together with BMD Z-score <= -2.0. A low BMD by itself is not diagnostic. A BMD above -2 does not exclude fragility.

## Formulas and fail-closed policy
- Total calcium target is a lookup by completed months. Valid age: 0–227 months inclusive.
- Intake difference = target mg/day minus reported total dietary intake mg/day.
- Intake percentage = reported intake / age-reference target * 100.
- Urine Ca/Cr = urine calcium concentration in mmol/L / urine creatinine concentration in mmol/L. This is mmol/mmol; not mass-based mg/mg or mg/mmol. It is NOT auto-classified; age-specific ranges are mandatory.
- Label elemental calcium (mg) = calcium salt mass (mg) times user-confirmed labelled elemental percentage / 100. This is NOT a supplement dose. If label supplies elemental mg directly, use that instead.
- PTH patterns are qualitative and depend on a clinician classifying contemporaneous calcium and PTH against the patient's age- and assay-specific local intervals. A seemingly "normal" PTH can be inappropriate.

No patient weights, medications, treatment rates or reference samples are automatically prefilled. Non-finite, negative, missing, zero-denominator and out-of-bound inputs fail without displaying a calculated result.

## Items requiring local clinical review
- Confirm actual inpatient calcium assay/age reference limits, critical calcium management and ECG/line policies.
- Confirm serial neonatal calcium measurement schedules and 22q11 protocols.
- Obtain final approved SCFN pathway; do not treat the supplied draft as policy.
- Confirm latest renal, dental, vitamin D and calcium readiness criteria for bisphosphonates.
- Consider separate clinician-provided institutional references only through access-controlled channels if a future feature needs actual dose/order sets.
- Manually QA mobile/desktop navigation and calculator fields; CI pass is not clinical approval.

## Technical files
- lib/features/endocrine/calcium_hub_math.dart
- lib/features/endocrine/calcium_hub_screen.dart
- lib/features/endocrine/endocrine_hub_screen.dart
- test/calcium_hub_math_test.dart

CI: flutter analyze, flutter test and flutter build web.
