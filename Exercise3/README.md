# Deployable minikube package for simple REST service

This folder contains everything you need to build and run the provided `rest_1.0.zip` Go REST service on a local Minikube cluster and expose it on `http://localhost:8080/hello-world`.

What is included
- `Dockerfile` — multi-stage Dockerfile that downloads `rest_1.0.zip` during build, compiles the Go binary and produces a minimal image.
- `k8s/` — Kubernetes manifests (`deployment.yaml`, `service.yaml`) to deploy the app.
- `scripts/checks.ps1` — checks for required tooling on Windows (PowerShell).
- `scripts/build_and_deploy.ps1` — builds the Docker image inside Minikube and deploys manifests, then opens a port-forward to localhost:8080.
- `.dockerignore` — keeps the build context small.

Prerequisites
- Docker (if using Docker driver for Minikube)
- Minikube
- kubectl

Quick start (Windows PowerShell)
1. Open PowerShell as your normal user (no need for elevated unless Minikube driver requires it).
2. From this repo run:

```powershell
cd task2\scripts
.\build_and_deploy.ps1
```

What the script does
- Ensures `minikube`, `kubectl` and `docker` are available.
- Starts Minikube (if not running) using the Docker driver.
- Configures your shell to use Minikube's Docker daemon, builds the Docker image `rest:latest` from the local `task2` directory so no external registry is required.
- Applies the Kubernetes manifests and waits for the deployment.
- Opens a new PowerShell window with `kubectl port-forward svc/rest-service 8080:80` so the service is reachable at `http://localhost:8080/hello-world`.

Manual alternative (if you prefer step-by-step)
1. Start minikube (example):

```powershell
minikube start --driver=docker
```

2. Configure shell to use the Minikube docker daemon and build the image in the Minikube docker:

```powershell
minikube -p minikube docker-env --shell powershell | Invoke-Expression
docker build -t rest:latest ..\task2
```

3. Deploy the manifests and port-forward:

```powershell
kubectl apply -f task2\k8s
kubectl rollout status deployment/rest-deploy
kubectl port-forward svc/rest-service 8080:80
```

Notes
- The `Dockerfile` downloads the zip at build time. If you'd rather include the source locally, extract `rest_1.0.zip` into `task2/app` and modify the Dockerfile to use the local source.
- The approach builds the image inside Minikube's Docker daemon, avoiding the need for a remote registry.
- If you prefer to expose the service via a LoadBalancer on `localhost`, you can use `minikube tunnel` (requires admin privileges) and change the Service type to `LoadBalancer`.
