$ErrorActionPreference = "Stop"

Write-Host "Repairing PedsFlow v20.5.1 navigation cleanup..."

$homeScreenPath = "lib\screens\home_screen.dart"

if (-not (Test-Path ".git")) {
    throw "Run this script from the PedsFlow repository root."
}

# Restore the exact known-good Home screen from the v20.5.0 commit.
git cat-file -e "7b5ec38:lib/screens/home_screen.dart" 2>$null
if ($LASTEXITCODE -ne 0) {
    throw "Could not find commit 7b5ec38 locally. Do not continue."
}

git show "7b5ec38:lib/screens/home_screen.dart" | Set-Content $homeScreenPath -Encoding UTF8
if ($LASTEXITCODE -ne 0) {
    throw "Failed to restore the known-good Home screen."
}

$homeText = Get-Content $homeScreenPath -Raw
$homeText = $homeText -replace "`r`n", "`n"

# Remove imports that become unused after cleanup.
$homeText = $homeText.Replace(
    "import '../features/electrolytes/hypokalemia_engine_screen.dart';`n",
    ""
)
$homeText = $homeText.Replace(
    "import 'integrated_clinical_support_screen.dart';`n",
    ""
)
$homeText = $homeText.Replace(
    "import 'pccu_screen.dart';`n",
    ""
)

# Update wording only.
$homeText = $homeText.Replace(
    "subtitle: 'Fast access without oversized dashboard cards',",
    "subtitle: 'High-value bedside tools and clinical references',"
)
$homeText = $homeText.Replace(
    "subtitle: 'Bilirubin, glucose, EOS, fluids/GIR, feeds, corrected GA and newborn resuscitation',",
    "subtitle: 'Patient-specific feeding plan, bilirubin, glucose, EOS, fluids/GIR, corrected GA and resuscitation',"
)

$hypokalemiaBlock = @'
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.bolt_outlined,
                  secondaryIcon: Icons.water_drop_outlined,
                  background: Color(0xFFFFF0D2),
                  accent: Color(0xFF99610C),
                ),
                title: 'Hypokalemia replacement engine',
                subtitle: 'Oral/IV KCl, current-fluid potassium, infusion rate, fluid burden and monitoring',
                meta: 'Electrolytes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const HypokalemiaEngineScreen(),
                    ),
                  );
                },
              ),
'@

$pccuBlock = @'
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.monitor_heart_outlined,
                  secondaryIcon: Icons.bolt_outlined,
                  background: Color(0xFFFFE8E8),
                  accent: Color(0xFF9E2A2A),
                ),
                title: 'PCCU',
                subtitle: '14 PCCU categories, comprehensive pathways, medication pages and critical-care calculators',
                meta: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const PccuScreen(),
                    ),
                  );
                },
              ),
'@

$decisionBlock = @'
              const SizedBox(height: 10),
              _ClinicalToolRow(
                illustration: const _IllustratedBadge(
                  icon: Icons.health_and_safety_outlined,
                  secondaryIcon: Icons.bolt_outlined,
                  background: Color(0xFFE7F3EE),
                  accent: Color(0xFF176B4D),
                ),
                title: 'ED/PICU decision support',
                subtitle: 'Electrolytes, EMR order sets, antibiotics and emergency algorithms',
                meta: '',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const IntegratedClinicalSupportScreen(),
                    ),
                  );
                },
              ),
'@

foreach ($entry in @(
    @{ Name = "Hypokalemia Home shortcut"; Block = $hypokalemiaBlock },
    @{ Name = "PCCU Home shortcut"; Block = $pccuBlock },
    @{ Name = "ED/PICU Decision Support Home shortcut"; Block = $decisionBlock }
)) {
    if (-not $homeText.Contains($entry.Block)) {
        throw "Expected block not found: $($entry.Name). The restored file was left unchanged."
    }
    $homeText = $homeText.Replace($entry.Block, "")
}

# Verify important structure/content remains.
foreach ($required in @(
    "class HomeScreen extends StatelessWidget",
    "title: 'Admission plans'",
    "title: 'Medication library'",
    "title: 'Calculators'",
    "title: 'Neonatal Hub'",
    "title: 'Endocrine Hub'",
    "title: 'Electrolyte Replacement Engine'",
    "title: 'Pediatric pain management'",
    "title: 'Antibiotics & organisms'",
    "title: 'Algorithm library'",
    "title: 'Backup & restore'",
    "title: 'Escalation guide'",
    "class _ClinicalToolRow extends StatelessWidget",
    "class _SectionHeading extends StatelessWidget"
)) {
    if (-not $homeText.Contains($required)) {
        throw "Safety verification failed: missing '$required'. No repaired file written."
    }
}

foreach ($removed in @(
    "title: 'Hypokalemia replacement engine'",
    "title: 'PCCU'",
    "title: 'ED/PICU decision support'",
    "HypokalemiaEngineScreen",
    "IntegratedClinicalSupportScreen",
    "PccuScreen"
)) {
    if ($homeText.Contains($removed)) {
        throw "Cleanup verification failed: '$removed' is still present."
    }
}

# Set-Content will use Windows line endings; Dart accepts either.
Set-Content $homeScreenPath $homeText -Encoding UTF8

Write-Host ""
Write-Host "Home screen repaired from commit 7b5ec38 and cleaned safely."
Write-Host "No underlying clinical feature files were deleted."
Write-Host ""
Write-Host "Run ONLY this next:"
Write-Host "  flutter analyze"
