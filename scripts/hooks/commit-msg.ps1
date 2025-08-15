<#
.SYNOPSIS
Validates the structure of commit messages and scans for embedded secrets before finalizing a Git commit.

.DESCRIPTION
This Git commit-msg hook checks if the provided commit message file starts with a capital letter,
alerts the user if formatting conventions are not met, and invokes TruffleHog to scan the latest commit
for any leaked credentials or high-entropy secrets.

Utilizes Shared logging functions (Write-StdLog) for color-coded terminal output and consistent UX.

.PARAMETER CommitMsgFile
The path to the temporary commit message file created by Git during the commit-msg hook execution.

.NOTES
Dependencies:
  - Resolved-ScriptRoot.ps1
  - Write-StdLog.ps1
  - TruffleHog CLI (installed and available in PATH)

.EXAMPLE
& .\commit-msg.ps1 -CommitMsgFile ".git/COMMIT_EDITMSG"
#>

param (
    [string]$CommitMsgFile
)

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptRoot\Shared\Resolved-ScriptRoot.ps1"
. "$ScriptRoot\Shared\Write-StdLog.ps1"

Write-StdLog "INFO" "Running commit-msg hook..."

try {
    # Get latest commit hash
    $LatestCommit = & git rev-parse HEAD
    Write-StdLog "Latest commit: $LatestCommit" "info"

    # Validate commit message format
    if (-not (Test-Path $CommitMsgFile)) {
        Write-StdLog "Missing commit message file: $CommitMsgFile" "error"
        exit 1
    }

    $CommitMessage = Get-Content $CommitMsgFile -Raw
    Write-StdLog "Commit message: `"$CommitMessage`"" "info"

    if ($CommitMessage -notmatch '^[A-Z]') {
        Write-StdLog "Message should start with a capital letter." "warn"
    }

    # Run TruffleHog scan
    Write-StdLog "Scanning with TruffleHog..." "info"
    $TruffleResult = & trufflehog git --commit $LatestCommit 2>&1

    if ($TruffleResult -match 'Found \d+ results') {
        Write-StdLog "TruffleHog detected possible secrets in the commit!" "error"
        Write-StdLog $TruffleResult "error"
        exit 1
    } else {
        Write-StdLog "TruffleHog scan passed — no secrets detected." "success"
    }

    Write-StdLog "commit-msg hook completed." "success"
    exit 0
}
catch {
    Write-StdLog "Unhandled exception in commit-msg hook." "error"
    Write-StdLog $_ "error"
    exit 1
}
