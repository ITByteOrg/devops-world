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
    Write-StdLog "INFO" "Latest commit: $LatestCommit"

    # Validate commit message format
    if (-not (Test-Path $CommitMsgFile)) {
        Write-StdLog "ERROR" "Missing commit message file: $CommitMsgFile"
        exit 1
    }

    $CommitMessage = Get-Content $CommitMsgFile -Raw
    Write-StdLog "INFO" "Commit message: `"$CommitMessage`""

    if ($CommitMessage -notmatch '^[A-Z]') {
        Write-StdLog "WARN" "Message should start with a capital letter."
    }

    # Run TruffleHog scan
    Write-StdLog "INFO" "Scanning with TruffleHog..."
    $TruffleResult = & trufflehog git --commit $LatestCommit 2>&1

    if ($TruffleResult -match 'Found \d+ results') {
        Write-StdLog "ERROR" "TruffleHog detected possible secrets in the commit!"
        Write-StdLog "ERROR" $TruffleResult
        exit 1
    } else {
        Write-StdLog "SUCCESS" "TruffleHog scan passed — no secrets detected."
    }

    Write-StdLog "SUCCESS" "commit-msg hook completed."
    exit 0
}
catch {
    Write-StdLog "FATAL" "Unhandled exception in commit-msg hook."
    Write-StdLog "FATAL" $_
    exit 1
}
