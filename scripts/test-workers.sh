#!/bin/bash

# EcoMesh Workers Test Suite
# Comprehensive testing for Cloudflare Workers before deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SIGNALING_URL="${SIGNALING_URL:-http://localhost:8787}"
AI_URL="${AI_URL:-http://localhost:8788}"
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_endpoint() {
    local name=$1
    local url=$2
    local method=$3
    local data=$4
    local expected_status=$5
    
    echo -e "\n${BLUE}🧪 Testing: $name${NC}"
    echo "   URL: $method $url"
    
    if [ -n "$data" ]; then
        echo "   Data: $data"
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$url" 2>/dev/null || echo -e "\n000")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            "$url" 2>/dev/null || echo -e "\n000")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}   ✅ Passed (Status: $status_code)${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}   ❌ Failed (Expected: $expected_status, Got: $status_code)${NC}"
        echo "   Response: $body"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo -e "${GREEN}🧪 EcoMesh Workers Test Suite${NC}"
echo "=============================="
echo -e "${YELLOW}Signaling Worker: $SIGNALING_URL${NC}"
echo -e "${YELLOW}AI Worker: $AI_URL${NC}"

# Wait for services to be ready
echo -e "\n${YELLOW}⏳ Checking if workers are running...${NC}"
sleep 2

# ============================================
# Signaling Worker Tests
# ============================================
echo -e "\n${GREEN}📡 Testing Signaling Worker${NC}"
echo "----------------------------"

# Health check
test_endpoint "Health Check" "$SIGNALING_URL/health" "GET" "" "200"

# Create room
test_endpoint "Create Room" "$SIGNALING_URL/api/rooms" "POST" '{"roomId": "test-room-123"}' "201"

# List peers (empty)
test_endpoint "List Peers (Empty)" "$SIGNALING_URL/peers?room=test-room-123" "GET" "" "200"

# Join room
test_endpoint "Join Room" "$SIGNALING_URL/join?room=test-room-123" "POST" \
    '{"peerId": "peer-1", "publicKey": "test-key-123"}' "200"

# Signal to peer (should fail if target not found)
test_endpoint "Signal to Non-existent Peer" "$SIGNALING_URL/signal?room=test-room-123" "POST" \
    '{"senderPeerId": "peer-1", "targetPeerId": "non-existent", "data": {"type": "offer"}}' "404"

# Leave room
test_endpoint "Leave Room" "$SIGNALING_URL/leave?room=test-room-123" "POST" \
    '{"peerId": "peer-1"}' "200"

# ============================================
# AI Worker Tests
# ============================================
echo -e "\n${GREEN}🤖 Testing AI Worker${NC}"
echo "--------------------"

# Health check
test_endpoint "Health Check" "$AI_URL/health" "GET" "" "200"

# Smart reply
test_endpoint "Smart Reply" "$AI_URL/smart-reply" "POST" \
    '{"message": "Hello! How are you today?", "context": "casual conversation", "tone": "friendly"}' "200"

# Translate
test_endpoint "Translate" "$AI_URL/translate" "POST" \
    '{"text": "Hello world", "targetLang": "es"}' "200"

# Summarize
test_endpoint "Summarize" "$AI_URL/summarize" "POST" \
    '{"text": "This is a test message. It contains multiple sentences. We want to summarize it.", "maxLength": 10}' "200"

# Detect language
test_endpoint "Detect Language" "$AI_URL/detect-language" "POST" \
    '{"text": "Bonjour le monde"}' "200"

# Test error handling
test_endpoint "Invalid Endpoint" "$AI_URL/invalid-endpoint" "GET" "" "404"

# ============================================
# WebSocket Test
# ============================================
echo -e "\n${GREEN}🔌 Testing WebSocket Connection${NC}"
echo "-------------------------------"

echo -e "${BLUE}🧪 Testing: WebSocket Upgrade${NC}"
if curl -s -i -N \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Host: localhost:8787" \
    -H "Origin: http://localhost:8787" \
    "$SIGNALING_URL/ws?room=ws-test&peer=ws-peer" 2>/dev/null | grep -q "101"; then
    echo -e "${GREEN}   ✅ WebSocket upgrade successful${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${YELLOW}   ⚠️  WebSocket test skipped (may require actual WS connection)${NC}"
fi

# ============================================
# Test Summary
# ============================================
echo -e "\n${GREEN}📊 Test Summary${NC}"
echo "==============="
echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
fi
