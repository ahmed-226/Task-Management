#!/bin/bash

# Exit on error
set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONITORING_DIR="$PROJECT_ROOT/monitoring"
NAMESPACE="${NAMESPACE:-default}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Task Management - Monitoring Setup${NC}"
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
    exit 1
fi

echo -e "${GREEN}✓ Connected to Kubernetes cluster${NC}"
echo ""

# Parse arguments
ACTION="install"

while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)
            ACTION="uninstall"
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
            echo "  --uninstall    Uninstall monitoring stack"
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

if [[ "$ACTION" == "uninstall" ]]; then
    echo -e "${BLUE}Uninstalling monitoring stack...${NC}"
    
    # Delete Grafana
    kubectl delete -f "$MONITORING_DIR/grafana/" -n $NAMESPACE --ignore-not-found
    
    # Delete Prometheus
    kubectl delete -f "$MONITORING_DIR/prometheus/" -n $NAMESPACE --ignore-not-found
    
    # Delete ClusterRole and ClusterRoleBinding (they're cluster-scoped)
    kubectl delete clusterrole prometheus --ignore-not-found
    kubectl delete clusterrolebinding prometheus --ignore-not-found
    
    echo -e "${GREEN}✓ Monitoring stack uninstalled${NC}"
    exit 0
fi

# Install Prometheus
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Prometheus...${NC}"
echo -e "${BLUE}========================================${NC}"

kubectl apply -f "$MONITORING_DIR/prometheus/prometheus-config.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/prometheus/alert-rules.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/prometheus/prometheus-deployment.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/prometheus/prometheus-service.yaml" -n $NAMESPACE

echo -e "${GREEN}✓ Prometheus deployed${NC}"
echo ""

# Wait for Prometheus to be ready
echo -e "${BLUE}Waiting for Prometheus to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n $NAMESPACE || true

# Install Grafana
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploying Grafana...${NC}"
echo -e "${BLUE}========================================${NC}"

kubectl apply -f "$MONITORING_DIR/grafana/grafana-configmap.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/grafana/grafana-dashboards-configmap.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/grafana/grafana-deployment.yaml" -n $NAMESPACE
kubectl apply -f "$MONITORING_DIR/grafana/grafana-service.yaml" -n $NAMESPACE

echo -e "${GREEN}✓ Grafana deployed${NC}"
echo ""

# Wait for Grafana to be ready
echo -e "${BLUE}Waiting for Grafana to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n $NAMESPACE || true

# Display status
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Monitoring Status${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Pods:${NC}"
kubectl get pods -l 'app in (prometheus, grafana)' -n $NAMESPACE
echo ""

echo -e "${YELLOW}Services:${NC}"
kubectl get svc -l 'app in (prometheus, grafana)' -n $NAMESPACE
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Monitoring setup completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Access URLs (using Minikube):${NC}"
echo -e "  Prometheus: minikube service prometheus --url"
echo -e "  Grafana:    minikube service grafana --url"
echo ""
echo -e "${BLUE}Or with port-forward:${NC}"
echo -e "  Prometheus: kubectl port-forward svc/prometheus 9090:9090"
echo -e "              Then open: http://localhost:9090"
echo ""
echo -e "  Grafana:    kubectl port-forward svc/grafana 3001:3000"
echo -e "              Then open: http://localhost:3001"
echo ""
echo -e "${BLUE}Grafana Credentials:${NC}"
echo -e "  Username: admin"
echo -e "  Password: admin123"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo -e "  View Prometheus logs: kubectl logs -l app=prometheus"
echo -e "  View Grafana logs:    kubectl logs -l app=grafana"
echo -e "  Uninstall:            ./scripts/setup-monitoring.sh --uninstall"
echo ""
