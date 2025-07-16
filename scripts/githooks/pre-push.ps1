#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Git pre-push hook to scan commits about to be pushed using TruffleHog.

.DESCRIPTION
    - Imports shared logging and scan logic
    - Diffs local branch against remote to isolate new changes
    - Blocks push if secrets are detected
#>

$ErrorActionPreference = 'Stop'

# Dynamically set repo root
$scriptRoot = (& git rev-parse --show-toplevel).Trim()
$scriptRoot = Split-Path -Parent $scriptPath
$repoRoot   = Resolve-Path "$scriptRoot/../.."
$sharedPath = Join-Path $repoRoot "scripts/shared"

$DebugPreference = "Continue"

# Import shared modules
Import-Module (Join-Path $sharedPath "LoggingUtils.psm1") -ErrorAction Stop
Import-Module (Join-Path $sharedPath "TruffleHogShared.psm1") -ErrorAction Stop

Write-Log -Message "🚨 Running pre-push hook..." -Type "info"

# Get diff content between remote and local
$diff = Get-GitDiffContent -DiffType "push"
$files = $diff.Files
$getContent = $diff.GetContent

if (-not $files -or $files.Count -eq 0) {
    Write-Log -Message "🟡 Nothing new to push. Skipping secret scan." -Type "warn"
    exit 0
}

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Initialize-TruffleHogLogDir -BaseDir $baseDir
$hadSecrets = $false

foreach ($file in $files) {
    if (Test-FileHasMeaningfulContent $file) {
        $content = $getContent.Invoke($file)

        $result = Invoke-TrufflehogScan -Content $content -FileName $file -LogDir $logDir

        if ($result.HasSecrets) {
            $hadSecrets = $true
            Write-Log -Message "🔒 Secret detected in $file" -Type "error"
        } else {
            Write-Log -Message "✅ Clean: $file" -Type "ok"
        }
    } else {
        Write-Log -Message "⏭️ Skipped (empty/untracked): $file" -Type "debug"
    }
}

if ($hadSecrets) {
    Write-Log -Message "⛔ Push aborted: Secrets were found in files above." -Type "error"
    exit 1
} else {
    Write-Log -Message "🎉 All clear! No secrets detected. Proceeding with push." -Type "success"
    exit 0
}
