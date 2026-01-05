#!/bin/bash

# Exit on error
set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELM_CHART="$PROJECT_ROOT/helm/task-management"
RELEASE_NAME="${RELEASE_NAME:-task-management}"
NAMESPACE="${NAMESPACE:-default}"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Task Management - Helm Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Release Name: ${RELEASE_NAME}"
echo -e "  Namespace: ${NAMESPACE}"
echo -e "  Environment: ${ENVIRONMENT}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    exit 1
fi

# Check if helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: helm is not installed${NC}"
    echo -e "${YELLOW}Install Helm: https://helm.sh/docs/intro/install/${NC}"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster${NC}"
    echo -e "${YELLOW}Make sure your cluster is running (minikube start)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
echo -e "${GREEN}✓ Helm is available${NC}"
echo ""

# Parse arguments
ACTION="install"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --upgrade)
            ACTION="upgrade"
            shift
            ;;
        --uninstall)
            ACTION="uninstall"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --prod)
            ENVIRONMENT="prod"
            shift
            ;;
        --dev)
            ENVIRONMENT="dev"
            shift
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --upgrade      Upgrade existing release"
            echo "  --uninstall    Uninstall the release"
            echo "  --dry-run      Simulate the deployment"
            echo "  --dev          Use development values (default)"
            echo "  --prod         Use production values"
            echo "  --namespace    Kubernetes namespace (default: default)"
            echo "  --help         Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Select values file based on environment
VALUES_FILE="$HELM_CHART/values-${ENVIRONMENT}.yaml"
if [[ ! -f "$VALUES_FILE" ]]; then
    VALUES_FILE="$HELM_CHART/values.yaml"
    echo -e "${YELLOW}Using default values.yaml${NC}"
else
    echo -e "${BLUE}Using values file: values-${ENVIRONMENT}.yaml${NC}"
fi

# Create namespace if it doesn't exist
if [[ "$NAMESPACE" != "default" ]]; then
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
fi

# Build Helm command
HELM_CMD=""
case $ACTION in
    install)
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}Installing Task Management...${NC}"
        echo -e "${BLUE}========================================${NC}"
        HELM_CMD="helm install $RELEASE_NAME $HELM_CHART -f $VALUES_FILE -n $NAMESPACE"
        
        # Check if release already exists
        if helm status $RELEASE_NAME -n $NAMESPACE &> /dev/null; then
            echo -e "${YELLOW}Release already exists, upgrading instead...${NC}"
            HELM_CMD="helm upgrade $RELEASE_NAME $HELM_CHART -f $VALUES_FILE -n $NAMESPACE"
        fi
        ;;
    upgrade)
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}Upgrading Task Management...${NC}"
        echo -e "${BLUE}========================================${NC}"
        HELM_CMD="helm upgrade $RELEASE_NAME $HELM_CHART -f $VALUES_FILE -n $NAMESPACE"
        ;;
    uninstall)
        echo -e "${BLUE}========================================${NC}"
        echo -e "${BLUE}Uninstalling Task Management...${NC}"
        echo -e "${BLUE}========================================${NC}"
        helm uninstall $RELEASE_NAME -n $NAMESPACE
        echo -e "${GREEN}✓ Release uninstalled successfully${NC}"
        exit 0
        ;;
esac

# Add dry-run flag if requested
if [[ "$DRY_RUN" == "true" ]]; then
    HELM_CMD="$HELM_CMD --dry-run --debug"
    echo -e "${YELLOW}Running in dry-run mode...${NC}"
fi

# Execute Helm command
echo ""
eval $HELM_CMD

if [[ "$DRY_RUN" == "false" ]]; then
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Waiting for pods to be ready...${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Wait for deployments
    kubectl wait --for=condition=available --timeout=300s deployment -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE 2>/dev/null || true
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Deployment Status${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    echo -e "${YELLOW}Pods:${NC}"
    kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE
    echo ""

    echo -e "${YELLOW}Services:${NC}"
    kubectl get svc -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE
    echo ""

    echo -e "${YELLOW}Ingress:${NC}"
    kubectl get ingress -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE
    echo ""

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Access the application:${NC}"
    echo -e "- For Minikube: Run 'minikube tunnel'"
    echo -e "- Then open: http://localhost"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo -e "- View logs: kubectl logs -l app.kubernetes.io/instance=$RELEASE_NAME -n $NAMESPACE --all-containers=true"
    echo -e "- Upgrade: ./scripts/deploy.sh --upgrade"
    echo -e "- Uninstall: ./scripts/deploy.sh --uninstall"
    echo -e "- Helm status: helm status $RELEASE_NAME -n $NAMESPACE"
    echo ""
fi
