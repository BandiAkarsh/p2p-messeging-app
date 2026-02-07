#!/bin/bash

# EcoMesh Local Testing Script
# This script helps you test Cloudflare Workers locally before deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 EcoMesh Local Testing Script${NC}"
echo "================================"

# Function to check if a port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for service
wait_for_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${YELLOW}⏳ Waiting for $name to be ready...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ $name is ready!${NC}"
            return 0
        fi
        echo -n "."
        sleep 1
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $name failed to start${NC}"
    return 1
}

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}❌ pnpm is not installed. Install with: npm install -g pnpm@9${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All prerequisites found${NC}"

# Parse command line arguments
MODE="${1:-docker}"  # Default to docker mode

if [ "$MODE" = "native" ]; then
    echo -e "\n${YELLOW}🔧 Running in NATIVE mode (using wrangler dev directly)${NC}"
    
    # Check if ports are available
    if check_port 8787; then
        echo -e "${RED}❌ Port 8787 is already in use. Stop the service first.${NC}"
        exit 1
    fi
    
    if check_port 8788; then
        echo -e "${RED}❌ Port 8788 is already in use. Stop the service first.${NC}"
        exit 1
    fi
    
    # Install dependencies
    echo -e "\n${YELLOW}📦 Installing dependencies...${NC}"
    cd workers/signaling && pnpm install && cd ../..
    cd workers/ai-worker && pnpm install && cd ../..
    
    # Start workers in background
    echo -e "\n${YELLOW}🚀 Starting Signaling Worker...${NC}"
    cd workers/signaling
    pnpm wrangler dev --local --port 8787 &
    SIGNALING_PID=$!
    cd ../..
    
    echo -e "${YELLOW}🚀 Starting AI Worker...${NC}"
    cd workers/ai-worker
    pnpm wrangler dev --local --port 8788 &
    AI_PID=$!
    cd ../..
    
    # Wait for services
    wait_for_service "http://localhost:8787/health" "Signaling Worker"
    wait_for_service "http://localhost:8788/health" "AI Worker"
    
    echo -e "\n${GREEN}✅ Both workers are running locally!${NC}"
    echo -e "${YELLOW}📍 Signaling Worker: http://localhost:8787${NC}"
    echo -e "${YELLOW}📍 AI Worker: http://localhost:8788${NC}"
    echo -e "\n${YELLOW}Press Ctrl+C to stop both workers${NC}"
    
    # Trap to kill background processes on exit
    trap "echo -e '\n${YELLOW}🛑 Stopping workers...${NC}'; kill $SIGNALING_PID $AI_PID 2>/dev/null; exit" INT
    
    # Wait for user to stop
    wait
    
elif [ "$MODE" = "docker" ]; then
    echo -e "\n${YELLOW}🐳 Running in DOCKER mode${NC}"
    
    # Check if .env exists
    if [ ! -f .env ]; then
        echo -e "${YELLOW}⚠️  .env file not found. Creating from .env.example...${NC}"
        cp .env.example .env
        echo -e "${YELLOW}⚠️  Please edit .env file with your actual values before running tests.${NC}"
    fi
    
    # Build and start containers
    echo -e "\n${YELLOW}🏗️  Building Docker containers...${NC}"
    docker-compose build
    
    echo -e "\n${YELLOW}🚀 Starting containers...${NC}"
    docker-compose up -d
    
    # Wait for services
    wait_for_service "http://localhost:8787/health" "Signaling Worker"
    wait_for_service "http://localhost:8788/health" "AI Worker"
    
    echo -e "\n${GREEN}✅ Docker containers are running!${NC}"
    echo -e "${YELLOW}📍 Signaling Worker: http://localhost:8787${NC}"
    echo -e "${YELLOW}📍 AI Worker: http://localhost:8788${NC}"
    echo -e "\n${YELLOW}View logs: docker-compose logs -f${NC}"
    echo -e "${YELLOW}Stop: docker-compose down${NC}"
    
else
    echo -e "${RED}❌ Unknown mode: $MODE${NC}"
    echo "Usage: ./scripts/test-local.sh [docker|native]"
    echo "  docker - Run workers in Docker containers (default)"
    echo "  native - Run workers directly with wrangler dev"
    exit 1
fi
