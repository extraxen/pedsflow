$ErrorActionPreference = "Stop"

Write-Host "Installing PedsFlow v20.5.0 NICU Specific Patient Feeding Plan..."

$hub = "lib\features\neonatal\neonatal_hub_screen.dart"
$meta = "lib\app_metadata.dart"
$pubspec = "pubspec.yaml"
$release = "RELEASE_INFO.txt"

foreach ($path in @($hub, $meta, $pubspec, $release)) {
    if (-not (Test-Path $path)) {
        throw "Required file not found: $path. Run this script from the PedsFlow repository root."
    }
}

$hubText = Get-Content $hub -Raw
if ($hubText -notmatch "nicu_feeding_plan_screen.dart") {
    $oldImport = "import '../bilirubin/bilirubin_screen.dart';"
    $newImport = "import '../bilirubin/bilirubin_screen.dart';`r`nimport 'nicu_feeding_plan_screen.dart';"
    if (-not $hubText.Contains($oldImport)) {
        throw "Could not find the expected Neonatal Hub import anchor. No changes made to hub."
    }
    $hubText = $hubText.Replace($oldImport, $newImport)

    $oldItem = "_NeoItem('Feeding calculator', 'mL/kg/day → mL/day, mL/feed and kcal/kg/day', Icons.local_drink_outlined, const NeonatalFeedingScreen()),"
    $newItem = "_NeoItem('Specific Patient Feeding Plan', 'LHSC newborn initial plan + current feeds → next nutrition milestones', Icons.route_outlined, const NicuSpecificFeedingPlanScreen()),`r`n      $oldItem"
    if (-not $hubText.Contains($oldItem)) {
        throw "Could not find the expected Feeding calculator item anchor. No changes made to hub."
    }
    $hubText = $hubText.Replace($oldItem, $newItem)
    Set-Content $hub $hubText -Encoding UTF8
}

$metaText = Get-Content $meta -Raw
$metaText = $metaText -replace "const String pedsFlowVersion = '[^']+';", "const String pedsFlowVersion = '20.5.0';"
$metaText = $metaText -replace "const int pedsFlowBuildNumber = \d+;", "const int pedsFlowBuildNumber = 2050;"
$metaText = $metaText -replace "const String pedsFlowVersionLabel = '[^']+';", "const String pedsFlowVersionLabel = '20.5.0+2050';"
$metaText = $metaText -replace "const String pedsFlowReleaseDate = '[^']+';", "const String pedsFlowReleaseDate = 'August 29, 2026';"
Set-Content $meta $metaText -Encoding UTF8

$pubText = Get-Content $pubspec -Raw
$pubText = $pubText -replace "(?m)^version:\s*[^\r\n]+", "version: 20.5.0+2050"
Set-Content $pubspec $pubText -Encoding UTF8

$releaseText = Get-Content $release -Raw
$releaseText = $releaseText -replace "(?m)^Version:\s*[^\r\n]+", "Version: 20.5.0+2050"
$releaseText = $releaseText -replace "(?m)^Release date:\s*[^\r\n]+", "Release date: August 29, 2026"

if ($releaseText -notmatch "NICU Specific Patient Feeding Plan") {
    $releaseText += @"

NICU Specific Patient Feeding Plan (v20.5.0):
- Added to the Neonatal Hub as a separate workflow from the basic feeding calculator.
- NEWBORN mode: GA + birth weight in grams -> local quick-guide starting feeds, donor EBM eligibility, and initial TPN/IV pathway.
- Calculates initial feed mL/day and mL/kg/day.
- Calculates TFI mL/day and mL/hr when the quick-guide pathway specifies a single TFI.
- ALREADY ON FEEDS mode: calculates current mL/day and mL/kg/day and shows the next documented nutrition milestone.
- Fortification milestone: 100 mL/kg/day.
- TPN/SMOF milestone: 100-120 mL/kg/day OR 75-80% feeds, as stated on the supplied quick card.
- IV discontinuation milestone: minimum 130-140 mL/kg/day AND fortified feeds tolerated.
- Adds donor EBM, HIE/perinatal acidosis, PRBC/iron, probiotic, and >32-week monitoring prompts where supported by the supplied card.
- Does NOT invent a universal feed-advancement rate; exact next-feed increases remain unautomated until verified from the full LHSC Neonatal TPN and Enteral Guideline.
- Exact 26+0-week TPN boundary is deliberately flagged for verification because the supplied card wording is not unambiguous.
- Added pure-engine unit tests for feed bands, TPN pathways, mL/kg/day arithmetic, donor eligibility and major milestones.

Clinical source basis:
- LHSC NICU Basic Nutrition Quick Guide / Neonatal TPN and Enteral quick-reference cards, updated 2024.
- The active full LHSC Neonatal TPN and Enteral Guideline, NICU clinical judgment, pharmacy and dietitian recommendations remain authoritative.
"@
}
Set-Content $release $releaseText -Encoding UTF8

Write-Host ""
Write-Host "Files installed and Neonatal Hub patched."
Write-Host "Now run these commands ONE AT A TIME:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host '  flutter build web --release --base-href "/pedsflow/"'
