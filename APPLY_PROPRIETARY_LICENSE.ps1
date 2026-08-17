# PedsFlow proprietary-license installer
# Run from the project root after extracting this patch over pedsflow_v2.

$ErrorActionPreference = "Stop"

Write-Host "Applying PedsFlow proprietary copyright/license..." -ForegroundColor Cyan

# 1. README notice
$readme = Join-Path $PWD "README.md"
if (Test-Path $readme) {
    $text = Get-Content $readme -Raw
    if ($text -notmatch "PedsFlow Proprietary License") {
        $section = @"

## License

**PedsFlow is proprietary software. Copyright © 2026 Ahmed Saleh. All rights reserved.**

The source code is publicly viewable only to the extent permitted by the hosting platform.
Public availability does not grant permission to reuse, redistribute, commercialize,
white-label, or create derivative products from PedsFlow.

Authorized users may use an authorized compiled/hosted copy of PedsFlow for personal,
educational, professional, or clinical decision-support purposes subject to the
[PedsFlow Proprietary License](LICENSE).

Third-party/open-source components and external clinical reference material remain subject to
their own terms. See [THIRD_PARTY_NOTICE.md](THIRD_PARTY_NOTICE.md).
"@
        Add-Content -Path $readme -Value $section -Encoding UTF8
        Write-Host "Updated README.md"
    } else {
        Write-Host "README.md already contains proprietary-license notice"
    }
}

# 2. Add a proprietary header to project-owned Dart source files.
$header = @"
// PedsFlow — Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.

"@

Get-ChildItem -Path (Join-Path $PWD "lib") -Filter *.dart -Recurse -File | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch "PedsFlow — Proprietary Software") {
        Set-Content -Path $_.FullName -Value ($header + $content) -Encoding UTF8
    }
}
Write-Host "Added proprietary headers to lib/**/*.dart"

# 3. Add visible footer notice without disturbing the current PedsFlow version.
$homeScreen = Join-Path $PWD "lib\screens\home_screen.dart"
if (Test-Path $homeScreen) {
    $content = Get-Content $homeScreen -Raw
    if ($content -notmatch "Proprietary software • All rights reserved") {
        $needle = "Text('© 2026 Dr. Ahmed Saleh'),"
        $replacement = @"
Text('© 2026 Dr. Ahmed Saleh'),
                    SizedBox(height: 3),
                    Text('Proprietary software • All rights reserved'),
"@
        if ($content.Contains($needle)) {
            $content = $content.Replace($needle, $replacement.TrimEnd())
            Set-Content -Path $homeScreen -Value $content -Encoding UTF8
            Write-Host "Added visible proprietary notice to Home footer"
        } else {
            Write-Warning "Home copyright line was not found; LICENSE files were still installed."
        }
    }
}

# 4. Add web copyright metadata.
$webIndex = Join-Path $PWD "web\index.html"
if (Test-Path $webIndex) {
    $content = Get-Content $webIndex -Raw
    if ($content -notmatch 'name="copyright"') {
        $meta = '  <meta name="copyright" content="Copyright © 2026 Ahmed Saleh. All rights reserved. PedsFlow is proprietary software.">'
        $content = $content.Replace("</head>", "$meta`r`n</head>")
        Set-Content -Path $webIndex -Value $content -Encoding UTF8
        Write-Host "Added copyright metadata to web/index.html"
    }
}

Write-Host ""
Write-Host "Proprietary license applied." -ForegroundColor Green
Write-Host "Next run:"
Write-Host "  flutter analyze"
Write-Host "  flutter test"
Write-Host ""
Write-Host "Then commit LICENSE, THIRD_PARTY_NOTICE.md, README.md, lib/, and web/index.html."
