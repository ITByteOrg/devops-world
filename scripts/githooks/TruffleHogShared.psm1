function Initialize-TruffleHogLogDir {
    param (
        [string]$BaseDir
    )

    $logDir = Join-Path $BaseDir "logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    return $logDir
}

function Get-GitDiffContent {
    param (
        [string]$DiffType = "cached",
        [string[]]$FileFilters = @("A", "M")
    )

    $diffArgs = @("diff", "--$DiffType", "--name-only", "--diff-filter=$($FileFilters -join '')")
    $files = git @diffArgs | Where-Object { $_ -and (Test-Path $_) }

    return @{
        Files = $files
        GetContent = {
            param ($file)
            git show ":$file"
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
        Write-ErrorLog "TruffleHog scan failed for $SourceDescription"
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
