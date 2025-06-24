#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pre-push hook to run TruffleHog or any additional security checks.

.DESCRIPTION
    This script will be invoked by Git before any push. Customize it
    to include credential scanning, linting, or push validation logic.
#>

# Import shared logging/module utilities if needed
. "$PSScriptRoot/../../scripts/githooks/LoggingUtils.psm1"
. "$PSScriptRoot/../../scripts/githooks/TruffleHogShared.psm1"

Write-Log -Message "🚨 Running pre-push hook..." -Type "info"

# Run the TruffleHog check (custom logic)
Invoke-TrufflehogScan -TargetPath "$PSScriptRoot/../../"

if ($LASTEXITCODE -ne 0) {
    Write-Log -Message "❌ Push blocked due to detected secrets!" -Type "error"
    exit 1
}

Write-Log -Message "✅ Pre-push checks passed!" -Type "success"
exit 0
