#!/bin/bash

# Exit on error
set -e

# Configuration
REGISTRY="${DOCKER_REGISTRY:-dockerhub-username}"
VERSION="${VERSION:-v1.0.0}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Task Management - Build & Push Images${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if logged in to Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Prompt for registry if using default
if [ "$REGISTRY" = "dockerhub-username" ]; then
    echo -e "${BLUE}Enter your Docker registry username (e.g., dockerhub username):${NC}"
    read -r REGISTRY
fi

echo -e "${GREEN}Using registry: $REGISTRY${NC}"
echo -e "${GREEN}Version: $VERSION${NC}"
echo ""

# Build Server Image
echo -e "${BLUE}Building server image...${NC}"
cd "$PROJECT_ROOT/server"
docker build -f Dockerfile \
    -t "${REGISTRY}/task-management-server:${VERSION}" \
    -t "${REGISTRY}/task-management-server:latest" \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server image built successfully${NC}"
else
    echo -e "${RED}✗ Server image build failed${NC}"
    exit 1
fi

# Build Client Image
echo -e "${BLUE}Building client image...${NC}"
cd "$PROJECT_ROOT/client"
docker build -f Dockerfile.prod \
    --build-arg REACT_APP_API_URL=http://localhost/api \
    -t "${REGISTRY}/task-management-client:${VERSION}" \
    -t "${REGISTRY}/task-management-client:latest" \
    .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Client image built successfully${NC}"
else
    echo -e "${RED}✗ Client image build failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Pushing images to registry...${NC}"

# Push Server Images
echo -e "${BLUE}Pushing server images...${NC}"
docker push "${REGISTRY}/task-management-server:${VERSION}"
docker push "${REGISTRY}/task-management-server:latest"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Server images pushed successfully${NC}"
else
    echo -e "${RED}✗ Server images push failed${NC}"
    exit 1
fi

# Push Client Images
echo -e "${BLUE}Pushing client images...${NC}"
docker push "${REGISTRY}/task-management-client:${VERSION}"
docker push "${REGISTRY}/task-management-client:latest"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Client images pushed successfully${NC}"
else
    echo -e "${RED}✗ Client images push failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Images built and pushed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Update deployment files with: ${REGISTRY}/task-management-server:${VERSION}"
echo -e "2. Update deployment files with: ${REGISTRY}/task-management-client:${VERSION}"
echo -e "3. Run: ./scripts/deploy.sh"
echo ""
