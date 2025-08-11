
# install profile loader
$repoRoot = git rev-parse --show-toplevel 2>$null
$sourceProfile = "$repoRoot/scripts/profiles/profile.ps1"
$targetProfile = $PROFILE

if (Test-Path $sourceProfile) {
    Copy-Item $sourceProfile $targetProfile -Force
    Write-Host "[INFO] PowerShell profile installed to $targetProfile"
} else {
    Write-Host "[ERROR] Source profile not found at $sourceProfile"
}

# import required modules
Import-Module posh-git
Import-Module $PROFILE

# verify setup
. $PROFILE
if (Get-Command Get-CustomPrompt -ErrorAction SilentlyContinue) {
    Write-Host "[SUCCESS] Get-CustomPrompt is available"
} else {
    Write-Host "[FAIL] Get-CustomPrompt not found"
}
