# Endocrine Hub: Steroid and laboratory calculation modules

Evidence review date: 2026-11-03.

Clinical status: Educational reference only; no SickKids-specific medication conversion protocol or laboratory reference interval has been verified. Never use the output as an independent clinical order.

## Steroid equivalence
Classic approximate systemic glucocorticoid anti-inflammatory equivalent mg:
Hydrocortisone 20, cortisone acetate 25, prednisone 5, prednisolone 5, methylprednisolone 4, triamcinolone 4, dexamethasone 0.75, betamethasone 0.6.
Formula: target mg = source mg / source reference mg * target reference mg.
This is NOT an adrenal-crisis or stress-dose converter, taper calculator, mineralocorticoid comparator, HPA suppression risk model, or automatic oral/IV substitution. Fludrocortisone and all non-systemic or depot formulations are excluded. In some recent guidelines dexamethasone/betamethasone values are 0.5 mg or 0.8 mg rather than classic 0.75/0.6 mg; there is no silent universal conversion.
Source: Endotext, Glucocorticoid Therapy and Adrenal Suppression (2018), Table 1:
https://www.ncbi.nlm.nih.gov/books/NBK279156/table/adrenal_glucocorticoid-therapy-and-adrenal-suppression.T./
ESE/Endocrine Society 2024 pharmacologic equivalence comparison:
https://academic.oup.com/view-large/467272950

## Corrected serum sodium
Katz 1973: measured Na + 1.6 * (glucose in mg/dL - 100) / 100.
Hillier 1999: measured Na + 2.4 * (glucose in mg/dL - 100) / 100.
CPS pediatric DKA (separate): measured Na + (glucose in mmol/L - 5) * 0.3.
Conversion: glucose mmol/L * 18.0182 = mg/dL. Sodium mmol/L.
Katz/Hillier not extrapolated below 100 mg/dL; at >400 mg/dL nonlinear glucose/sodium responses can reduce reliability. These estimate the sodium expected with corrected hyperglycemia, not an actual measured sodium. DKA management must use CPS/local pathways and trends.
https://pubmed.ncbi.nlm.nih.gov/4763428/
https://pubmed.ncbi.nlm.nih.gov/10225241/
https://cps.ca/en/documents/position/current-recommendations-for-management-of-paediatric-diabetic-ketoacidosis

## Anion gap
AG = measured Na - measured chloride - bicarbonate (all mmol/L). No potassium.
Optional albumin-adjusted AG = AG + 0.25*(40 - albumin g/L) for albumin below 40 g/L only. This implements approximately +2.5 mmol/L for each 10 g/L drop in albumin. Uses measured, not hyperglycemia-corrected, sodium. No universal normal interval, and no automatic diagnosis.
https://pmc.ncbi.nlm.nih.gov/articles/PMC11924111/
https://site.thoracic.org/assemblies/cc/clinical-education/interpretation-of-abgs

## Osmolarity and osmolality
Effective calculated osmolarity = 2*measured Na + glucose.
Total calculated osmolarity = 2*measured Na + glucose + urea.
All inputs mmol/L, specifically UREA not BUN. Output based on concentrations is approximately mOsm/L, not measured osmolality (mOsm/kg). Optional approximate osmolal gap compares measured osmolality to calculated total and requires expert interpretation of unmeasured osmoles, different units and laboratory methods.
https://www.gloshospitals.nhs.uk/our-services/services-we-offer/pathology/tests-and-investigations/osmolality/
https://diabetesjournals.org/care/article/49/Supplement_1/S166/163925/8-Obesity-and-Weight-Management-for-the-Prevention

## Architecture and release safety
Isolated pure Dart: lib/features/endocrine/endocrine_lab_math.dart.
New Flutter calculators: lib/features/endocrine/endocrine_lab_tools_screen.dart.
Navigation integrated into lib/features/endocrine/endocrine_hub_screen.dart.
Boundary and worked-case tests: test/endocrine_lab_math_test.dart.
No patient fields are prefilled. Values outside guard ranges return no calculation; guards do not establish clinical exclusion criteria. Systemic steroid equivalence must not be interpreted as equivalent schedules.
GitHub CI should run Flutter analyze, Flutter test, release web build. Passing CI is not evidence of clinical validation. Pediatric endocrinology and pharmacy review is required for real patient-care adoption.
