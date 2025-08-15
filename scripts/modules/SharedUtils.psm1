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

function Get-TruffleHogImage {
    return "ghcr.io/trufflesecurity/trufflehog:3.89.2"
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

function Test-HookEnvironment {
    param (
        [string]$RepoRoot,
        [bool]$VerboseMode = $false
    )

    $Missing = @()
    $ProfilePath = Join-Path $RepoRoot "scripts/profiles/profile.ps1"
    $SharedUtilsPath = Join-Path $RepoRoot "scripts/modules/SharedUtils.psm1"

    # Check required files
    if (-not (Test-Path $ProfilePath)) {
        $Missing += "profile.ps1"
        if ($VerboseMode) { Write-Warning "Missing: $ProfilePath" }
    }

    if (-not (Test-Path $SharedUtilsPath)) {
        $Missing += "SharedUtils.psm1"
        if ($VerboseMode) { Write-Warning "Missing: $SharedUtilsPath" }
    }

    # Check function availability
    if (-not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
        $Missing += "Write-Log"
        if ($VerboseMode) { Write-Warning "Function Write-Log not available" }
    }

    # Check Docker readiness
    if (-not (Test-DockerReady)) {
        $Missing += "Docker (not running)"
        if ($VerboseMode) { Write-Warning "Docker is not running or unreachable" }
    }

    # Summary output
    if ($VerboseMode) {
        if ($Missing.Count -eq 0) {
            Write-Host "✅ Hook environment validated successfully."
        } else {
            Write-Host "⚠️ Hook environment incomplete: $($Missing -join ', ')"
        }
    }

    return $Missing
}

function Test-DockerReady {
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $dockerCmd) {
        return $false
    }

    $output = docker info 2>&1
    if ($output -match "could not be found in this WSL 2 distro") {
        Write-Log "Docker not integrated with WSL. Please enable WSL integration in Docker Desktop." "warn"
        return $false
    }

    return $LASTEXITCODE -eq 0
}

function Test-DockerAvailable {
    return (Get-Command docker -ErrorAction SilentlyContinue) -and 
           ($null -ne (docker info -ErrorAction SilentlyContinue))
}

function Test-HookContext {
    <#
    .SYNOPSIS
    Validates the hook environment and required CLI tools.

    .DESCRIPTION
    Runs both Test-HookEnvironment and Test-ToolReady to check for required files,
    functions, Docker readiness, and external tools. Returns a structured object
    with missing items for conditional logic in hook scripts.

    .PARAMETER RepoRoot
    The root directory of the repository (typically from git rev-parse).

    .PARAMETER Tools
    An array of CLI tools to check for availability (e.g., git, python, trufflehog).

    .PARAMETER VerboseMode
    If true, prints warnings and status messages to the console.

    .OUTPUTS
    [hashtable] with two keys:
        EnvMissing  - array of missing environment components
        ToolMissing - array of missing CLI tools

    .EXAMPLE
    $Status = Test-HookContext -RepoRoot $RepoRoot -Tools @("git", "trufflehog") -VerboseMode $true

    if ($Status.EnvMissing -contains "Docker (not running)") {
        Write-Host "Skipping Docker-dependent tasks."
        return
    }

    if ($Status.ToolMissing -contains "trufflehog") {
        Write-Host "Skipping secret scan — trufflehog not available."
    }
    #>
    param (
        [string]$RepoRoot,
        [string[]]$Tools = @("git", "python", "trufflehog"),
        [bool]$VerboseMode = $false
    )

    $EnvMissing = Test-HookEnvironment -RepoRoot $RepoRoot -VerboseMode $VerboseMode
    $ToolMissing = Test-ToolReady -Tools $Tools -VerboseMode $VerboseMode

    return @{
        EnvMissing  = $EnvMissing
        ToolMissing = $ToolMissing
    }
}

function Test-ToolReady {
    param (
        [string[]]$Tools = @("git", "python", "trufflehog"),
        [bool]$VerboseMode = $false
    )

    $MissingTools = @()

    foreach ($Tool in $Tools) {
        if (-not (Get-Command $Tool -ErrorAction SilentlyContinue)) {
            $MissingTools += $Tool
            if ($VerboseMode) {
                Write-Warning "$Tool not found in PATH"
            }
        }
    }

    if ($VerboseMode) {
        if ($MissingTools.Count -eq 0) {
            Write-Host "✅ All requested tools are available."
        } else {
            Write-Host "⚠️ Missing tools: $($MissingTools -join ', ')"
        }
    }

    return $MissingTools
}

Export-ModuleMember -Function `
    Get-CustomPrompt, `
    Get-TruffleHogImage, `
    Resolve-ModulePath, `
    Resolve-RepoRoot, `
    Test-DockerReady, `
    Test-HookContext, `
    Test-HookEnvironment, `
    Write-Log, `
    Write-StdLog

     