<#
.SYNOPSIS
    Prepares the local environment for PowerShell-based workflows.

.DESCRIPTION
    - Loads environment variables from .env (if present)
    - Activates Python virtual environment (.venv)
    - Detects Python executable inside .venv
    - Sets PYTHONPATH for module resolution
    - Starts SSH agent and adds key if available
#>

$RepoRoot = git rev-parse --show-toplevel
. "$RepoRoot/scripts/modules/SharedUtils.psm1

# Load environment variables from .env
$EnvFile = Join-Path $RepoRoot ".env"
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
        $pair = $_ -split '='
        if ($pair.Length -eq 2) {
            [System.Environment]::SetEnvironmentVariable($pair[0], $pair[1])
        }
    }
} else {
    Write-StdLog "Warning: .env file not found. Continuing without environment overrides." "warn"
}

# Activate virtual environment
$VenvUnix = Join-Path $RepoRoot ".venv/bin/Activate.ps1"
$VenvWin  = Join-Path $RepoRoot ".venv/Scripts/Activate.ps1"

if (Test-Path $VenvUnix) {
    . $VenvUnix
} elseif (Test-Path $VenvWin) {
    . $VenvWin
} else {
    Write-StdLog "ERROR: Could not activate .venv" "error"
    exit 1
}

# Detect Python executable
$PythonUnix = Join-Path $RepoRoot ".venv/bin/python"
$PythonWin  = Join-Path $RepoRoot ".venv/Scripts/python.exe"

if (Test-Path $PythonUnix) {
    $env:VENV_PY = $PythonUnix
} elseif (Test-Path $PythonWin) {
    $env:VENV_PY = $PythonWin
} else {
    Write-StdLog "ERROR: Could not find .venv Python" "error"
    exit 1
}

# Set Python path
$env:PYTHONPATH = "src"

# Start SSH agent and add key
if (Get-Command ssh-agent -ErrorAction SilentlyContinue -CommandType Application) {
    Start-Process ssh-agent -WindowStyle Hidden
    $SSHKey = "$HOME/.ssh/id_ed25519"
    if (Test-Path $SSHKey) {
        $existingKeys = & ssh-add -l 2>&1
        if ($existingKeys -notmatch [regex]::Escape($SSHKey)) {
            & ssh-add $SSHKey | Out-Null
            Write-StdLog "SSH key added to agent." "info"
        } else {
            Write-StdLog "SSH key already loaded." "info"
        }
    } else {
        Write-StdLog "SSH key not found at $SSHKey. Skipping SSH setup." "warn"
    }
} else {
    Write-StdLog "ssh-agent not available. Skipping SSH setup." "warn"
}
