param()

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "Required command '$Name' not found in PATH."
        exit 1
    }
}

Require-Command "minikube"
Require-Command "kubectl"
Require-Command "docker"

Write-Output "All required commands found: minikube, kubectl, docker."