#!/bin/bash

# DFIR Container startup script
# Ensures proper initialization and permissions

echo "Starting DFIR Container..."

# Ensure proper permissions for dfiruser directories (excluding mounted volumes)
chown dfiruser:dfiruser /home/dfiruser/.bashrc 2>/dev/null || true
chown dfiruser:dfiruser /home/dfiruser/dfir-tools.sh 2>/dev/null || true

# Create analysis directory if it doesn't exist and set permissions
mkdir -p /home/dfiruser/analysis
chown dfiruser:dfiruser /home/dfiruser/analysis 2>/dev/null || true

# Ensure VNC directories have correct permissions
mkdir -p /home/dfiruser/.vnc
chown -R dfiruser:dfiruser /home/dfiruser/.vnc 2>/dev/null || true
chmod 700 /home/dfiruser/.vnc

# Create Desktop directory and Firefox shortcut for easy access
mkdir -p /home/dfiruser/Desktop
cat > /home/dfiruser/Desktop/firefox.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupNotify=true
EOF
chmod +x /home/dfiruser/Desktop/firefox.desktop
chown -R dfiruser:dfiruser /home/dfiruser/Desktop 2>/dev/null || true

# Kill any existing VNC sessions
su - dfiruser -c "vncserver -kill :1" 2>/dev/null || true

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf