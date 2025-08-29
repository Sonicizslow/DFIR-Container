#!/bin/bash

# DFIR Container Quick Start Script
# This script helps users get started quickly with the DFIR container

set -e

echo "=== DFIR Container Quick Start ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not available in PATH"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available"
    echo "Please ensure Docker Compose is installed"
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

# Check if downloads directory exists
DOWNLOADS_DIR="${HOME}/Downloads"
if [ ! -d "$DOWNLOADS_DIR" ]; then
    echo "⚠️  Downloads directory not found at $DOWNLOADS_DIR"
    echo "Creating downloads directory..."
    mkdir -p "$DOWNLOADS_DIR"
fi

echo "✅ Downloads directory: $DOWNLOADS_DIR"

# Build and start the container
echo ""
echo "🔨 Building DFIR container (this may take a few minutes)..."
docker compose build

echo ""
echo "🚀 Starting DFIR container..."
docker compose up -d

# Wait for container to be ready
echo ""
echo "⏳ Waiting for container to be ready..."
sleep 10

# Check if container is running
if docker compose ps | grep -q "running"; then
    echo ""
    echo "✅ DFIR Container is running!"
    echo ""
    echo "🌐 Access the container:"
    echo "   Open your web browser and go to: http://localhost:6080"
    echo ""
    echo "📁 File locations in the container:"
    echo "   - Your downloads: /home/dfiruser/downloads (read-only)"
    echo "   - Analysis workspace: /home/dfiruser/analysis"
    echo ""
    echo "🛠️  DFIR Tools:"
    echo "   Open a terminal in the container and run: source ~/dfir-tools.sh"
    echo ""
    echo "📖 For detailed usage instructions, see README.md"
    echo ""
    echo "🛑 To stop the container: docker compose down"
else
    echo ""
    echo "❌ Container failed to start properly"
    echo "Check the logs with: docker compose logs"
    exit 1
fi