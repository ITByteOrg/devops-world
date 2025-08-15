<#
.SYNOPSIS
  Executes a TruffleHog scan based on the Git hook type.

.DESCRIPTION
  Primary entry point for Git hook wrappers: pre-commit, pre-push, and commit-msg.
  Dynamically selects the appropriate diff strategy, executes TruffleHog scan, and returns a clean status.
  Manages repository context, exclusion rules, and scan orchestration.
  Relies on shared utilities from TruffleHogShared.psm1.
#>

# modules are always Imported so $PSScriptRoot will resolve correctly

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
            $localRef = git rev-parse HEAD
            $remoteRef = git rev-parse 'HEAD@{u}'
            return git diff $remoteRef $localRef
        }
    }
}

function Invoke-TruffleHogScan {
    param (
        [string]$Content,
        [string]$Image
    )

Write-Log "Caller: $($MyInvocation.InvocationName)" -Type debug


    $tempFilePath = Join-Path -Path $PWD -ChildPath ("scan-" + [guid]::NewGuid().ToString() + ".tmp")
    Set-Content -Path $tempFilePath -Value $Content -Encoding UTF8

    $scanResult = $null  

    try {
        # Docker availability check
        $dockerAvailable = $false
        try {
            & docker version | Out-Null
            $dockerAvailable = $true
        } catch {
            $dockerAvailable = $false
        }

        if (-not $dockerAvailable) {
            Write-Log "🚫 Docker is not running. Secret scan aborted." -Type "error"
            Write-Log "💡 Tip: Start Docker and re-run your Git operation to resume scanning." -Type "info"
            $scanResult = @{ IsClean = $false; RawOutput = $null }
            return  # optional early return; otherwise continue below
        } else {
            if (-not $SourceDescription) {
                $SourceDescription = if ($env:GIT_HOOK_TYPE) { $env:GIT_HOOK_TYPE } else { "local-content" }
            }

            $RepoRoot = Resolve-RepoRoot
            $Image = Get-TruffleHogImage
            $dockerArgs = @(
                "run", "--rm", "-i",
                "--network", "none",
                $Image,
                "stdin",
                "--only-verified",
                "--json"
            )

            try {
                $result = & docker @dockerArgs

                # Error formatting
                $result | Where-Object { $_ -match '"level":"error"' } | ForEach-Object {
                    try {
                        $parsed = $_ | ConvertFrom-Json
                        Write-Log "❌ TruffleHog reported error: $($parsed.msg)" -Type error
                        if ($parsed.errors) {
                            foreach ($e in $parsed.errors) {
                                Write-Log "       ↳ $e" -Type error
                            }
                        }
                    } catch {
                        Write-Log "TruffleHog error output could not be parsed." -Type error
                    }
                }

                # Final parse
                try {
                    $json = $result | ConvertFrom-Json
                    $hasSecrets = $json -and $json.Count -gt 0
                    $scanResult = @{ IsClean = -not $hasSecrets; RawOutput = $result }
                } catch {
                    Write-Log "TruffleHog scan failed: Invalid JSON output." -Type "error"
                    $scanResult = @{ IsClean = $false; RawOutput = $result }
                }
            } catch {
                Write-Log "TruffleHog scan could not execute: $($_.Exception.Message)" -Type "error"
                $scanResult = @{ IsClean = $false; RawOutput = $null }
            }
        }
    }
    finally {
        Start-Sleep -Milliseconds 500
        Remove-Item $tempFilePath -Force 
    }

    return $scanResult  
}

function Invoke-TruffleHogHookScan {
    param (
        [ValidateSet('pre-commit', 'pre-push', 'commit-msg')]
        [string]$HookType
    )

    Write-Log "Starting TruffleHog scan for hook type: $HookType" -Type "info"

    switch ($HookType) {
        'pre-commit' { $diffContent = Get-GitDiffContent -DiffType 'cached' }
        'pre-push'   { $diffContent = Get-GitDiffContent -DiffType 'push' }
        'commit-msg' { $diffContent = git show HEAD | Out-String }
        default {
            Write-Log "Unknown hook type: $HookType" -Type "error"
            return $null
        }
    }

    if (-not $diffContent -or -not $diffContent.Trim()) {
        Write-Log "No content to scan for $HookType" -Type "info"
        return @{ IsClean = $true; RawOutput = $null }
    }

    return Invoke-TruffleHogScan -Content $diffContent
}

Export-ModuleMember -Function Invoke-TruffleHogHookScan, Get-GitDiffContent, Invoke-TruffleHogScan
