#!/usr/bin/env pwsh
<#
.SYNOPSIS
Runs TruffleHog scan before a Git push to detect and block secrets in committed content.

.DESCRIPTION
This hook script is executed prior to a Git push. It imports shared utilities and TruffleHog scanning modules,
ensuring they are available and properly initialized. If secrets are found in the latest commit range, the
push is blocked to prevent leakage. Logging is performed using Write-Log and Write-StdLog functions.

Module loading errors or missing required functions will fail the hook with diagnostic output.

.NOTES
Requirements : TruffleHog CLI, shared-utils.psm1, TruffleHogHookScanner.psm1

.EXAMPLE
& .\pre-push.ps1
Triggers scan before pushing changes to remote Git repository.
#>

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Resolve repo paths
$gitRoot = (& git rev-parse --show-toplevel).Trim()
$moduleBase = Join-Path $gitRoot "scripts/modules"

# Load modules
try {
    Import-Module (Join-Path $moduleBase "shared-utils.psm1") -Force
    Import-Module (Join-Path $moduleBase "TruffleHogHookScanner.psm1") -Force
} catch {
    Write-StdLog "Failed to import modules: $($_.Exception.Message)" -Type "error"
    Write-StdLog "Stack trace: $($_.ScriptStackTrace)" -Type "error"
    exit 1
}

# Run scan
try {
    $scanResult = Invoke-TruffleHogHookScan -HookType pre-push

    if ($scanResult -isnot [hashtable]) {
        Write-Log "Scan failed due to environment issue (e.g., Docker not running)." -Type error
        exit 1
    }

    if (-not $scanResult.IsClean) {
        Write-Log "Secrets detected — blocking push!" -Type error
        exit 1
    }

    Write-Log "No secrets found — proceeding with push." -Type info
} catch {
    Write-Log "Unexpected error during scan: $($_.Exception.Message)" -Type error
    exit 1
}
