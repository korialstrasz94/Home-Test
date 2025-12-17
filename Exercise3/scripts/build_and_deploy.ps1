param()

$ErrorActionPreference = "Stop"

# Pre checks
Write-Output "Running pre-checks..."
powershell -File .\checks.ps1

Write-Output "Starting minikube (driver=docker) if not running..."

## Checking if minikube is running
$profileName = "minikube"

$profiles = minikube profile list --output json | ConvertFrom-Json
$profile = $profiles.valid | Where-Object { $_.Name -eq $profileName }

if (-not $profile) {
    Write-Output "Minikube profile '$profileName' not found. Starting..."
    minikube start --driver=docker
}
else {
    $status = minikube status -p $profileName --format '{{.Host}}'
    if ($status -ne "Running") {
        Write-Output "Minikube profile exists but is not running. Starting..."
        minikube start --driver=docker
    }
    else {
        Write-Output "minikube already running"
    }
}

Write-Output "Building Docker image inside minikube..."
minikube image build -t rest:latest ..

Write-Output "Applying Kubernetes manifests..."
kubectl apply -f ..\k8s

Write-Output "Waiting for deployment to become ready..."
kubectl rollout status deployment/rest-deploy --timeout=120s

Write-Output "Starting port-forward in background (localhost:8080 -> svc/rest-service:80)..."

Start-Process kubectl `
    -ArgumentList "port-forward","svc/rest-service","8080:80" `
    -WindowStyle Hidden

# How to access the service
Write-Output ""
Write-Output "Deployment complete."
Write-Output "Service available at:"
Write-Output "  http://localhost:8080"
Write-Output ""
Write-Output "You can now call:"
Write-Output "  Invoke-RestMethod http://localhost:8080/hello-world"