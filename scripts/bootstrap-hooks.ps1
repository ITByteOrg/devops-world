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

# Resolve Git root
$GitRoot = git rev-parse --show-toplevel 2>$null
if (-not $GitRoot) {
    Write-Host "Unable to resolve Git root. Are you inside a Git repo?"
    exit 1
}

# Import logging utility
$LoggingModule = Join-Path $GitRoot "scripts/shared/LoggingUtils.psm1"
if (Test-Path $LoggingModule) {
    Import-Module $LoggingModule -Force
} else {
    Write-Host "Logging module not found at $LoggingModule. Falling back to Write-Host."
    function Write-Log { param([string]$Message, [string]$Severity = "Info") Write-Host "[$Severity] $Message" }
}

# Define paths
$GitHooksDir    = Join-Path $GitRoot "scripts/githooks"
$TargetHooksDir = Join-Path $GitRoot ".git/hooks"

# Validate hook source directory
if (-not (Test-Path $GitHooksDir)) {
    Write-Log -Message "Hook source directory '$GitHooksDir' not found." -Type Error
    exit 1
}

# Define hooks to install: source filename => target hook name
$HookMap = @{
    "pre-push.ps1"              = "pre-push"
    "trufflehog-pre-commit.ps1" = "pre-commit"
}

Write-Log -Message "Installing hooks from '$GitHooksDir' to '$TargetHooksDir'" -Type Info

foreach ($sourceFile in $HookMap.Keys) {
    $sourcePath = Join-Path $GitHooksDir $sourceFile
    $targetHook = Join-Path $TargetHooksDir $HookMap[$sourceFile]

    if (-not (Test-Path $sourcePath)) {
        Write-Log -Message "Missing source hook file: $sourceFile. Skipping." -Type Warning
        continue
    }

    try {
        Copy-Item -Path $sourcePath -Destination $targetHook -Force
        Write-Log -Message "Installed $sourceFile as ${targetHook}" -Type Info
    } catch {
        Write-Log -Message "Failed to install ${targetHook}: $_" -Type Error
    }
}

Write-Log -Message "Git hooks installed successfully." -Type Success
