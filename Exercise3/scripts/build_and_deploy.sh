#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo "Checking required commands: minikube, kubectl"
for cmd in minikube kubectl; do
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

echo "Building Docker image inside minikube"
minikube image build -t rest:latest "${ROOT_DIR}"

echo "Applying Kubernetes manifests"
kubectl apply -f "${ROOT_DIR}/k8s"

echo "Waiting for deployment to become ready"
kubectl rollout status deployment/rest-deploy --timeout=120s

echo "Starting port-forward in background (localhost:8080 -> svc/rest-service:80)"

nohup kubectl port-forward svc/rest-service 8080:80 \
  >/dev/null 2>&1 &

echo
echo "Deployment complete."
echo "Service available at:"
echo "  http://localhost:8080"
echo
echo "You can now call:"
echo "  curl http://localhost:8080/hello-world"