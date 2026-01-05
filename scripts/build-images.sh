#!/bin/bash

# Exit on error
set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REGISTRY="${DOCKER_REGISTRY:-docker.io}"
IMAGE_PREFIX="${IMAGE_PREFIX:-taskmanagement}"
TAG="${TAG:-latest}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Task Management - Docker Image Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Registry: ${REGISTRY}"
echo -e "  Image Prefix: ${IMAGE_PREFIX}"
echo -e "  Tag: ${TAG}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker is available${NC}"
echo ""

# Build Client Image
build_client() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Building Client Image...${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    local CLIENT_IMAGE="${REGISTRY}/${IMAGE_PREFIX}-client:${TAG}"
    
    docker build \
        -f "$PROJECT_ROOT/client/Dockerfile.prod" \
        -t "$CLIENT_IMAGE" \
        --build-arg REACT_APP_API_URL="${REACT_APP_API_URL:-/api}" \
        "$PROJECT_ROOT/client"
    
    echo -e "${GREEN}✓ Client image built: ${CLIENT_IMAGE}${NC}"
    echo ""
}

# Build Server Image
build_server() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Building Server Image...${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    local SERVER_IMAGE="${REGISTRY}/${IMAGE_PREFIX}-server:${TAG}"
    
    docker build \
        -f "$PROJECT_ROOT/server/Dockerfile.prod" \
        -t "$SERVER_IMAGE" \
        "$PROJECT_ROOT/server"
    
    echo -e "${GREEN}✓ Server image built: ${SERVER_IMAGE}${NC}"
    echo ""
}

# Parse arguments
BUILD_CLIENT=false
BUILD_SERVER=false
PUSH_IMAGES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --client)
            BUILD_CLIENT=true
            shift
            ;;
        --server)
            BUILD_SERVER=true
            shift
            ;;
        --push)
            PUSH_IMAGES=true
            shift
            ;;
        --all)
            BUILD_CLIENT=true
            BUILD_SERVER=true
            shift
            ;;
        --registry)
            REGISTRY="$2"
            shift 2
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --client      Build client image only"
            echo "  --server      Build server image only"
            echo "  --all         Build all images (default if no option specified)"
            echo "  --push        Push images to registry after building"
            echo "  --registry    Docker registry (default: docker.io)"
            echo "  --tag         Image tag (default: latest)"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Default to building all if no specific option
if [[ "$BUILD_CLIENT" == "false" && "$BUILD_SERVER" == "false" ]]; then
    BUILD_CLIENT=true
    BUILD_SERVER=true
fi

# Build images
if [[ "$BUILD_CLIENT" == "true" ]]; then
    build_client
fi

if [[ "$BUILD_SERVER" == "true" ]]; then
    build_server
fi

# Push images if requested
if [[ "$PUSH_IMAGES" == "true" ]]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Pushing Images to Registry...${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if [[ "$BUILD_CLIENT" == "true" ]]; then
        docker push "${REGISTRY}/${IMAGE_PREFIX}-client:${TAG}"
        echo -e "${GREEN}✓ Client image pushed${NC}"
    fi
    
    if [[ "$BUILD_SERVER" == "true" ]]; then
        docker push "${REGISTRY}/${IMAGE_PREFIX}-server:${TAG}"
        echo -e "${GREEN}✓ Server image pushed${NC}"
    fi
    echo ""
fi

# List built images
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Built Images:${NC}"
echo -e "${BLUE}========================================${NC}"
docker images | grep "${IMAGE_PREFIX}" | head -10
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
