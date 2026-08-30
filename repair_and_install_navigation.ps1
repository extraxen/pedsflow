$ErrorActionPreference = "Stop"

Write-Host "Repairing and installing PedsFlow v20.5.1 navigation hierarchy..."

$knownGood = "7b5ec38"
$homePath = "lib\screens\home_screen.dart"
$shellPath = "lib\screens\app_shell.dart"
$calcPath = "lib\screens\calculators_screen.dart"
$releasePath = "RELEASE_INFO.txt"

if (-not (Test-Path ".git")) {
    throw "Run this script from C:\Users\drham\pedsflow_v2"
}

foreach ($p in @($homePath, $shellPath, $calcPath, $releasePath, "lib\screens\ctu_screen.dart")) {
    if (-not (Test-Path $p)) {
        throw "Required file not found: $p"
    }
}

# Restore known-good navigation files from v20.5.0.
foreach ($p in @("lib/screens/home_screen.dart", "lib/screens/app_shell.dart", "lib/screens/calculators_screen.dart")) {
    git cat-file -e "$knownGood`:$p" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read $p from commit $knownGood"
    }
    git show "$knownGood`:$p" | Set-Content ($p -replace "/", "\") -Encoding UTF8
}

function Remove-Import([System.Collections.Generic.List[string]]$lines, [string]$needle) {
    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        if ($lines[$i].Trim() -eq $needle) {
            $lines.RemoveAt($i)
        }
    }
}

function Remove-HomeCardByTitle([System.Collections.Generic.List[string]]$lines, [string]$titleText) {
    $titleIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Contains("title: '$titleText'")) {
            $titleIndex = $i
            break
        }
    }
    if ($titleIndex -lt 0) {
        throw "Home card not found: $titleText"
    }

    $start = $titleIndex
    while ($start -ge 0 -and -not $lines[$start].Contains("_ClinicalToolRow(")) {
        $start--
    }
    if ($start -lt 0) {
        throw "Could not find start of Home card: $titleText"
    }

    if ($start -gt 0 -and $lines[$start - 1].Contains("SizedBox(height: 10)")) {
        $start--
    }

    $depth = 0
    $seenCard = $false
    $end = -1

    for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Contains("_ClinicalToolRow(")) {
            $seenCard = $true
        }
        if ($seenCard) {
            $depth += ([regex]::Matches($line, "\(")).Count
            $depth -= ([regex]::Matches($line, "\)")).Count
            if ($depth -eq 0 -and $line.Trim().EndsWith(",")) {
                $end = $i
                break
            }
        }
    }

    if ($end -lt 0) {
        throw "Could not find end of Home card: $titleText"
    }

    $lines.RemoveRange($start, $end - $start + 1)
}

function Replace-AdmissionCardWithCtu([System.Collections.Generic.List[string]]$lines) {
    $titleIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Contains("title: 'Admission plans'")) {
            $titleIndex = $i
            break
        }
    }
    if ($titleIndex -lt 0) {
        throw "Admission plans Home card not found"
    }

    $start = $titleIndex
    while ($start -ge 0 -and -not $lines[$start].Contains("_ClinicalToolRow(")) {
        $start--
    }
    if ($start -lt 0) {
        throw "Could not find Admission plans card start"
    }

    $depth = 0
    $seenCard = $false
    $end = -1
    for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Contains("_ClinicalToolRow(")) {
            $seenCard = $true
        }
        if ($seenCard) {
            $depth += ([regex]::Matches($line, "\(")).Count
            $depth -= ([regex]::Matches($line, "\)")).Count
            if ($depth -eq 0 -and $line.Trim().EndsWith(",")) {
                $end = $i
                break
            }
        }
    }
    if ($end -lt 0) {
        throw "Could not find Admission plans card end"
    }

    $newLines = [string[]]@(
        "              _ClinicalToolRow(",
        "                illustration: const _IllustratedBadge(",
        "                  icon: Icons.local_hospital_outlined,",
        "                  secondaryIcon: Icons.assignment_turned_in_outlined,",
        "                  background: Color(0xFFDDF3F1),",
        "                  accent: Color(0xFF08756F),",
        "                ),",
        "                title: 'CTU',",
        "                subtitle: 'Admission plans and Growth Suite',",
        "                meta: 'Ward tools',",
        "                onTap: () => openTab(1),",
        "              ),"
    )

    $lines.RemoveRange($start, $end - $start + 1)
    $lines.InsertRange($start, $newLines)
}

