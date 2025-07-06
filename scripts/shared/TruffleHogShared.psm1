<#
.SYNOPSIS
    Shared helper functions for running TruffleHog secret scans.

.DESCRIPTION
    Encapsulates logic for:
        - Initializing scan log directories
        - Normalizing file content for scanning
        - Invoking TruffleHog with consistent parameters
    Designed for use in Git hook scripts and automated security scans.

.EXPORTS
    Initialize-TruffleHogLogDir
    Invoke-TrufflehogScan
    Test-FileHasMeaningfulContent

.NOTES
    Assumes the calling script resolves and passes a valid `BaseDir` path if not run directly.
#>

# Import shared modules
Import-Module (Join-Path $sharedPath "LoggingUtils.psm1") -ErrorAction Stop

if (-not $BaseDir) {
    $BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Initialize-TruffleHogLogDir {
    param (
        [string]$BaseDir
    )

    if (-not $BaseDir) {
        throw "❌ BaseDir is null — can't resolve log directory."
    }

    $logDir = Join-Path $BaseDir "logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    return $logDir
}

function Get-GitDiffContent {
    param (
        [ValidateSet("cached", "push")]
        [string]$DiffType = "cached"
    )

    if ($DiffType -eq "cached") {
        $files = git diff --cached --name-only | Where-Object { Test-Path $_ }

        return @{
            Files = $files
            GetContent = { param($file) Get-Content $file -Raw }
        }
    }

    if ($DiffType -eq "push") {
        # Get current and upstream branches
        $localBranch  = git symbolic-ref --short HEAD
        $remoteBranch = "origin/$localBranch"

        # Ensure remote is up to date
        git fetch origin $localBranch

        # Collect all files changed between the remote and local branches
        $files = git diff --name-only $remoteBranch $localBranch | Where-Object { Test-Path $_ }

        return @{
            Files = $files
            GetContent = { param($file) Get-Content $file -Raw }
        }
    }
}


function Test-FileHasMeaningfulContent {
    param (
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {
        return $false
    }

    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    return ($content -match '\S')
}

function Invoke-TruffleHogScan {
    param (
        [string]$Content,
        [string]$SourceDescription,
        [string]$LogDir,
        [string[]]$ExcludeDetectors = @()
    )

    $dockerArgs = @(
        "run", "--rm", "-i",
        "--network", "none",
        "trufflesecurity/trufflehog:latest",
        "stdin",
        "--only-verified",
        "--json",
        "--source-name", $SourceDescription
    )

    foreach ($detector in $ExcludeDetectors) {
        $dockerArgs += @("--exclude-detectors", $detector)
    }

    try {
        $result = $Content | docker @dockerArgs 2>&1
        $hasSecrets = $result -match '"verified":\s*true'
        return @{
            HasSecrets = $hasSecrets
            HasError = $false
            Raw = $result
        }
    } catch {
        Write-Log -Message ("Scan failed for {0}. Error: {1}" -f $SourceDescription, $_) -Type "error"
        return @{
            HasSecrets = $false
            HasError = $true
            Raw = $_.Exception.Message
        }
    }
}

function Test-BinFilesForCRLF {
    param (
        [string[]]$BinFiles
    )

    $crlfFound = $false

    foreach ($file in $BinFiles) {
        if (-not (Test-Path $file)) { continue }

        $lines = Get-Content $file -AsByteStream -Raw
        if ($lines -match "`r`n") {
            Write-WarnLog "CRLF line endings found in: $file"
            $crlfFound = $true
        }
    }

    return $crlfFound
}
