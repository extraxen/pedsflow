$ErrorActionPreference = "Stop"

Write-Host "Installing PedsFlow v20.5.1 CTU hierarchy cleanup hotfix..."

$appShellPath = "lib\screens\app_shell.dart"
$homeScreenPath = "lib\screens\home_screen.dart"
$calculatorsPath = "lib\screens\calculators_screen.dart"
$releasePath = "RELEASE_INFO.txt"

foreach ($path in @($appShellPath, $homeScreenPath, $calculatorsPath, $releasePath, "lib\screens\ctu_screen.dart")) {
    if (-not (Test-Path $path)) {
        throw "Required file not found: $path"
    }
}

function Normalize-Lf([string]$text) {
    return $text.Replace("`r`n", "`n")
}

function Join-Lines([string[]]$lines) {
    return ($lines -join "`n") + "`n"
}

# ---------------- APP SHELL ----------------
$appShell = Normalize-Lf (Get-Content $appShellPath -Raw)

if (-not $appShell.Contains("import 'ctu_screen.dart';")) {
    $anchor = "import 'calculators_screen.dart';`n"
    if (-not $appShell.Contains($anchor)) {
        throw "Could not find app_shell calculators import anchor."
    }
    $appShell = $appShell.Replace(
        $anchor,
        "import 'calculators_screen.dart';`nimport 'ctu_screen.dart';`n"
    )
}

$appShell = $appShell.Replace("import 'plans_screen.dart';`n", "")

$oldPage = "      PlansScreen(store: widget.store),"
$newPage = "      CtuScreen(store: widget.store),"
if (-not $appShell.Contains($oldPage)) {
    throw "Could not find PlansScreen in app_shell.dart."
}
$appShell = $appShell.Replace($oldPage, $newPage)

$oldNav = Join-Lines @(
"          NavigationDestination(",
"            icon: Icon(Icons.assignment_outlined),",
"            selectedIcon: Icon(Icons.assignment),",
"            label: 'Plans',",
"          ),"
)

$newNav = Join-Lines @(
"          NavigationDestination(",
"            icon: Icon(Icons.local_hospital_outlined),",
"            selectedIcon: Icon(Icons.local_hospital),",
"            label: 'CTU',",
"          ),"
)

if (-not $appShell.Contains($oldNav)) {
    throw "Could not find the Plans bottom-navigation block."
}
$appShell = $appShell.Replace($oldNav, $newNav)

if (-not $appShell.Contains("CtuScreen(store: widget.store)")) {
    throw "CTU page verification failed."
}
if (-not $appShell.Contains("label: 'CTU'")) {
    throw "CTU navigation verification failed."
}

Set-Content $appShellPath $appShell -Encoding UTF8

# ---------------- HOME ----------------
$home = Normalize-Lf (Get-Content $homeScreenPath -Raw)

$home = $home.Replace("import '../features/growth/growth_suite_screen.dart';`n", "")
$home = $home.Replace("import '../features/electrolytes/electrolyte_engine_screen.dart';`n", "")

$admissionBlock = Join-Lines @(
"              _ClinicalToolRow(",
"                illustration: const _IllustratedBadge(",
"                  icon: Icons.assignment_outlined,",
"                  secondaryIcon: Icons.check_rounded,",
"                  background: Color(0xFFDDF3F1),",
"                  accent: Color(0xFF08756F),",
"                ),",
"                title: 'Admission plans',",
"                subtitle: 'Browse `${store.plans.length} diagnosis-specific plans',",
"                meta: '`${store.plans.length} plans',",
"                onTap: () => openTab(1),",
"              ),"
)

