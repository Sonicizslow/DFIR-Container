#!/bin/bash

# DFIR Container Verification Script
# Tests that the permission fixes work correctly

set -e

echo "=== DFIR Container Permission Fix Verification ==="
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
echo "🚀 Testing container startup (this will run for 30 seconds)..."

# Start container and capture logs
timeout 30s docker compose up 2>&1 | tee /tmp/dfir-test.log || true

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

if grep -q "Can't drop privilege as nonroot user" /tmp/dfir-test.log; then
    echo "❌ FAILED: Supervisord still failing to drop privileges"
    exit 1
else
    echo "✅ No supervisord privilege errors found"
fi

if grep -q "supervisord started" /tmp/dfir-test.log; then
    echo "✅ Supervisord started successfully"
else
    echo "⚠️  Warning: Supervisord start message not found (check logs)"
fi

# Clean up
echo ""
echo "🧹 Cleaning up..."
docker compose down --quiet

echo ""
echo "🎉 SUCCESS: All permission issues appear to be fixed!"
echo ""
echo "📁 The container now uses ~/phishing instead of ~/Downloads"
echo "🔒 Container starts as root for setup, then drops to dfiruser for services"
echo "📖 See README.md for usage instructions"