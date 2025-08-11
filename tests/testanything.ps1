# testanything.ps1
Set-StrictMode -Version Latest

# Resolve repo root
$GIT_ROOT = git rev-parse --show-toplevel
Import-Module "$GIT_ROOT/scripts/modules/Shared-Utils.psm1" -Force

Write-Host "🔍 Testing Write-Log for all types..."

$types = @("info", "warn", "error", "success", "ok", "debug", "unknown")

foreach ($type in $types) {
    Write-Log -Type $type -Message "This is a test message for type '$type'" -ToFile -LogDir "$GIT_ROOT/logs"
}

Write-Host "🔍 Testing Write-StdLog for all types..."

foreach ($type in $types) {
    Write-StdLog -Type $type -Message "This is a test message for type '$type'"
}
