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

try {
    Import-Module "$PWD/scripts/modules/shared-utils.psm1" -Force
    $gitRoot = Resolve-RepoRoot
} catch {
    Write-StdLog "Failed to import shared utilities: $($_.Exception.Message)" -Type "error"
    exit 1
}

Write-Log "Branch checkout detected — repo root: $gitRoot" -Type "info"
Write-StdLog "Git branch or file checkout completed." -Type "info"
