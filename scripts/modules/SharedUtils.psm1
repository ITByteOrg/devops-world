<#
.SYNOPSIS
  Shared utility functions for hook initialization, repo resolution, and logging.

.DESCRIPTION
  Provides modular tools for scanning variables, resolving paths, importing modules,
  and emitting consistent log output. Used across Git hooks and automation scripts.
#>

function Get-CustomPrompt {
    $esc = "`e"
    $venv = if ($env:VIRTUAL_ENV) { "($([System.IO.Path]::GetFileName($env:VIRTUAL_ENV)))" } else { "" }
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    $branchText = if ($gitBranch) { "[$gitBranch]" } else { "" }
    $cwd = Get-Location
    return "$esc[32m$venv $esc[34m$cwd $esc[33m$branchText$esc[0m > "
}


function Write-Log {
    <#
    .SYNOPSIS
        Utility module for standardized logging across scripts.

    .DESCRIPTION
        Provides emoji-enhanced, color-coded log output for Git hooks and CI workflows.
        Supports optional file logging when enabled by the caller.

    .EXPORTS
        Write-Log

    #>
    param (
    [Parameter(Mandatory)] 
    [string]$Message,

    [string]$Type = "info",  # Default to 'info' like Bash

    [switch]$ToFile,
    [string]$LogDir,
    [string]$LogName
    )
    $global:IsCI = $env:CI -or $env:GITHUB_ACTIONS -or $env:BUILD_BUILDID

    if (-not $IsCI) {
        $iconMap = @{
            info    = "[INFO]";      warn    = "[WARN]"
            error   = "[ERROR]";     success = "[SUCCESS]"
            ok      = "[OK]";        debug   = "[DEBUG]"
        }
        $colorMap = @{
            info    = "Cyan"; warn    = "Yellow"; error  = "Red"
            success = "Green"; ok     = "Green";  debug  = "Gray"
            default = "White"
        }

        $prefix = if ($iconMap.ContainsKey($Type)) { "$($iconMap[$Type]) " } else { "[$Type] " }
        $color  = if ($colorMap.ContainsKey($Type)) { $colorMap[$Type] } else { $colorMap["default"] }

        Write-Host "$prefix$Message" -ForegroundColor $color
    }

    # If running in CI, write to the standard output
    if ($ToFile -and $LogDir) {
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }

    $scriptName = $MyInvocation.ScriptName
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($scriptName)
    $logFileName = if ($LogName) { $LogName } else { "$baseName.log" }
    $logFile = Join-Path $LogDir $logFileName

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $cleanMessage = $Message -replace "`e\[[0-9;]*[a-zA-Z]", ""
    Add-Content -Path $logFile -Value "[$timestamp][$Type] $cleanMessage"
    }
}

function Write-StdLog {
   <#
    .SYNOPSIS
        Minimalist console output with structured icons and color. Wrapper for Write-Log.

    .DESCRIPTION
        Provides single-line messaging aligned with Write-Log styling,
        minus file output and CI awareness. Ideal for Git hooks and ad hoc scripts.

    .PARAMETER Message
        The text to display.

    .PARAMETER Type
        Log level indicator: info, warn, error, success, ok, debug.
    #>    
    param (
        [Parameter(Mandatory)][string]$Message,
        [string]$Type = "info"
    )
    Write-Log -Message $Message -Type $Type
}


function Resolve-RepoRoot {
    <#
    .SYNOPSIS
    Returns the absolute path to the root of the Git repository.

    .DESCRIPTION
    Uses git rev-parse to get the repository root path.
    More reliable than traversing directories manually.
    #>
    param (
        [string]$StartPath = (Get-Location).Path
    )

    try {
        # Ask Git for the absolute path to the working-tree root
        $root = git rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $root) {
            throw "Unable to determine repo root via git rev-parse"
        }
        return $root.Trim()
    }
    catch {
        # Fallback to directory traversal if git command fails
        $currentPath = Resolve-Path $StartPath
        while ($currentPath -ne [System.IO.Path]::GetPathRoot($currentPath)) {
            if (Test-Path "$currentPath/.git") {
                return $currentPath
            }
            $currentPath = [System.IO.Path]::GetDirectoryName($currentPath)
        }
        throw "Could not locate Git repository root from: $StartPath"
    }
}

function Resolve-ModulePath {
    <#
    .SYNOPSIS
    Resolves the absolute path to a shared PowerShell module relative to the current script.

    .DESCRIPTION
    This function sets the script’s location as the working directory, then constructs and resolves
    the path to a given `.psm1` module within the repo’s `shared` directory.

    Use this to reliably locate shared hook utilities (e.g., LoggingUtils.psm1, TruffleHogShared.psm1)
    from any Git hook or CI context, regardless of shell quirks.

    .PARAMETER ModuleName
    The name of the target module file (e.g., 'LoggingUtils.psm1').

    .OUTPUTS
    String path to the resolved module file.

    .NOTES
    Designed for use within Git hook scripts and CI wrappers. Ensures portability across WSL, Windows,
    and POSIX environments. Provides clear failure messaging if the module cannot be resolved.
    #>
    param (
        [string]$ModuleName,
        [string]$BaseDir
    )
    if (-not $BaseDir) {
        Write-Host "❌ Resolve-ModulePath: BaseDir is null or empty."
        return $null
    }
    # Wrap it with a null check
    if (-not $BaseDir) {
        Write-Host "⚠️ BaseDir is null before BaseDir concat."
        return $null
    }

    $RawPath = "$BaseDir/scripts/shared/$ModuleName"
    if (-not (Test-Path $RawPath)) {
        Write-Host "❌ Resolve-ModulePath: Module not found at path: $RawPath"
        return $null
    }

    try {
        $ResolvedPath = Resolve-Path $RawPath
        return $ResolvedPath.Path
    } catch {
        Write-Host "❌ Resolve-ModulePath: Failed to resolve path: $($_.Exception.Message)"
        return $null
    }
}

function Test-DockerReady {
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) { return $false }

    try {
        $null = docker info | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Test-DockerAvailable {
    return (Get-Command docker -ErrorAction SilentlyContinue) -and 
           ($null -ne (docker info -ErrorAction SilentlyContinue))
}

Export-ModuleMember -Function `
    Resolve-RepoRoot, `
    Resolve-ModulePath, `
    Write-Log, `
    Write-StdLog, `
    Get-CustomPrompt, `
    Test-DockerReady
