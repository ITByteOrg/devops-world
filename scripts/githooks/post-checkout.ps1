#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Auto-installs Git hooks if missing after branch checkout
#>

$ErrorActionPreference = "SilentlyContinue"

# Relative paths
$repoRoot = Resolve-Path "$PSScriptRoot\..\.."
$hookDir = "$repoRoot\.git\hooks"
$expected = @("pre-commit", "pre-push.ps1")
$missing = @()

# Import shared logging/module utilities if needed
. "$PSScriptRoot/../shared/LoggingUtils.psm1"
. "$PSScriptRoot/../shared/TruffleHogShared.psm1"

foreach ($file in $expected) {
    $path = Join-Path $hookDir $file
    if (-not (Test-Path $path)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {

    Write-Log -Message "🛠️  Detected missing Git hooks: $($missing -join ', ')" -Type "info"
    Write-Log -Message "🔧 Attempting to re-run scripts/bootstrap-hooks.ps1..." -Type "info"

    $bootstrap = "$repoRoot\scripts\bootstrap-hooks.ps1"
    if (Test-Path $bootstrap) {
        & pwsh $bootstrap
    } else {
        Write-Log -Message "❌ Cannot find bootstrap-hooks.ps1. Please run it manually." -Type "error"
    }
}
