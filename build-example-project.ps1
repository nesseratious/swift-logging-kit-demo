# Build script for LoggingKitExample on Windows
# This script builds only the LoggingKitExample executable and copies it to Bin/

Write-Host "Building LoggingKitExample..." -ForegroundColor Cyan

# Build the product
swift build --product LoggingKitExample

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Build successful!" -ForegroundColor Green

# Create Bin directory if it doesn't exist
$binDir = "Bin"
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir | Out-Null
    Write-Host "Created Bin directory" -ForegroundColor Yellow
}

# Copy the executable to Bin/
$exePath = ".build\x86_64-unknown-windows-msvc\debug\LoggingKitExample.exe"
$destPath = Join-Path $binDir "LoggingKitExample.exe"

if (Test-Path $exePath) {
    Copy-Item -Path $exePath -Destination $destPath -Force
    Write-Host "Copied LoggingKitExample.exe to Bin/" -ForegroundColor Green
} else {
    Write-Host "Error: Executable not found at $exePath" -ForegroundColor Red
    exit 1
}

Write-Host "Done!" -ForegroundColor Cyan