function Remove-CalculatorItemByTitle([System.Collections.Generic.List[string]]$lines, [string]$titleText) {
    $titleIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Contains("title: '$titleText'")) {
            $titleIndex = $i
            break
        }
    }
    if ($titleIndex -lt 0) {
        throw "Calculator item not found: $titleText"
    }

    $start = $titleIndex
    while ($start -ge 0 -and -not $lines[$start].Contains("_CalculatorItem(")) {
        $start--
    }
    if ($start -lt 0) {
        throw "Could not find calculator item start: $titleText"
    }

    $depth = 0
    $seen = $false
    $end = -1
    for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Contains("_CalculatorItem(")) {
            $seen = $true
        }
        if ($seen) {
            $depth += ([regex]::Matches($line, "\(")).Count
            $depth -= ([regex]::Matches($line, "\)")).Count
            if ($depth -eq 0 -and $line.Trim().EndsWith(",")) {
                $end = $i
                break
            }
        }
    }
    if ($end -lt 0) {
        throw "Could not find calculator item end: $titleText"
    }

    $lines.RemoveRange($start, $end - $start + 1)
}

# HOME
$homeLines = [System.Collections.Generic.List[string]]::new()
(Get-Content $homePath) | ForEach-Object { [void]$homeLines.Add($_) }

Remove-Import $homeLines "import '../features/growth/growth_suite_screen.dart';"
Remove-Import $homeLines "import '../features/electrolytes/electrolyte_engine_screen.dart';"
Remove-Import $homeLines "import '../features/electrolytes/hypokalemia_engine_screen.dart';"
Remove-Import $homeLines "import 'integrated_clinical_support_screen.dart';"
Remove-Import $homeLines "import 'pccu_screen.dart';"

for ($i = 0; $i -lt $homeLines.Count; $i++) {
    if ($homeLines[$i].Contains("subtitle: 'Fast access without oversized dashboard cards'")) {
        $homeLines[$i] = "                subtitle: 'High-value bedside tools and clinical references',"
    }
    if ($homeLines[$i].Contains("subtitle: 'Bilirubin, glucose, EOS, fluids/GIR, feeds, corrected GA and newborn resuscitation'")) {
        $homeLines[$i] = "                subtitle: 'Patient-specific feeding plan, bilirubin, glucose, EOS, fluids/GIR, corrected GA and resuscitation',"
    }
}

Replace-AdmissionCardWithCtu $homeLines
Remove-HomeCardByTitle $homeLines "Growth Suite"
Remove-HomeCardByTitle $homeLines "Electrolyte Replacement Engine"
Remove-HomeCardByTitle $homeLines "Hypokalemia replacement engine"
Remove-HomeCardByTitle $homeLines "PCCU"
Remove-HomeCardByTitle $homeLines "ED/PICU decision support"

$homeText = $homeLines -join "`r`n"

foreach ($required in @(
    "title: 'CTU'",
    "title: 'Medication library'",
    "title: 'Calculators'",
    "title: 'Neonatal Hub'",
    "title: 'Endocrine Hub'",
    "title: 'Pediatric pain management'",
    "title: 'Antibiotics & organisms'",
    "title: 'Algorithm library'",
    "title: 'Backup & restore'",
    "title: 'Escalation guide'"
)) {
    if (-not $homeText.Contains($required)) {
        throw "Home verification failed: missing $required"
    }
}

