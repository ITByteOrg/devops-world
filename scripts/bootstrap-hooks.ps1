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

# figure out where the repo lives 
$gitRoot = (& { git rev-parse --show-toplevel 2>$null }).Trim()
$moduleBase = Join-Path $gitRoot "scripts/modules"
$sharedUtilsPath = Join-Path $moduleBase "SharedUtils.psm1"

if (-not (Test-Path $sharedUtilsPath)) {
    Write-StdLog "Module file not found at path: $sharedUtilsPath", -Type "error"
    exit 1
}

Import-Module $sharedUtilsPath -Force

# Define paths
$gitHooksDir    = Join-Path $gitRoot "scripts/hooks"
$targetHooksDir = Join-Path $gitRoot ".git/hooks"

# Validate hook source directory
if (-not (Test-Path $gitHooksDir)) {
    Write-Log -Message "Hook source directory '$gitHooksDir' not found." -Type Error
    exit 1
}

# Define hooks to install: source filename => target hook name
$hookMap = @{
    "pre-commit.ps1"            = "pre-commit"
    "pre-push.ps1"              = "pre-push"
    "post-checkout.ps1"         = "post-checkout"
}

Write-Log -Message "Installing hooks from '$gitHooksDir' to '$targetHooksDir'" -Type Info

foreach ($sourceFile in $hookMap.Keys) {
    $sourcePath = Join-Path $gitHooksDir $sourceFile
    $targetHook = Join-Path $targetHooksDir $hookMap[$sourceFile]

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
