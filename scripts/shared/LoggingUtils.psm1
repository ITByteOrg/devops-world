<#
.SYNOPSIS
    Utility module for standardized logging across scripts.

.DESCRIPTION
    Provides emoji-enhanced, color-coded log output for Git hooks and CI workflows.
    Supports optional file logging when enabled by the caller.

.EXPORTS
    Write-Log

#>

function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("info", "warn", "error", "success", "ok", "debug")]
        [string]$Type = "info",

        [switch]$ToFile,

        [string]$LogDir
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

        $prefix = if ($iconMap.ContainsKey($Type)) { "$($iconMap[$Type]) " } else { "" }
        $color  = if ($colorMap.ContainsKey($Type)) { $colorMap[$Type] } else { $colorMap["default"] }

        Write-Host "$prefix$Message" -ForegroundColor $color
    }

    if ($ToFile -and $LogDir) {
        $logFile = Join-Path $LogDir "bootstrap.log"
        if (-not (Test-Path $LogDir)) {
            New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        }

        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logFile -Value "[$timestamp][$Type] $Message"
    }
}
