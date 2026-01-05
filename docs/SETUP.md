# Task Management - Setup Guide

Complete setup guide for development and deployment environments.

## Development Setup

### Prerequisites

- Node.js 18.x or higher
- Docker & Docker Compose
- Git

### Local Development (Docker Compose)

```bash
# Clone repository
git clone https://github.com/ahmed-226/Task-Management.git
cd Task-Management

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000

### Local Development (Manual)

```bash
# Install server dependencies
cd server
npm install

# Start MongoDB (using Docker)
docker run -d -p 27017:27017 --name mongodb mongo:7.0

# Start server
npm start

# In another terminal, install client dependencies
cd client
npm install

# Start client
npm start
```

## Kubernetes Setup

### Prerequisites

- kubectl installed and configured
- Helm 3.x installed
- Kubernetes cluster access

### Option 1: Minikube (Local)

```bash
# Install Minikube
# Windows (using Chocolatey)
choco install minikube

# Start cluster
minikube start --memory=4096 --cpus=2

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
```

### Option 2: Docker Desktop Kubernetes

1. Open Docker Desktop Settings
2. Go to Kubernetes tab
3. Enable Kubernetes
4. Wait for cluster to start

### Option 3: Cloud Kubernetes

#### Azure AKS

```bash
# Create AKS cluster (via Terraform)
cd infrastructure/terraform
terraform init
terraform plan
terraform apply
```

## Build Docker Images

### For Local Kubernetes

```bash
# If using Minikube
eval $(minikube docker-env)

# Build images
docker build -f client/Dockerfile.prod -t taskmanagement-client:latest ./client
docker build -f server/Dockerfile.prod -t taskmanagement-server:latest ./server
```

### For Remote Registry

```bash
# Set variables
export DOCKER_REGISTRY="your-registry.azurecr.io"
export TAG="latest"

# Build and push
./scripts/build-images.sh --all --push --registry $DOCKER_REGISTRY --tag $TAG
```

## Install Nginx Ingress Controller

```bash
# For Minikube
minikube addons enable ingress

# For other clusters
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

## Deploy Application

### Using Helm (Recommended)

```bash
# Development deployment
helm install task-management ./helm/task-management \
  -f ./helm/task-management/values-dev.yaml

# Production deployment
helm install task-management ./helm/task-management \
  -f ./helm/task-management/values-prod.yaml \
  -n production --create-namespace
```

### Using kubectl

```bash
# Deploy all resources
./scripts/deploy.sh
```

## Verify Installation

```bash
# Check all pods are running
kubectl get pods -l app.kubernetes.io/instance=task-management

# Check services
kubectl get svc

# Check ingress
kubectl get ingress

# Test the application
curl http://localhost/api/health
```

## Environment Variables

### Server

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port | 4000 |
| NODE_ENV | Environment | development |
| MONGODB_URI | MongoDB connection string | mongodb://localhost:27017/taskmanagement |
| JWT_SECRET | JWT signing secret | (required) |
| ALLOWED_ORIGINS | CORS origins | http://localhost:3000 |

### Client

| Variable | Description | Default |
|----------|-------------|---------|
| REACT_APP_API_URL | Backend API URL | /api |
| NODE_ENV | Environment | development |

## Monitoring Setup

### Deploy Prometheus and Grafana

```bash
# Install monitoring stack
./scripts/setup-monitoring.sh

# With custom namespace
./scripts/setup-monitoring.sh --namespace monitoring

# Uninstall monitoring
./scripts/setup-monitoring.sh --uninstall
```

### Access Monitoring

```bash
# Port-forward Prometheus
kubectl port-forward svc/prometheus 9090:9090
# Open: http://localhost:9090

# Port-forward Grafana
kubectl port-forward svc/grafana 3001:3000
# Open: http://localhost:3001
```

### Grafana Credentials

- Username: `admin`
- Password: `admin123`

The pre-configured dashboard "Task Management - Application Dashboard" shows:
- Total pods running
- Pod health status
- Pod status over time

## Next Steps

1. [Deploy the application](DEPLOYMENT.md)
2. ✅ Set up monitoring with Prometheus and Grafana
3. Configure CI/CD pipeline (GitHub Actions)
4. Set up infrastructure with Terraform
