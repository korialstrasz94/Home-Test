param()

Write-Output "Running pre-checks..."
powershell -File .\checks.ps1

Write-Output "Starting minikube (driver=docker) if not already running..."
if (-not (minikube status --format '{{.Host}}' 2>$null)) {
    minikube start --driver=docker
} else {
    Write-Output "minikube appears to be running."
}

Write-Output "Configuring shell to use minikube's Docker daemon..."
minikube -p minikube docker-env --shell powershell | Invoke-Expression

Write-Output "Building Docker image 'rest:latest' inside minikube's docker daemon..."
docker build -t rest:latest ..

$maxChecks = 12
$i = 0
while (($i -lt $maxChecks) -and -not (docker images -q rest:latest)) {
    Write-Output "Waiting for image 'rest:latest' to appear in docker... ($i/$maxChecks)"
    Start-Sleep -Seconds 2
    $i++
}
if (-not (docker images -q rest:latest)) {
    Write-Error "Image rest:latest not found in docker after build. Aborting."
    exit 1
}

Write-Output "Applying Kubernetes manifests..."
kubectl apply -f ..\k8s

Write-Output "Waiting for deployment to become ready..."
kubectl rollout status deployment/rest-deploy --timeout=120s

Write-Output "Starting port-forward to expose the service on localhost:8080 in a new PowerShell window..."
Start-Process powershell -ArgumentList "-NoExit","-Command","kubectl port-forward svc/rest-service 8080:80"

Write-Output "Deployment complete. You can now call http://localhost:8080/hello-world"
