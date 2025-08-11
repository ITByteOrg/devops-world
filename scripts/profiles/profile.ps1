# Import shared utilities
function Import-SharedUtils {
    try {
        $repoRoot = git rev-parse --show-toplevel 2>$null
        if (-not $repoRoot) {
            # Fallback to a known path if not in a Git repo
            Write-Host "[WARN] Not inside a Git repo — using fallback path"
            $repoRoot = "$HOME/dev/devops-world"
        }
        $modulePath = "$repoRoot/scripts/modules/Shared-Utils.psm1"
        if (-not (Test-Path $modulePath)) {
            Write-Host "[ERROR] Module not found at: $modulePath"
            return
        }
        Import-Module $modulePath -Force -ErrorAction Stop
        Write-Host "[INFO] Shared-Utils.psm1 imported successfully"
    } catch {
        Write-Host "[ERROR] Failed to import Shared-Utils.psm1: $($_.Exception.Message)"
    }
}

Import-Module posh-git
Import-SharedUtils
if (Get-Command Get-CustomPrompt -ErrorAction SilentlyContinue) {
    Write-Host "[INFO] Get-CustomPrompt is available"
} else {
    Write-Host "[ERROR] Get-CustomPrompt not found after import"
}

function prompt {
    Get-CustomPrompt
}
