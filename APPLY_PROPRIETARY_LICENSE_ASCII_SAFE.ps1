# PedsFlow proprietary-license installer - ASCII-safe version
# Run from the PedsFlow project root.

$ErrorActionPreference = "Stop"

Write-Host "Applying PedsFlow proprietary copyright/license..." -ForegroundColor Cyan

# Confirm project root
if (-not (Test-Path ".\pubspec.yaml")) {
    Write-Error "pubspec.yaml not found. Run this script from C:\Users\drham\pedsflow_v2"
    exit 1
}

# -------------------------------------------------------------------
# 1. Ensure LICENSE exists
# -------------------------------------------------------------------
if (-not (Test-Path ".\LICENSE")) {
    Write-Warning "LICENSE file is missing. Extract the license patch into the project root first."
}

# -------------------------------------------------------------------
# 2. Update README
# -------------------------------------------------------------------
$readmePath = Join-Path $PWD "README.md"

if (Test-Path $readmePath) {
    $readmeText = Get-Content $readmePath -Raw

    if ($readmeText -notmatch "PedsFlow Proprietary License") {
        $licenseSection = @'

## License

PedsFlow is proprietary software.
Copyright (c) 2026 Ahmed Saleh. All rights reserved.

The source code may be publicly viewable where hosted, but public availability does not grant
permission to reuse, redistribute, commercialize, white-label, sublicense, republish, or create
derivative products from PedsFlow except where independently permitted by applicable law or
third-party licenses.

Authorized users may use an authorized compiled or hosted version of PedsFlow for personal,
educational, professional, or clinical decision-support purposes subject to the PedsFlow
Proprietary License in the LICENSE file.

Third-party and open-source components, datasets, publications, clinical guidelines, standards,
and reference material remain subject to their own licenses and terms. See THIRD_PARTY_NOTICE.md.
'@

        Add-Content -Path $readmePath -Value $licenseSection -Encoding UTF8
        Write-Host "Updated README.md"
    }
    else {
        Write-Host "README.md already contains the proprietary-license notice"
    }
}

# -------------------------------------------------------------------
# 3. Add headers to project-owned Dart files
# -------------------------------------------------------------------
$dartHeader = @'
// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

'@

$libPath = Join-Path $PWD "lib"

if (Test-Path $libPath) {
    Get-ChildItem -Path $libPath -Filter *.dart -Recurse -File | ForEach-Object {
        $dartText = Get-Content $_.FullName -Raw

        if ($dartText -notmatch "PedsFlow - Proprietary Software") {
            Set-Content -Path $_.FullName -Value ($dartHeader + $dartText) -Encoding UTF8
        }
    }

    Write-Host "Added proprietary headers to lib/**/*.dart"
}

# -------------------------------------------------------------------
# 4. Add visible notice to Home footer
# -------------------------------------------------------------------
$homeScreenPath = Join-Path $PWD "lib\screens\home_screen.dart"

if (Test-Path $homeScreenPath) {
    $homeText = Get-Content $homeScreenPath -Raw

    if ($homeText -notmatch "Proprietary software - All rights reserved") {

        # Match either copyright-symbol or ASCII-style existing footer text.
        $patterns = @(
            "Text\('© 2026 Dr\. Ahmed Saleh'\),",
            "Text\('Copyright \(c\) 2026 Dr\. Ahmed Saleh'\),"
        )

        $matched = $false

        foreach ($pattern in $patterns) {
            if ($homeText -match $pattern) {
                $replacement = @"
Text('Copyright (c) 2026 Dr. Ahmed Saleh'),
                    SizedBox(height: 3),
                    Text('Proprietary software - All rights reserved'),
"@
                $homeText = [regex]::Replace($homeText, $pattern, $replacement.TrimEnd(), 1)
                $matched = $true
                break
            }
        }

        if ($matched) {
            Set-Content -Path $homeScreenPath -Value $homeText -Encoding UTF8
            Write-Host "Added visible proprietary notice to Home footer"
        }
        else {
            Write-Warning "Could not automatically locate the Home copyright footer. LICENSE files were still applied."
        }
    }
    else {
        Write-Host "Home footer already contains proprietary notice"
    }
}

# -------------------------------------------------------------------
# 5. Add web copyright metadata
# -------------------------------------------------------------------
$webIndexPath = Join-Path $PWD "web\index.html"

if (Test-Path $webIndexPath) {
    $webText = Get-Content $webIndexPath -Raw

    if ($webText -notmatch 'name="copyright"') {
        $metaTag = '  <meta name="copyright" content="Copyright (c) 2026 Ahmed Saleh. All rights reserved. PedsFlow is proprietary software.">'

        if ($webText -match "</head>") {
            $webText = $webText.Replace("</head>", "$metaTag`r`n</head>")
            Set-Content -Path $webIndexPath -Value $webText -Encoding UTF8
            Write-Host "Added copyright metadata to web/index.html"
        }
    }
    else {
        Write-Host "web/index.html already contains copyright metadata"
    }
}

Write-Host ""
Write-Host "PedsFlow proprietary license installation completed." -ForegroundColor Green
Write-Host ""
Write-Host "Next run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host ""
Write-Host "Then:"
Write-Host "  git add -A"
Write-Host '  git commit -m "Add PedsFlow proprietary copyright and license"'
Write-Host "  git push origin main"
