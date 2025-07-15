#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Git pre-commit hook to scan staged files for secrets using TruffleHog via Docker.
.DESCRIPTION
    - Scans staged files using `git diff --cached` and pipes them to TruffleHog.
    - Uses stdin scanning for compatibility with Dockerized TruffleHog.
    - Blocks commit if secrets are detected or TruffleHog returns an error.
    - Skips deleted or empty staged files.
.NOTES
    Requires Docker, PowerShell Core, LoggingUtils.psm1, and WSL-compatible paths.
#>

#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

# Dynamically set repo root
$BasePath = (& git rev-parse --show-toplevel).Trim()
Write-Host "🔍 pre-commit hook BasePath: '$BasePath'"
if (-not $BasePath) {
    Write-Host "❌ Failed to resolve repo root. Aborting pre-commit hook."
    exit 1
}

# Dot-source shared function
. "$BasePath/scripts/shared/Resolve-ModulePath.ps1"

# Confirm function loaded
if (-not (Get-Command Resolve-ModulePath -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Resolve-ModulePath not found. Verify dot-sourcing line."
    exit 1
}

# Resolve module path
$TruffleHogSharedPath = Resolve-ModulePath -ModuleName "TruffleHogShared.psm1" -BaseDir $BasePath

if (-not $TruffleHogSharedPath) {
    Write-Host "❌ Failed to resolve TruffleHogShared.psm1. Skipping scan."
    exit 1
}

# Confirm path exists before import
if (-not (Test-Path $TruffleHogSharedPath)) {
    Write-Host "❌ Resolved path does not exist: $TruffleHogSharedPath"
    exit 1
}

# Load module
Import-Module $TruffleHogSharedPath -Force

# Retrieve staged files and log directory
$diffInfo = Get-GitDiffContent -DiffType "cached"
$LogDir   = Initialize-TruffleHogLogDir -BaseDir $BasePath

$foundSecrets = $false

foreach ($file in $diffInfo.Files) {
    if (Test-FileHasMeaningfulContent -FilePath $file) {
        $content = $diffInfo.GetContent.Invoke($file)
        $scanResult = Invoke-TruffleHogScan -Content $content -SourceDescription $file -LogDir $LogDir

        if ($scanResult.HasSecrets) {
            Write-Host "❌ Secrets detected in: $file"
            $foundSecrets = $true
        }
    }
}

if ($foundSecrets) {
    Write-Host "❌ Commit blocked due to verified secrets."
    exit 1
}

Write-Host "✅ TruffleHog scan passed: no secrets found."
exit 0
