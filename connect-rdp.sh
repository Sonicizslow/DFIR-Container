#!/bin/bash

# DFIR Container RDP Connection Script
# Provides easy RDP access to the DFIR investigation environment

set -e

echo "=== DFIR Container RDP Connection ===="
echo ""

# Check if container is running
CONTAINER_NAME="dfir-investigation"
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ DFIR Container is not running!"
    echo ""
    echo "Start the container first:"
    echo "  docker-compose up -d"
    echo ""
    echo "Or use the quick start script:"
    echo "  ./quick-start.sh"
    exit 1
fi

echo "✅ DFIR Container is running"
echo ""

# RDP connection details
RDP_HOST="localhost"
RDP_PORT="3389"
RDP_USER="dfiruser"
RDP_PASS="dfirpassword"

echo "🔗 RDP Connection Details:"
echo "  Host: $RDP_HOST"
echo "  Port: $RDP_PORT"
echo "  Username: $RDP_USER"
echo "  Password: $RDP_PASS"
echo ""

# Detect OS and suggest appropriate RDP client
OS=$(uname -s)
case $OS in
    Linux*)
        echo "🐧 Linux detected - RDP connection options:"
        echo ""
        
        # Check for remmina
        if command -v remmina &> /dev/null; then
            echo "📱 Option 1: Remmina (GUI RDP client)"
            echo "  remmina -c rdp://$RDP_USER:$RDP_PASS@$RDP_HOST:$RDP_PORT"
            echo ""
            read -p "❓ Connect using Remmina? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🚀 Launching Remmina..."
                remmina -c "rdp://$RDP_USER:$RDP_PASS@$RDP_HOST:$RDP_PORT" &
                exit 0
            fi
        fi
        
        # Check for xfreerdp
        if command -v xfreerdp &> /dev/null; then
            echo "📱 Option 2: FreeRDP (command line RDP client)"
            echo "  xfreerdp /v:$RDP_HOST:$RDP_PORT /u:$RDP_USER /p:$RDP_PASS /clipboard"
            echo ""
            read -p "❓ Connect using FreeRDP? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🚀 Launching FreeRDP..."
                xfreerdp /v:$RDP_HOST:$RDP_PORT /u:$RDP_USER /p:$RDP_PASS /clipboard
                exit 0
            fi
        fi
        
        echo "📦 Install an RDP client:"
        echo "  sudo apt install remmina remmina-plugin-rdp  # For Remmina"
        echo "  sudo apt install freerdp2-x11               # For FreeRDP"
        ;;
        
    Darwin*)
        echo "🍎 macOS detected - RDP connection options:"
        echo ""
        echo "📱 Option 1: Microsoft Remote Desktop (Mac App Store)"
        echo "  Create new connection with details above"
        echo ""
        echo "📱 Option 2: Built-in Screen Sharing (requires manual setup)"
        echo "  Go to Finder > Go > Connect to Server"
        echo "  Enter: rdp://$RDP_HOST:$RDP_PORT"
        ;;
        
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        echo "🪟 Windows detected - RDP connection options:"
        echo ""
        echo "📱 Option 1: Built-in Remote Desktop Connection"
        echo "  Run: mstsc"
        echo "  Computer: $RDP_HOST:$RDP_PORT"
        echo "  Username: $RDP_USER"
        echo "  Password: $RDP_PASS"
        echo ""
        read -p "❓ Launch Remote Desktop Connection? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🚀 Launching Remote Desktop Connection..."
            mstsc /v:$RDP_HOST:$RDP_PORT
            exit 0
        fi
        ;;
        
    *)
        echo "❓ Unknown OS: $OS"
        echo ""
        echo "Use any RDP client with these connection details:"
        echo "  Server: $RDP_HOST:$RDP_PORT"
        echo "  Username: $RDP_USER"
        echo "  Password: $RDP_PASS"
        ;;
esac

echo ""
echo "💡 Tips:"
echo "  • Enable clipboard sharing in your RDP client for copy/paste support"
echo "  • Use full screen mode for the best investigation experience"
echo "  • The container provides a complete XFCE4 desktop environment"
echo ""
echo "📁 Container file locations:"
echo "  • Analysis workspace: /home/dfiruser/analysis"
echo "  • Phishing files: /home/dfiruser/phishing (read-only)"
echo "  • Desktop shortcuts: /home/dfiruser/Desktop"
echo ""
echo "🛠️  DFIR Tools available:"
echo "  • Firefox for link analysis"
echo "  • LibreOffice for document analysis"
echo "  • ClamAV for malware scanning"
echo "  • Python tools: oletools, pdfplumber, yara-python"
echo "  • File analysis: binwalk, exiftool, hexedit"
echo "  • Run 'source ~/dfir-tools.sh' in a terminal for tool shortcuts"