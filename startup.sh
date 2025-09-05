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

# Ensure XRDP configuration has correct permissions
chown dfiruser:dfiruser /home/dfiruser/.xsession 2>/dev/null || true

# Note: Browser desktop shortcuts moved to separate dfir-browser container

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf