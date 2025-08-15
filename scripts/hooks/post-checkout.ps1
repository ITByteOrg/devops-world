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
$VerboseMode = $env:GIT_HOOK_VERBOSE -eq "true"
$SharedUtilsPath = "$RepoRoot/scripts/modules/SharedUtils.psm1"

if (Test-Path $SharedUtilsPath) {
    try {
        Import-Module $SharedUtilsPath -Force -ErrorAction SilentlyContinue

        # Dispatcher call
        $Status = Test-HookContext -RepoRoot $RepoRoot -VerboseMode $VerboseMode
        $OldBranch = git name-rev --name-only $args[0]
        $NewBranch = git name-rev --name-only $args[1]

        # Conditional logic based on results
        if ($Status.EnvMissing -contains "Docker (not running)") {
            Write-Host "⏭️ Skipping Docker-dependent tasks."
            return
        }

        if ($Status.ToolMissing -contains "trufflehog") {
            Write-Host "⏭️ Skipping secret scan — trufflehog not available."
        }
    } catch {
        Write-Host "[WARN] Failed to import shared utilities: $($_.Exception.Message)"
    }
} else {
    Write-Host "[WARN] SharedUtils.psm1 not found at $SharedUtilsPath"
}

if (Get-Command Write-StdLog -ErrorAction SilentlyContinue) {
    Write-Log "Checked out from $OldBranch to $NewBranch" -Type "info"
} else {
    Write-Host "[WARN] Write-Log not available—skipping structured logging"
}
