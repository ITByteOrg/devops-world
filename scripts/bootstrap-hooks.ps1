#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Git hooks and shared modules into .git/hooks/

.DESCRIPTION
    - Verifies Git, Docker, PowerShell are available
    - Installs any *.ps1 files in scripts/githooks/ as Git hooks
    - Creates a shell wrapper to invoke each hook for cross-platform compatibility
    - Installs shared modules from scripts/shared/
    - Marks scripts executable on Unix systems
#>

$ErrorActionPreference = "Stop"

$RepoRoot       = Resolve-Path "$PSScriptRoot/.."
$GitHooksDir    = "$RepoRoot/.git/hooks"
$HookSourceDir  = "$RepoRoot/scripts/githooks"
$SharedDir      = "$RepoRoot/scripts/shared"

# Import shared modules
Import-Module "$PSScriptRoot/shared/LoggingUtils.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot/shared/TruffleHogShared.psm1" -ErrorAction Stop

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

# Discover *.ps1 hook scripts in the source directory
$hookScripts = Get-ChildItem -Path $HookSourceDir -Filter *.ps1 -File

foreach ($hook in $hookScripts) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($hook.Name)
    $ps1Dest  = Join-Path $GitHooksDir "$baseName.ps1"
    $shDest   = Join-Path $GitHooksDir $baseName

    # Copy the PowerShell script
    Copy-Item $hook.FullName $ps1Dest -Force
    Write-Log "📦 Installed $baseName.ps1 to .git/hooks/" -Type "ok"

    # Create the shell wrapper
    $prefix = '#!/bin/sh'
    $execCmd = 'exec pwsh "$(dirname "$0")/' + $baseName + '.ps1" "$@"'

$wrapperContent = @"
$prefix
$execCmd
"@

    Set-Content -Path $shDest -Value $wrapperContent -Encoding UTF8
    Write-Log "🔧 Created wrapper: $baseName → $baseName.ps1" -Type "ok"

    # Make the wrapper executable (Unix only)
    if ($IsLinux -or $IsMacOS) {
        & chmod +x $shDest
        Write-Log "🔑 Marked $baseName as executable on Unix." -Type "ok"
    }
}

Write-Log "🎯 All Git hooks installed and ready." -Type "info"
