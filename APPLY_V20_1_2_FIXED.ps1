$ErrorActionPreference = "Stop"

Write-Host "Applying PedsFlow v20.1.2 hypokalemia redesign..." -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    throw "Run this script from the root of your PedsFlow project (the folder containing pubspec.yaml)."
}

$homeScreen = "lib\screens\home_screen.dart"
if (Test-Path $homeScreen) {
    $text = Get-Content $homeScreen -Raw
    $text = $text.Replace("PedsFlow v20.1.0", "PedsFlow v20.1.2")
    $text = $text.Replace("PedsFlow v20.1.1", "PedsFlow v20.1.2")
    $text = $text.Replace("Implemented August 2, 2026", "Implemented August 17, 2026")
    Set-Content -Path $homeScreen -Value $text -Encoding utf8
}

Write-Host "Version tracker updated. Now run flutter analyze." -ForegroundColor Green