foreach ($removed in @(
    "title: 'Admission plans'",
    "title: 'Growth Suite'",
    "title: 'Electrolyte Replacement Engine'",
    "title: 'Hypokalemia replacement engine'",
    "title: 'PCCU'",
    "title: 'ED/PICU decision support'"
)) {
    if ($homeText.Contains($removed)) {
        throw "Home cleanup verification failed: still contains $removed"
    }
}

Set-Content $homePath $homeLines -Encoding UTF8

# APP SHELL
$shellLines = [System.Collections.Generic.List[string]]::new()
(Get-Content $shellPath) | ForEach-Object { [void]$shellLines.Add($_) }

Remove-Import $shellLines "import 'plans_screen.dart';"

$calcImportIndex = -1
for ($i = 0; $i -lt $shellLines.Count; $i++) {
    if ($shellLines[$i].Trim() -eq "import 'calculators_screen.dart';") {
        $calcImportIndex = $i
        break
    }
}
if ($calcImportIndex -lt 0) {
    throw "calculators_screen import not found in app_shell.dart"
}
$shellLines.Insert($calcImportIndex + 1, "import 'ctu_screen.dart';")

for ($i = 0; $i -lt $shellLines.Count; $i++) {
    if ($shellLines[$i].Contains("PlansScreen(store: widget.store)")) {
        $shellLines[$i] = "      CtuScreen(store: widget.store),"
    }
    if ($shellLines[$i].Contains("icon: Icon(Icons.assignment_outlined)")) {
        $shellLines[$i] = "            icon: Icon(Icons.local_hospital_outlined),"
    }
    if ($shellLines[$i].Contains("selectedIcon: Icon(Icons.assignment)")) {
        $shellLines[$i] = "            selectedIcon: Icon(Icons.local_hospital),"
    }
    if ($shellLines[$i].Contains("label: 'Plans'")) {
        $shellLines[$i] = "            label: 'CTU',"
    }
}

$shellText = $shellLines -join "`r`n"
if (-not $shellText.Contains("CtuScreen(store: widget.store)")) {
    throw "App shell verification failed: CTU page missing"
}
if (-not $shellText.Contains("label: 'CTU'")) {
    throw "App shell verification failed: CTU label missing"
}
Set-Content $shellPath $shellLines -Encoding UTF8

# CALCULATORS
$calcLines = [System.Collections.Generic.List[string]]::new()
(Get-Content $calcPath) | ForEach-Object { [void]$calcLines.Add($_) }

Remove-Import $calcLines "import '../features/growth/growth_suite_screen.dart';"
Remove-CalculatorItemByTitle $calcLines "Growth Suite"

$calcText = $calcLines -join "`r`n"
if (-not $calcText.Contains("title: 'Electrolyte Replacement Engine'")) {
    throw "Calculator verification failed: Electrolyte Replacement Engine missing"
}
Set-Content $calcPath $calcLines -Encoding UTF8

# RELEASE INFO
$release = Get-Content $releasePath -Raw
if (-not $release.Contains("CTU hierarchy cleanup (v20.5.1)")) {
    Add-Content $releasePath ""
    Add-Content $releasePath "CTU hierarchy cleanup (v20.5.1):"
    Add-Content $releasePath "- Replaced Plans bottom navigation with CTU."
    Add-Content $releasePath "- CTU contains Admission Plans and Growth Suite."
    Add-Content $releasePath "- Home uses one CTU shortcut."
    Add-Content $releasePath "- Electrolyte Replacement Engine remains under Calculators."
    Add-Content $releasePath "- Removed duplicate Home shortcuts for Growth, Electrolytes, Hypokalemia, PCCU, and ED/PICU Decision Support."
    Add-Content $releasePath "- No underlying clinical feature files were deleted."
}

Write-Host ""
Write-Host "Navigation hierarchy repaired and installed."
Write-Host ""
Write-Host "Run ONLY this next:"
Write-Host "  flutter analyze"