$ctuBlock = Join-Lines @(
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

if (-not $home.Contains($admissionBlock)) {
    throw "Could not find the exact Admission Plans Home card."
}
$home = $home.Replace($admissionBlock, $ctuBlock)

$growthBlock = Join-Lines @(
"              const SizedBox(height: 10),",
"              _ClinicalToolRow(",
"                illustration: const _IllustratedBadge(",
"                  icon: Icons.show_chart,",
"                  secondaryIcon: Icons.straighten_outlined,",
"                  background: Color(0xFFE8F4F8),",
"                  accent: Color(0xFF27677A),",
"                ),",
"                title: 'Growth Suite',",
"                subtitle: 'Corrected age, longitudinal growth, BMI and velocity with WHO/CDC/Fenton/INTERGROWTH framework',",
"                meta: 'Growth',",
"                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GrowthSuiteScreen())),",
"              ),"
)

$electrolyteBlock = Join-Lines @(
"              const SizedBox(height: 10),",
"              _ClinicalToolRow(",
"                illustration: const _IllustratedBadge(",
"                  icon: Icons.science_outlined,",
"                  secondaryIcon: Icons.bolt_outlined,",
"                  background: Color(0xFFFFF0D2),",
"                  accent: Color(0xFF99610C),",
"                ),",
"                title: 'Electrolyte Replacement Engine',",
"                subtitle: 'Potassium, sodium, magnesium, phosphate and calcium replacement safety',",
"                meta: 'K • Na • Mg • PO₄ • Ca',",
"                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ElectrolyteEngineScreen())),",
"              ),"
)

if (-not $home.Contains($growthBlock)) {
    throw "Could not find the exact Growth Suite Home card."
}
$home = $home.Replace($growthBlock, "")

if (-not $home.Contains($electrolyteBlock)) {
    throw "Could not find the exact Electrolyte Replacement Engine Home card."
}
$home = $home.Replace($electrolyteBlock, "")

if (-not $home.Contains("title: 'CTU'")) {
    throw "CTU Home card verification failed."
}
if ($home.Contains("title: 'Growth Suite'")) {
    throw "Growth Suite Home card is still present."
}
if ($home.Contains("title: 'Electrolyte Replacement Engine'")) {
    throw "Electrolyte Home card is still present."
}

Set-Content $homeScreenPath $home -Encoding UTF8

# ---------------- CALCULATORS ----------------
$calc = Normalize-Lf (Get-Content $calculatorsPath -Raw)

$calc = $calc.Replace("import '../features/growth/growth_suite_screen.dart';`n", "")

$growthCalcBlock = Join-Lines @(
"      _CalculatorItem(",
"        title: 'Growth Suite',",
"        subtitle: 'WHO/CDC/Fenton/INTERGROWTH workspace, corrected age, trajectories and velocity',",
"        icon: Icons.show_chart,",
"        screen: const GrowthSuiteScreen(),",
"      ),"
)

if (-not $calc.Contains($growthCalcBlock)) {
    throw "Could not find Growth Suite in Calculators."
}
$calc = $calc.Replace($growthCalcBlock, "")

if (-not $calc.Contains("title: 'Electrolyte Replacement Engine'")) {
    throw "Electrolyte Replacement Engine is not present in Calculators."
}

Set-Content $calculatorsPath $calc -Encoding UTF8

# ---------------- RELEASE INFO ----------------
$release = Get-Content $releasePath -Raw

$marker = "CTU hierarchy cleanup (v20.5.1):"
if (-not $release.Contains($marker)) {
    $lines = @(
        "",
        "CTU hierarchy cleanup (v20.5.1):",
        "- Replaced the Plans bottom-navigation destination with CTU.",
        "- CTU now contains Admission Plans and Growth Suite.",
        "- Home now has one CTU shortcut instead of separate Admission Plans and Growth Suite cards.",
        "- Removed Electrolyte Replacement Engine from Home; it remains under Calculators.",
        "- Removed Growth Suite from Calculators because it now belongs under CTU.",
        "- No underlying admission-plan, growth, or electrolyte logic was deleted."
    )
    $release = $release.TrimEnd() + "`r`n" + ($lines -join "`r`n") + "`r`n"
    Set-Content $releasePath $release -Encoding UTF8
}

Write-Host ""
Write-Host "CTU hierarchy cleanup installed successfully."
Write-Host ""
Write-Host "Run ONLY:"
Write-Host "  flutter analyze"
