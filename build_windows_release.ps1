<#
.SYNOPSIS
  Compile AirBar en release pour Windows et prépare un dossier + zip pour clé USB.

.DESCRIPTION
  Flutter ne sait compiler que pour l'architecture de la machine hôte :
  lancer ce script sur un PC x64 produit un build x64, sur un PC ARM64 un build ARM64.

  Prérequis : Flutter (Windows desktop activé), Visual Studio avec "Desktop development with C++",
  et le dépôt ../airbar_backend/airbar_backend_client présent (dépendance locale).

.EXAMPLE
  .\build_windows_release.ps1
  .\build_windows_release.ps1 -SkipBuild   # re-packager sans recompiler
#>
param(
    [switch]$SkipBuild,
    [string]$OutputDir = "build\dist"
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
Write-Host "Architecture cible : $arch" -ForegroundColor Cyan

if (-not (Test-Path '..\airbar_backend\airbar_backend_client')) {
    throw "Dependance introuvable : ..\airbar_backend\airbar_backend_client"
}

if (-not $SkipBuild) {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw "flutter pub get a echoue" }
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw "flutter build windows a echoue" }
}

$src = "build\windows\$arch\runner\Release"
if (-not (Test-Path "$src\airbar.exe")) { throw "Build introuvable : $src\airbar.exe" }

$name = "AirBar-windows-$arch"
$dst = Join-Path $OutputDir $name
$zip = Join-Path $OutputDir "$name-release.zip"

Remove-Item $dst, $zip -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $dst -Force | Out-Null
Copy-Item "$src\*" $dst -Recurse

# Runtime Visual C++ embarqué : l'app démarre même sans redistribuable installé
foreach ($dll in 'vcruntime140.dll', 'vcruntime140_1.dll', 'msvcp140.dll') {
    $path = Join-Path $env:SystemRoot "System32\$dll"
    if (Test-Path $path) { Copy-Item $path $dst } else { Write-Warning "$dll introuvable dans System32" }
}

Compress-Archive -Path $dst -DestinationPath $zip -Force

Write-Host ""
Write-Host "Termine ($arch) :" -ForegroundColor Green
Write-Host "  Dossier : $((Resolve-Path $dst).Path)"
Write-Host "  Zip     : $((Resolve-Path $zip).Path)"
Write-Host "Copiez le dossier (ou le zip) sur la cle USB ; lancez airbar.exe."
