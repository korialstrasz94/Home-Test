#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo "Checking required commands: minikube, kubectl, docker"
for cmd in minikube kubectl docker; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

echo "Starting minikube (driver=docker) if not running..."
if ! minikube status --format '{{.Host}}' >/dev/null 2>&1; then
  minikube start --driver=docker
else
  echo "minikube already running"
fi

echo "Configuring shell to use minikube's Docker daemon"
eval "$(minikube -p minikube docker-env)"

echo "Building docker image 'rest:latest' inside minikube's docker daemon"
docker build -t rest:latest "${ROOT_DIR}"

echo "Applying Kubernetes manifests"
kubectl apply -f "${ROOT_DIR}/k8s"

echo "Waiting for deployment to become ready"
kubectl rollout status deployment/rest-deploy --timeout=120s

echo "Starting port-forward in background (localhost:8080 -> svc/rest-service:80)"
kubectl port-forward svc/rest-service 8080:80 &

echo "Deployment complete. You can now curl http://localhost:8080/hello-world"
