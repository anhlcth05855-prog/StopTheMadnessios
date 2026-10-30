# Script dong goi file IPA chuan iTunes tren Windows
$ErrorActionPreference = "Stop"

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $currentDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     DANG TAO GOI STOPTHEMADNESS PRO IPA CHO ITUNES       " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$payloadDir = Join-Path $currentDir "Payload"
$appDir = Join-Path $payloadDir "StopTheMadnessPro.app"
$pluginsDir = Join-Path $appDir "PlugIns"
$extensionDir = Join-Path $pluginsDir "StopTheMadnessExtension.appex"
$outputIpa = Join-Path $currentDir "StopTheMadnessPro.ipa"
$outputZip = Join-Path $currentDir "StopTheMadnessPro.zip"

# 1. Don dep thu muc tam
if (Test-Path $payloadDir) { Remove-Item -Recurse -Force $payloadDir }
if (Test-Path $outputIpa) { Remove-Item -Force $outputIpa }
if (Test-Path $outputZip) { Remove-Item -Force $outputZip }

New-Item -ItemType Directory -Force -Path $extensionDir | Out-Null

Write-Host "[1/4] Dong goi App Bundle va Extension Bundle..." -ForegroundColor Green

# Copy Info.plist cua App
Copy-Item (Join-Path $currentDir "StopTheMadnessPro\App\Info.plist") (Join-Path $appDir "Info.plist")

# Copy Resources cua Extension vao .appex
Copy-Item -Recurse -Force (Join-Path $currentDir "StopTheMadnessExtension\Resources\*") $extensionDir
Copy-Item (Join-Path $currentDir "StopTheMadnessExtension\Info.plist") (Join-Path $extensionDir "Info.plist")

# Copy Resource Web Script vao App Bundle
if (Test-Path (Join-Path $currentDir "StopTheMadnessPro\Resources\stopthemadness.js")) {
    Copy-Item (Join-Path $currentDir "StopTheMadnessPro\Resources\stopthemadness.js") (Join-Path $appDir "stopthemadness.js")
    Copy-Item (Join-Path $currentDir "StopTheMadnessPro\Resources\stopthemadness.css") (Join-Path $appDir "stopthemadness.css")
}

Write-Host "[2/4] Bo sung sieu du lieu iTunesMetadata.plist..." -ForegroundColor Green
Copy-Item (Join-Path $currentDir "iTunesMetadata.plist") (Join-Path $payloadDir "iTunesMetadata.plist")

Write-Host "[3/4] Nen Payload thanh file StopTheMadnessPro.ipa..." -ForegroundColor Green
Compress-Archive -Path (Join-Path $currentDir "Payload"), (Join-Path $currentDir "iTunesMetadata.plist") -DestinationPath $outputZip -Force

# Doi duoi .zip sang .ipa
Rename-Item -Path $outputZip -NewName "StopTheMadnessPro.ipa" -Force

# Don dep thu muc Payload tam
Remove-Item -Recurse -Force $payloadDir

Write-Host "[4/4] THANH CONG!" -ForegroundColor Yellow
Write-Host "Da tao file IPA chuan iTunes tai: $outputIpa" -ForegroundColor Green
Write-Host "File nay san sang de keo tha vao iTunes hoac cac cong cu nap vao iPhone!" -ForegroundColor Cyan
