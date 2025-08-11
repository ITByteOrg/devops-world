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

        # Ensure Docker is ready
        if (-not (Test-DockerReady)) {
            Write-Log "Docker is not running. Please start Docker Desktop or your Docker daemon." "warn"
            exit 1
        }
    } catch {
        Write-Host "[WARN] Failed to import shared utilities: $($_.Exception.Message)"
    }
} else {
    Write-Host "[WARN] SharedUtils.psm1 not found at $SharedUtilsPath"
}

if (Get-Command Write-StdLog -ErrorAction SilentlyContinue) {
    Write-Log "Post-checkout hook triggered for ref $args[1]" "info"
} else {
    Write-Host "[WARN] Write-Log not available—skipping structured logging"
}
