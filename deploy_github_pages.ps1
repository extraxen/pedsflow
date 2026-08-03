param(
  [string]$RepoFolder = "$HOME\Documents\GitHub\pedsflow"
)

$ErrorActionPreference = "Stop"

Write-Host "Building PedsFlow for GitHub Pages..."
flutter clean
flutter pub get
flutter build web --release --base-href "/pedsflow/"

if (!(Test-Path $RepoFolder)) {
  throw "GitHub repository folder not found: $RepoFolder"
}

Write-Host "Replacing files in $RepoFolder"
Get-ChildItem -Path $RepoFolder -Force |
  Where-Object { $_.Name -ne ".git" } |
  Remove-Item -Recurse -Force

Copy-Item -Path ".\build\web\*" -Destination $RepoFolder -Recurse -Force

Write-Host ""
Write-Host "Build copied successfully."
Write-Host "Open GitHub Desktop, review changes, Commit to main, then Push origin."
