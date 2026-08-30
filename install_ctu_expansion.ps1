$ErrorActionPreference = "Stop"

Write-Host "Installing PedsFlow v20.5.1 expanded CTU grouping..."

$homePath = "lib\screens\home_screen.dart"
$ctuPath = "lib\screens\ctu_screen.dart"
$releasePath = "RELEASE_INFO.txt"

foreach ($p in @($homePath, $ctuPath, $releasePath)) {
    if (-not (Test-Path $p)) {
        throw "Required file not found: $p"
    }
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
    $seen = $false
    $end = -1

    for ($i = $start; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line.Contains("_ClinicalToolRow(")) {
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
        throw "Could not find end of Home card: $titleText"
    }

    $lines.RemoveRange($start, $end - $start + 1)
}

$homeLines = [System.Collections.Generic.List[string]]::new()
(Get-Content $homePath) | ForEach-Object { [void]$homeLines.Add($_) }

Remove-Import $homeLines "import 'antibiotic_guide_screen.dart';"
Remove-Import $homeLines "import 'pain_management_screen.dart';"

Remove-HomeCardByTitle $homeLines "Pediatric pain management"
Remove-HomeCardByTitle $homeLines "Antibiotics & organisms"

$homeText = $homeLines -join "`r`n"

foreach ($removed in @(
    "title: 'Pediatric pain management'",
    "title: 'Antibiotics & organisms'"
)) {
    if ($homeText.Contains($removed)) {
        throw "Home cleanup verification failed: still contains $removed"
    }
}

if (-not $homeText.Contains("title: 'CTU'")) {
    throw "Home verification failed: CTU card missing"
}

Set-Content $homePath $homeLines -Encoding UTF8

$ctuText = Get-Content $ctuPath -Raw
foreach ($required in @(
    "title: 'Admission Plans'",
    "title: 'Antibiotics & organisms'",
    "title: 'Pediatric Pain Management'",
    "title: 'Growth Suite'"
)) {
    if (-not $ctuText.Contains($required)) {
        throw "CTU verification failed: missing $required"
    }
}

$release = Get-Content $releasePath -Raw
if (-not $release.Contains("Expanded CTU grouping")) {
    Add-Content $releasePath ""
    Add-Content $releasePath "Expanded CTU grouping (v20.5.1):"
    Add-Content $releasePath "- CTU now contains Admission Plans, Antibiotics & organisms, Pediatric Pain Management, and Growth Suite."
    Add-Content $releasePath "- Removed separate Home shortcuts for Antibiotics & organisms and Pediatric pain management."
    Add-Content $releasePath "- Underlying antibiotic and pain-management screens remain unchanged."
}

Write-Host ""
Write-Host "Expanded CTU grouping installed successfully."
Write-Host ""
Write-Host "Run ONLY:"
Write-Host "  flutter analyze"
