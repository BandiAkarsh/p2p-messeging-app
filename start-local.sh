#!/bin/bash
# Start all EcoMesh services locally

echo "🚀 Starting EcoMesh Local Development..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "🛑 Shutting down services..."
    kill $SIGNALING_PID $AI_PID 2>/dev/null
    exit
}
trap cleanup INT TERM

cd "$(dirname "$0")"

# Build workers
echo "${BLUE}Building workers...${NC}"
cd workers/signaling && pnpm run build && cd ../..
cd workers/ai-worker && pnpm run build && cd ../..

# Start Signaling Worker
echo "${GREEN}Starting Signaling Worker on port 8787...${NC}"
cd workers/signaling
pnpm run dev &
SIGNALING_PID=$!
cd ../..

# Wait a moment
sleep 2

# Start AI Worker  
echo "${GREEN}Starting AI Worker on port 8788...${NC}"
cd workers/ai-worker
pnpm run dev &
AI_PID=$!
cd ../..

echo ""
echo "${GREEN}✅ All services started!${NC}"
echo ""
echo "Signaling Worker: http://localhost:8787"
echo "AI Worker:        http://localhost:8788"
echo ""
echo "Test commands:"
echo "  curl http://localhost:8787/health"
echo "  curl http://localhost:8788/health"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for both processes
wait
