<#
.SYNOPSIS
  Scans script files for variables or function logic, grouped by file.

.DESCRIPTION
  Supports:
    - vars   : Finds variable names like $gitRoot
    - symbols: Finds function calls and defined functions

  Recursively searches *.ps1, *.psm1, *.sh from the Git repo root.
#>

param (
  [ValidateSet("vars", "symbols")]
  [string]$mode = "vars"
)

# resolve Git repo root
$gitRoot = (& { git rev-parse --show-toplevel 2>$null }).Trim()
if (-not $gitRoot) {
  Write-Host "❌ could not resolve Git root. are you inside a Git repo?"
  exit 1
}

$file_types = @("*.ps1", "*.psm1", "*.sh")
$excluded_keywords = @(
  "if","foreach","return","exit","while","switch","try","catch",
  "break","continue","trap","default","function","param","then","fi"
)

$results = @{}

foreach ($type in $file_types) {
  Get-ChildItem -Path $gitRoot -Recurse -Filter $type -File | ForEach-Object {
    $file_path = $_.FullName
    $file_name = $_.Name
    $content = Get-Content $file_path -Raw

    if ($mode -eq "vars") {
      $items = [regex]::Matches($content, '\$[a-zA-Z_][\w]*') |
               ForEach-Object { $_.Value } |
               Sort-Object -Unique
    }
    elseif ($mode -eq "symbols") {
      $lines = $content -split "`n"

      # calls: first token on non-comment lines (excluding keywords)
      $calls = $lines |
               Where-Object { $_ -match '^\s*\w' -and $_ -notmatch '^\s*#' } |
               ForEach-Object { ($_ -split '\s+')[0].Trim() } |
               Where-Object { $_ -and ($_ -notin $excluded_keywords) }

      # function defs: match 'function name' or 'def name'
      $defs = [regex]::Matches($content, '\b(function|def)\s+([\w-]+)') |
              ForEach-Object { $_.Groups[2].Value }

      $items = $calls + $defs | Sort-Object -Unique
    }

    if ($items.Count -gt 0) {
      $results[$file_name] = $items
    }
  }
}

# display results
foreach ($script in ($results.Keys | Sort-Object)) {
  Write-Host "`n📄 $script" -ForegroundColor Magenta
  foreach ($item in ($results[$script] | Sort-Object)) {
    Write-Host "   └─ $item"
  }
}

