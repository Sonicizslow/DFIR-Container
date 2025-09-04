#!/bin/bash

# DFIR Container RDP Demo Script
# Demonstrates the new RDP functionality

echo "================================="
echo "  DFIR Container RDP Migration"
echo "  Demonstration Script"
echo "================================="
echo ""

echo "📋 Migration Summary:"
echo "  ❌ BEFORE: VNC (tightvncserver + noVNC)"
echo "     • Web browser access: http://localhost:6080"
echo "     • Direct VNC: localhost:5901"
echo "     • Required web browser for access"
echo "     • Clipboard issues in some browsers"
echo ""
echo "  ✅ AFTER: RDP (XRDP)"
echo "     • Native RDP access: localhost:3389"
echo "     • Works with all standard RDP clients"
echo "     • Better clipboard integration"
echo "     • More reliable connections"
echo ""

echo "🔧 Technical Changes:"
echo "  • Dockerfile: Replaced VNC packages with XRDP"
echo "  • Port: Changed from 5901/6080 to 3389"
echo "  • Service: XRDP daemon instead of VNC server"
echo "  • Desktop: Still uses XFCE4 (unchanged)"
echo ""

echo "🚀 Usage:"
echo "  1. Start container: docker-compose up -d"
echo "  2. Connect via script: ./connect-rdp.sh"
echo "  3. Manual connection:"
echo "     • Host: localhost:3389"
echo "     • Username: dfiruser"
echo "     • Password: dfirpassword"
echo ""

echo "💻 Supported Clients:"
echo "  • Windows: Built-in Remote Desktop Connection"
echo "  • Linux: Remmina, FreeRDP"
echo "  • macOS: Microsoft Remote Desktop"
echo ""

echo "✨ Benefits:"
echo "  • No browser required"
echo "  • Better performance"
echo "  • Native clipboard support"
echo "  • More stable connections"
echo "  • Faster startup"
echo ""

if [ -f "./connect-rdp.sh" ]; then
    echo "🎯 Ready to test:"
    echo "  Run: ./connect-rdp.sh"
    echo ""
    
    read -p "Would you like to see the connection script help? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "📄 Connection Script Preview:"
        echo "----------------------------------------"
        head -20 ./connect-rdp.sh | grep -E "^#|echo"
        echo "----------------------------------------"
        echo "(Use ./connect-rdp.sh for full functionality)"
    fi
else
    echo "⚠️  Connection script not found. Please ensure you're in the repository directory."
fi

echo ""
echo "📖 For complete documentation, see:"
echo "  • README.md - Updated usage instructions"
echo "  • RDP-MIGRATION-SUMMARY.md - Detailed migration notes"
echo ""
echo "🎉 VNC to RDP migration complete!"