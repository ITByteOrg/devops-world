<#
.SYNOPSIS
  Executes a TruffleHog scan based on the Git hook type.

.DESCRIPTION
  Central entry point used by pre-commit, pre-push, and commit-msg hook wrappers.
  Dynamically selects diff strategy, runs scan, and returns clean status.
#>

Import-Module "$PSScriptRoot/Shared-Utils.psm1"

function Get-GitDiffContent {
    param (
        [ValidateSet('cached', 'push')]
        [string]$DiffType
    )

    switch ($DiffType) {
        'cached' {
            return git diff --cached
        }
        'push' {
            # avoid syntax issues by using full symbolic ref instead of shorthand '@'
            $localRef = git rev-parse HEAD
            $remoteRef = git rev-parse 'HEAD@{u}'
            return git diff $remoteRef $localRef
        }
    }
}

function Invoke-TrufflehogScan {
    param (
        [string]$Content
    )

    $tempFile = New-TemporaryFile
    Set-Content -Path $tempFile -Value $Content -Encoding UTF8

    $dockerCmd = @(
        "docker run --rm",
        "-v $PWD:/pwd",
        "--entrypoint trufflehog",
        "ghcr.io/trufflesecurity/trufflehog:latest",
        "filesystem /pwd/$($tempFile.Name)",
        "--json"
    ) -join " "

    try {
        $result = Invoke-Expression $dockerCmd
        $hasSecrets = $result -and ($result | ConvertFrom-Json).Count -gt 0
        return @{
            IsClean = -not $hasSecrets
            RawOutput = $result
        }
    } catch {
        Write-StdLog "TruffleHog scan failed: $_" -Type "error"
        return @{ IsClean = $false; RawOutput = $null }
    } finally {
        Remove-Item $tempFile -Force
    }
}

function Run-TrufflehogHookScan {
    param (
        [ValidateSet('pre-commit', 'pre-push', 'commit-msg')]
        [string]$HookType
    )

    Write-Log "Starting TruffleHog scan for hook type: $HookType" -Level "Info"

    switch ($HookType) {
        'pre-commit' {
            $diffContent = Get-GitDiffContent -DiffType 'cached'
        }
        'pre-push' {
            $diffContent = Get-GitDiffContent -DiffType 'push'
        }
        'commit-msg' {
            $diffContent = git show HEAD | Out-String
        }
        default {
            Write-Log "Unknown hook type: $HookType" -Level "Error"
            return $false
        }
    }

    if (-not $diffContent.Trim()) {
        Write-Log "No content to scan for $HookType" -Level "Info"
        return $true
    }

    $scanResult = Invoke-TrufflehogScan -Content $diffContent
    if ($scanResult.IsClean) {
        Write-Log "No secrets found for $HookType scan." -Level "Success"
        return $true
    } else {
        Write-Log "Secrets detected during $HookType scan!" -Level "Error"
        return $false
    }
}

Export-ModuleMember -Function Run-TrufflehogHookScan, Get-GitDiffContent, Invoke-TrufflehogScan
