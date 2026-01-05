# Task Management - Deployment Guide

This guide covers deploying the Task Management application to Kubernetes using Helm charts.

## Prerequisites

- Docker installed and running
- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- kubectl configured to connect to your cluster
- Helm 3.x installed

## Quick Start (Development)

```bash
# 1. Start Minikube (if using locally)
minikube start

# 2. Enable Ingress addon
minikube addons enable ingress

# 3. Build and load images (Minikube)
eval $(minikube docker-env)
./scripts/build-images.sh --all

# 4. Deploy with Helm (development mode)
./scripts/deploy.sh --dev

# 5. Access the application
minikube tunnel
# Open http://localhost
```

## Deployment Script Usage

```bash
# Development deployment (default)
./scripts/deploy.sh

# With specific options
./scripts/deploy.sh --dev              # Development environment
./scripts/deploy.sh --prod             # Production environment
./scripts/deploy.sh --upgrade          # Upgrade existing release
./scripts/deploy.sh --uninstall        # Uninstall release
./scripts/deploy.sh --dry-run          # Simulate without applying
./scripts/deploy.sh --namespace myns   # Custom namespace

# Examples
./scripts/deploy.sh --dev --dry-run    # Test dev deployment
./scripts/deploy.sh --prod --namespace production
```

## Manual Helm Deployment

```bash
# Development
helm install task-management ./helm/task-management \
  -f ./helm/task-management/values-dev.yaml

# Production
helm install task-management ./helm/task-management \
  -f ./helm/task-management/values-prod.yaml \
  -n production --create-namespace

# Check deployment status
kubectl get pods -l app.kubernetes.io/instance=task-management
```

## Building Docker Images

```bash
# Build all images locally
./scripts/build-images.sh --all

# Build specific image
./scripts/build-images.sh --client
./scripts/build-images.sh --server

# Build and push to registry
./scripts/build-images.sh --all --push --registry your-registry.azurecr.io --tag 1.0.0
```

## Helm Commands Reference

```bash
# Install
helm install task-management ./helm/task-management

# Install with custom values
helm install task-management ./helm/task-management -f custom-values.yaml

# Upgrade
helm upgrade task-management ./helm/task-management

# Rollback
helm rollback task-management 1

# Uninstall
helm uninstall task-management

# Dry run (test without applying)
helm install task-management ./helm/task-management --dry-run --debug

# Template rendering (see generated YAML)
helm template task-management ./helm/task-management

# Get release status
helm status task-management
```

## Monitoring Deployment

```bash
# Watch pods
kubectl get pods -w -l app.kubernetes.io/instance=task-management

# View logs
kubectl logs -f -l app.kubernetes.io/instance=task-management --all-containers

# Check ingress
kubectl get ingress

# Describe resources
kubectl describe deployment task-management-client
kubectl describe deployment task-management-server
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Image pull errors

```bash
# For private registries, create secret
kubectl create secret docker-registry registry-secret \
  --docker-server=your-registry.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password>
```

### Database connection issues

```bash
# Check MongoDB pod
kubectl logs -l component=mongodb

# Connect to MongoDB shell
kubectl exec -it <mongodb-pod> -- mongosh
```

## Cleanup

```bash
# Remove Helm release
helm uninstall task-management

# Remove K8s manifests
kubectl delete all -l app=task-management
kubectl delete pvc -l app=task-management
kubectl delete configmap -l app=task-management
kubectl delete secret -l app=task-management
```
