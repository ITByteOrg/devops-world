#!/usr/bin/env pwsh
# Hook: pre-push.ps1
# Purpose: Run TruffleHog scan before Git push to catch secrets

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# figure out where the repo lives 
$gitRoot = (& git rev-parse --show-toplevel).Trim()
$moduleBase = Join-Path $gitRoot "scripts/modules"

try {
    Import-Module (Join-Path $moduleBase "shared-utils.psm1") -Force
    Import-Module (Join-Path $moduleBase "TruffleHogHookScanner.psm1") -Force
} catch {
    Write-StdLog "Failed to import modules: $($_.Exception.Message)" -Type "error"
    Write-StdLog "Stack trace: $($_.ScriptStackTrace)" -Type "error"
    exit 1
}

$requiredFunctions = @('Resolve-RepoRoot', 'Write-Log', 'Invoke-TruffleHogHookScan')
foreach ($func in $requiredFunctions) {
    if (-not (Get-Command $func -ErrorAction SilentlyContinue)) {
        Write-StdLog "Required function '$func' is not available after loading modules." -Type "error"
        Write-StdLog "Available commands:" -Type "info"
        Get-Command | Where-Object { $_.Source -like "*shared-utils*" -or $_.Source -like "*TruffleHog*" } | 
            ForEach-Object { Write-Host "  $($_.Name)" -ForegroundColor Gray }
        exit 1
    }
}

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

    Write-Log "No secrets found—proceeding with push." -Type info

} catch {
    Write-Log "Unexpected error during scan: $($_.Exception.Message)" -Type error
    exit 1
}
