#!/usr/bin/env pwsh
<#
.DESCRIPTION:
Imports module directly from the repo (no install needed)
Simulates a diff with a hardcoded secret
Runs the scan using your latest Docker args
Prints the result in a readable format
#>

Remove-Module SharedUtils -Force 
Remove-Module TruffleHogHookScanner -Force

Import-Module "$RepoRoot/scripts/modules/SharedUtils.psm1" -Force
$RepoRoot = Resolve-RepoRoot

Import-Module "$RepoRoot/scripts/modules/TruffleHogHookScanner.psm1" -Force
$Image = Get-TruffleHogImage

Write-Host "Running TruffleHog scan with image: $Image"

$sampleDiff = @"
diff --git a/app.py b/app.py
index 1234567..89abcde 100644
--- a/app.py
+++ b/app.py
@@ def connect():
- password = "hunter2"
+ password = "newsecret123"
"@

$result = Invoke-TruffleHogScan -Content $sampleDiff, $Image

Write-Host "`nScan Result:"
$result | Format-List
