$global:IsCI = $env:CI -or $env:GITHUB_ACTIONS -or $env:BUILD_BUILDID

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("info", "ok", "warn", "error", "debug")]
        [string]$Type = "info",
        [switch]$ToFile
    )

    # Emoji and color setup
    if (-not $IsCI) {
        $iconMap = @{
            info  = "[INFO]"
            ok    = "[OK]"
            warn  = "[WARN]"
            error = "[ERROR]"
            debug = "[DEBUG]"
        }        
        $colorMap = @{
            info  = "Gray"
            ok    = "Green"
            warn  = "Yellow"
            error = "Red"
            debug = "DarkGray"
        }
    } else {
        $iconMap = @{}
        $colorMap = @{ default = "White" }
    }

    $prefix = if ($iconMap.ContainsKey($Type)) { "$($iconMap[$Type]) " } else { "" }
    $color = if ($colorMap.ContainsKey($Type)) { $colorMap[$Type] } else { $colorMap["default"] }


    Write-Host "$prefix$Message" -ForegroundColor $color

    if ($ToFile) {
        $logDir = Join-Path $PSScriptRoot "logs"
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }

        $logFile = Join-Path $logDir "bootstrap.log"
        $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Add-Content -Path $logFile -Value "[$timestamp][$Type] $Message"
    }
}
