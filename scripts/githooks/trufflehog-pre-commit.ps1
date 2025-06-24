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

$ErrorActionPreference = 'Stop'

# Import logging module
$LogModulePath = Join-Path $PSScriptRoot "../shared/LoggingUtils.psm1"
if (-not (Test-Path $LogModulePath)) {
    Write-Log "❌ Missing LoggingUtils.psm1 at: $LogModulePath" -Type "error"
    exit 1
}
Import-Module $LogModulePath -Force

# Import shared TruffleHog logic
$SharedModulePath = Join-Path $PSScriptRoot "../shared/TruffleHogShared.psm1"
if (-not (Test-Path $SharedModulePath)) {
    Write-Log "❌ Could not find TruffleHogShared.psm1 at: $SharedModulePath" -Type "error"
    exit 1
}
Import-Module $SharedModulePath -Force

# Initialize
$exitCode = 0
$logDir = Initialize-TruffleHogLogDir -BaseDir $PSScriptRoot

# Get staged files (added or modified only, skip deleted)
$diffInfo = Get-GitDiffContent -DiffType "cached" -FileFilters @("A", "M")
$stagedFiles = $diffInfo.Files
$getContentFunc = $diffInfo.GetContent

foreach ($file in $stagedFiles) {
    if (-not (Test-Path $file)) {
        Write-Log "[SKIP] $file does not exist on disk. Probably deleted or untracked." -Type "warn"
        continue
    }

    if (-not (Test-FileHasMeaningfulContent -FilePath $file)) {
        Write-Log "[SKIP] $file has no meaningful content. Skipping." -Type "warn"
        continue
    }

    Write-Log "Scanning: $file" -Type "info"
    $fileContent = & $getContentFunc $file

    $scanResult = Invoke-TruffleHogScan `
    -Content $fileContent `
    -SourceDescription $file `
    -LogDir $logDir `
    -ExcludeDetectors @("SlackWebhook")

    if ($scanResult.HasSecrets -or $scanResult.HasError) {
        Write-Log "Potential secret detected in: $file" -Type "error"
        $exitCode = 1
    }
}

# Check for CRLF in bin scripts
$binFiles = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -like 'bin/*' }

if ($binFiles.Count -gt 0) {
    $crlfFail = Test-BinFilesForCRLF -BinFiles $binFiles
    if ($crlfFail) {
        Write-Log "CRLF line endings detected in one or more bin/ files." -Type "error"
        $exitCode = 1
    }
}

if ($exitCode -eq 0) {
    Write-Log "✅ Pre-commit checks passed!" -Type "ok"
} else {
    Write-Log "❌ Pre-commit checks failed!" -Type "error"
}

exit $exitCode
