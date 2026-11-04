# Neonatal thyroid assessment — source, thresholds, and safety

Reviewed 4 November 2026. This educational module is not a validated SickKids clinical order set.

## 1. Source-derived reference intervals
These numbers are transcribed from a user-provided "Free T4 Neonatal Reference Ranges" image. That image does not identify the laboratory, instrument, assay, collection date, or provenance. **The app must not imply these intervals are authoritative for every newborn.** The user must check the performing lab's current report and the specimen's exact age at sampling.

Free T4 in pmol/L:

| Age on source slide | FT4 interval |
| --- | --- |
| 3 d to <15 d | 13.0–52.2 |
| 15 d to <30 d | 10.5–30.0 |
| 30 d to <4 months | 10.5–22.7 |
| 4 months to <1 year | 10.0–22.0 |
| 1 year to <19 years | 10.0–17.6 |

TSH in mIU/L (=mU/L):

| Age on source slide | TSH interval |
| --- | --- |
| <5 days | 3.2–19 |
| 6–31 days | 1.7–9.1 |
| 1–2 months | 0.5–6.3 |
| 3 to <6 months | 0.5–4.77 |
| 6 months to <1 year | 0.61–4.58 |
| 1 to <14 years | 0.73–4.09 |
| 14 to <19 years | 0.47–4.00 |

**Source limitations:** No FT4 interval is shown for ages 0–2 days. There is an explicit TSH gap at exactly 5 days (between "<5" and "6–31"). The 6–31 d TSH interval overlaps the slide's "1–2 months" label; for day 30–31 this implementation uses the more specific day-based range. From 32 d onward, 30 d/month and 365 d/year are approximate conversions from source labels, not exact calendar-month/years cutoffs. Confirm against lab-specific ranges at boundaries. Neither a laboratory range nor these gaps alone determine when to treat.

## 2. Guideline-based diagnostic decisions (SEPARATE from slide)
Sources:
- ENDO-ERN/ESPE congenital hypothyroidism consensus 2020–2021: https://pmc.ncbi.nlm.nih.gov/articles/PMC8001676/
- AAP Pediatrics, Congenital Hypothyroidism: Screening and Management, 2023: https://publications.aap.org/pediatrics/article/151/1/e2022060420/190308/

The app requires an explicit acknowledgment that numbers are from **serum**, not dried-blood-spot screening. An abnormal newborn screen triggers prompt endocrinology/newborn-screen-program follow-up and confirmatory paired serum tests even if entered values appear within the provided slide intervals. The following are *suggested escalation pathways*, not medication orders:

- Low age-specific FT4 with clearly elevated TSH: urgent pediatric endocrinology assessment for possible primary congenital hypothyroidism. Guidelines support prompt LT4 initiation under specialist direction.
- Confirmatory **serum** TSH >20 mIU/L approximately in the second week of life: urgent endocrine assessment and LT4 consideration even if FT4 is within age reference, per AAP/ENDO-ERN. Early postnatal TSH surge means the first days need special interpretation.
- Normal age-specific FT4 with serum TSH 6–20 mIU/L after age 21 days: no universally correct treatment choice; endocrine review. ENDO-ERN supports either LT4 with later re-evaluation or repeat paired serum tests in 1–2 weeks in otherwise healthy infants.
- Low FT4 with non-elevated or only mildly elevated TSH: possible *central* congenital hypothyroidism. Urgent endocrine assessment, including evaluation for adrenal insufficiency **before LT4** when central disease cannot be excluded.
- High FT4 and suppressed TSH: prompt evaluation for neonatal thyrotoxicosis, maternal Graves disease/thyroid antibodies, and confounders.
- Preterm, NICU, sick, low birth weight, transfused, pituitary risk or midline anomaly: a normal single test must not be treated as an exclusion. Follow the newborn-screen program's repeated-screen strategy. AAP advises repeat newborn screen at 2–4 weeks for selected at-risk babies (e.g. <32 weeks, <1500 g, critically ill).
- Already treated with LT4: specialist-directed treated-patient monitoring, not the new-diagnosis algorithm. Concerning results still trigger expedited review.
- Missing values, unknown reference age, non-serum results or non-finite/invalid numeric inputs: no reassuring output.

No levothyroxine dose, IV administration, pituitary replacement, or taper schedule is created.

## 3. Technical implementation
- Pure Dart engine: lib/features/endocrine/neonatal_thyroid_engine.dart
- Standalone mobile screen: lib/features/endocrine/neonatal_thyroid_screen.dart
- Endocrine Hub navigation: lib/features/endocrine/endocrine_hub_screen.dart
- Independent test suite: test/neonatal_thyroid_engine_test.dart

User interaction shows: age in completed days, serum TSH mIU/L, FT4 pmol/L, newborn screen status, serum specimen confirmation, preterm/NICU status, possible pituitary disease, and current LT4 status. It displays the reference band, classification and guideline-grounded next actions. The entire transcribed reference is shown in expandable tables. No PHI is stored.

**Clinical review needed before relying on the pathway:** confirm laboratory reference provenance and local SickKids test methods, gestational/postmenstrual-age context, repeat newborn screening recommendations, ordering workflows, treatment initiation/timing and pediatric endocrine sign-off. Flutter analyze, test and web build verify implementation, not clinical appropriateness.
