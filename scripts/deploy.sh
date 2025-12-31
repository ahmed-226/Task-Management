#!/bin/bash

# Exit on error
set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_DIR="$PROJECT_ROOT/k8s"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Task Management - K8s Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}Make sure your cluster is running (minikube start)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
echo ""

# Function to wait for deployment
wait_for_deployment() {
    local deployment=$1
    local namespace=${2:-default}
    echo -e "${BLUE}Waiting for $deployment to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/$deployment -n $namespace
}

# Function to wait for statefulset
wait_for_statefulset() {
    local statefulset=$1
    local namespace=${2:-default}
    echo -e "${BLUE}Waiting for $statefulset to be ready...${NC}"
    kubectl wait --for=condition=ready --timeout=300s pod -l component=mongodb -n $namespace
}

# Deploy MongoDB
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying MongoDB...${NC}"
echo -e "${BLUE}========================================${NC}"
kubectl apply -f "$K8S_DIR/mongodb/service.yaml"
kubectl apply -f "$K8S_DIR/mongodb/deployment.yaml"
wait_for_statefulset "mongodb"
echo -e "${GREEN}✓ MongoDB deployed successfully${NC}"
echo ""

# Deploy Server
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Server...${NC}"
echo -e "${BLUE}========================================${NC}"
kubectl apply -f "$K8S_DIR/server/configmap.yaml"
kubectl apply -f "$K8S_DIR/server/secret.yaml"
kubectl apply -f "$K8S_DIR/server/deployment.yaml"
kubectl apply -f "$K8S_DIR/server/service.yaml"
wait_for_deployment "server-deployment"
echo -e "${GREEN}✓ Server deployed successfully${NC}"
echo ""

# Deploy Client
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Client...${NC}"
echo -e "${BLUE}========================================${NC}"
kubectl apply -f "$K8S_DIR/client/configmap.yaml"
kubectl apply -f "$K8S_DIR/client/deployment.yaml"
kubectl apply -f "$K8S_DIR/client/service.yaml"
wait_for_deployment "client-deployment"
echo -e "${GREEN}✓ Client deployed successfully${NC}"
echo ""

# Deploy Ingress
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Ingress...${NC}"
echo -e "${BLUE}========================================${NC}"
kubectl apply -f "$K8S_DIR/ingress/ingress.yaml"
echo -e "${GREEN}✓ Ingress deployed successfully${NC}"
echo ""

# Display deployment status
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deployment Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Pods:${NC}"
kubectl get pods -l app=task-management
echo ""

echo -e "${YELLOW}Services:${NC}"
kubectl get svc -l app=task-management
echo ""

echo -e "${YELLOW}Ingress:${NC}"
kubectl get ingress
echo ""

echo -e "${YELLOW}Persistent Volume Claims:${NC}"
kubectl get pvc
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Access the application:${NC}"
echo -e "- For Minikube: Run 'minikube service client-service' or 'minikube tunnel'"
echo -e "- Then open: http://localhost"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "- View logs: kubectl logs -l app=task-management --all-containers=true"
echo -e "- Restart deployment: kubectl rollout restart deployment/server-deployment"
echo -e "- Delete all: kubectl delete all -l app=task-management"
echo ""