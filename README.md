# Task Management Application

A full-stack task management application built with React, Node.js, and MongoDB, deployed on Kubernetes.

## 🚀 Features

- Create, update, and delete tasks
- User authentication with JWT
- Task categorization and prioritization
- Responsive design with Tailwind CSS
- Kubernetes-ready with Helm charts
- Monitoring with Prometheus and Grafana

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Ingress                               │
│                    (nginx-ingress)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│     Client      │      │     Server      │
│  (React + Nginx)│      │   (Node.js)     │
│     Port 3000   │      │    Port 4000    │
└─────────────────┘      └────────┬────────┘
                                  │
                                  ▼
                         ┌─────────────────┐
                         │    MongoDB      │
                         │   Port 27017    │
                         └─────────────────┘
```

## 📁 Project Structure

```
Task-Management/
├── client/              # React frontend
├── server/              # Node.js backend
├── helm/                # Helm chart for K8s deployment
├── monitoring/          # Prometheus & Grafana configs
├── infrastructure/      # Terraform for cloud infra
├── scripts/             # Build and deploy scripts
└── docs/                # Documentation
```

## 🛠️ Quick Start

### Development (Docker Compose)

```bash
docker-compose up -d
```

Access at: http://localhost:3000

### Kubernetes (Helm)

```bash
# Build images
./scripts/build-images.sh --all

# Deploy with Helm
helm install task-management ./helm/task-management -f ./helm/task-management/values-dev.yaml
```

## 📦 Deployment Options

| Method | Use Case |
|--------|----------|
| Docker Compose | Local development |
| Helm Chart | Production-ready K8s deployment |
| Terraform + Helm | Full cloud infrastructure |

## 📊 Monitoring

The project includes a basic Prometheus and Grafana setup:

```bash
# Deploy monitoring stack
./scripts/setup-monitoring.sh

# Access Prometheus (http://localhost:9090)
kubectl port-forward svc/prometheus 9090:9090

# Access Grafana (http://localhost:3001)
kubectl port-forward svc/grafana 3001:3000
# Login: admin / admin123
```

Includes pre-configured dashboard for pod health monitoring.

## 📚 Documentation

- [Setup Guide](docs/SETUP.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

## 🔧 Scripts

```bash
# Build Docker images
./scripts/build-images.sh --all

# Deploy to Kubernetes
./scripts/deploy.sh

# Setup monitoring
./scripts/setup-monitoring.sh
```

## 🧪 Tech Stack

- **Frontend**: React, Tailwind CSS
- **Backend**: Node.js, Express
- **Database**: MongoDB
- **Container**: Docker
- **Orchestration**: Kubernetes, Helm
- **Monitoring**: Prometheus, Grafana
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions (coming soon)

## 📄 License

MIT License
