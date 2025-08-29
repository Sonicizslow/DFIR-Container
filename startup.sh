#!/bin/bash

# DFIR Container startup script
# Ensures proper initialization and permissions

echo "Starting DFIR Container..."

# Ensure proper permissions for dfiruser directories
chown -R dfiruser:dfiruser /home/dfiruser

# Create analysis directory if it doesn't exist
mkdir -p /home/dfiruser/analysis
chown dfiruser:dfiruser /home/dfiruser/analysis

# Ensure VNC directories have correct permissions
mkdir -p /home/dfiruser/.vnc
chown -R dfiruser:dfiruser /home/dfiruser/.vnc
chmod 700 /home/dfiruser/.vnc

# Kill any existing VNC sessions
su - dfiruser -c "vncserver -kill :1" 2>/dev/null || true

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf