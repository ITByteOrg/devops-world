#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Git post-checkout hook that runs after branch changes or file checkouts.

.DESCRIPTION
    - Imports shared utilities for logging and path resolution
    - Logs checkout event and repo root
    - Future-ready for initializing environments or showing status banners
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$RepoRoot = git rev-parse --show-toplevel
$SharedUtilsPath = "$RepoRoot/scripts/modules/SharedUtils.psm1"

if (Test-Path $SharedUtilsPath) {
    try {
        Import-Module $SharedUtilsPath -Force
    } catch {
        Write-Host "[WARN] Failed to import shared utilities: $($_.Exception.Message)"
    }
} else {
    Write-Host "[WARN] SharedUtils.psm1 not found at $SharedUtilsPath"
}

if (Get-Command Write-StdLog -ErrorAction SilentlyContinue) {
    Write-StdLog "Post-checkout hook triggered for ref $args[1]" "info"
} else {
    Write-Host "[WARN] Write-StdLog not available—skipping structured logging"
}
