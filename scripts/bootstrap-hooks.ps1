#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Git hooks and shared modules into .git/hooks/

.DESCRIPTION
    - Verifies Git, Docker, PowerShell are available
    - Copies hook scripts from scripts/githooks/ into .git/hooks/
    - Installs post-checkout to reapply hooks automatically
    - Marks executables on macOS/Linux
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path "$PSScriptRoot\.."
$GitHooksDir = "$RepoRoot\.git\hooks"
$HookSourceDir = "$RepoRoot\scripts\githooks"
$ExpectedFiles = @("pre-push.ps1", "TruffleHogShared.psm1", "post-checkout")

# Import centralized logger
Import-Module "$PSScriptRoot\LoggingUtils.psm1" -ErrorAction Stop

Write-Log "🔍 Verifying environment..." -Type "info"

function Test-Tool($name, $command) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Log "$name not found! Please install." -Type "error"
        exit 1
    } else {
        Write-Log "$name found." -Type "ok"
    }
}

Test-Tool "Git" "git"
Test-Tool "Docker" "docker"
Test-Tool "PowerShell Core" "pwsh"

Write-Log "📂 Installing Git hooks..." -Type "info"

foreach ($file in $ExpectedFiles) {
    $src = Join-Path $HookSourceDir $file
    $dst = Join-Path $GitHooksDir $file

    if (-not (Test-Path $src)) {
        Write-Log "Missing hook file: $file" -Type "error"
        exit 1
    }

    Copy-Item $src $dst -Force
    Write-Log "Installed $file to .git/hooks/" -Type "ok"
}

if ($IsLinux -or $IsMacOS) {
    foreach ($file in $ExpectedFiles){
        $hookPath = Join-Path $GitHooksDir $file
        & chmod +x $hookPath
    }
    Write-Log "Marked hook scripts as executable on Unix." -Type "ok"
}

Write-Log "🎯 All Git hooks installed and post-checkout auto-sync enabled." -Type "ok"
