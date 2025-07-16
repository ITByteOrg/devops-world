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
function Resolve-ModulePath {
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
