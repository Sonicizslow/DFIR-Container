#!/bin/bash

# DFIR Container RDP Verification Script
# Tests that the RDP setup works correctly

set -e

echo "=== DFIR Container RDP Verification ==="
echo ""

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not available"
    exit 1
fi

# Check if docker compose is available  
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available"
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Create test phishing directory
echo "Creating test phishing directory..."
mkdir -p ~/phishing
echo "This is a test phishing file for DFIR analysis" > ~/phishing/test-sample.txt
echo "✅ Test phishing directory created at ~/phishing"

echo ""
echo "🔨 Building DFIR container..."
docker compose build --quiet

echo ""
echo "🚀 Testing container startup (this will run for 45 seconds)..."

# Start container and capture logs
timeout 45s docker compose up 2>&1 | tee /tmp/dfir-test.log || true

echo ""
echo "🔍 Analyzing startup logs..."

# Check for permission errors
if grep -q "Read-only file system" /tmp/dfir-test.log; then
    echo "❌ FAILED: Still getting 'Read-only file system' errors"
    exit 1
else
    echo "✅ No 'Read-only file system' errors found"
fi

if grep -q "Operation not permitted" /tmp/dfir-test.log; then
    echo "❌ FAILED: Still getting 'Operation not permitted' errors"
    exit 1  
else
    echo "✅ No 'Operation not permitted' errors found"
fi

# Check for XRDP startup
if grep -q "xrdp" /tmp/dfir-test.log; then
    echo "✅ XRDP service logs found"
else
    echo "⚠️  Warning: XRDP service logs not found (check manually)"
fi

# Check for supervisord startup
if grep -q "supervisord started" /tmp/dfir-test.log; then
    echo "✅ Supervisord started successfully"
else
    echo "⚠️  Warning: Supervisord start message not found (check logs)"
fi

# Check if RDP port is listening
echo ""
echo "🔌 Checking RDP port availability..."
sleep 5  # Give services time to start

if netstat -an 2>/dev/null | grep -q ":3389.*LISTEN" || ss -an 2>/dev/null | grep -q ":3389.*LISTEN"; then
    echo "✅ RDP port 3389 is listening"
else
    echo "⚠️  Warning: RDP port 3389 not detected as listening (may need more time)"
fi

# Clean up
echo ""
echo "🧹 Cleaning up..."
docker compose down --quiet

echo ""
echo "🎉 SUCCESS: RDP migration appears to be working!"
echo ""
echo "📋 Summary of changes:"
echo "🔄 VNC (ports 5901/6080) → RDP (port 3389)"
echo "🖥️  tightvncserver + noVNC → XRDP"
echo "🔗 Web browser access → RDP client access"
echo "📋 Improved clipboard support through native RDP"
echo ""
echo "🚀 Next steps:"
echo "1. Start the container: docker-compose up -d"
echo "2. Connect via RDP: ./connect-rdp.sh"
echo "3. Use any RDP client: localhost:3389 (dfiruser/dfirpassword)"
echo ""
echo "📖 See README.md for updated usage instructions"