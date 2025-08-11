#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Pre-commit hook wrapper for TruffleHog secret scanning.

.DESCRIPTION
  Imports the centralized hook scanner module and invokes a scan
  against staged changes using TruffleHog. Aborts commit if secrets are found.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    Import-Module "$PWD/scripts/modules/SharedUtils.psm1" -Force

    Write-StdLog "Current directory before scan: $(Get-Location)" -Type debug
    $InitialDir = Get-Location

    $gitRoot = Resolve-RepoRoot
    Import-Module "$gitRoot/scripts/modules/TruffleHogHookScanner.psm1" -Force
} catch {
    Write-StdLog "Failed to load TruffleHog scanner module: $_" -Type "error"
    exit 1
}

if (-not (Invoke-TruffleHogHookScan -HookType 'pre-commit')) {
    Write-StdLog "Secret detected — blocking commit!" -Type "error"
    exit 1
}

Write-StdLog "TruffleHog scan passed — proceeding with commit." -Type "success"
Set-Location $InitialDir
Write-StdLog "Current directory after scan: $(Get-Location)" -Type debug
exit 0
