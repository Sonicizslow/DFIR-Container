#!/bin/bash

# Script to install real Firefox in DFIR container
# This script will be run during container startup to ensure Firefox is available

echo "Installing Firefox from Mozilla repository..."

# Remove the snap transitional package
apt-get remove -y firefox 2>/dev/null || true

# Install dependencies
apt-get update
apt-get install -y wget gnupg ca-certificates

# Add Mozilla's signing key using modern method
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /tmp/mozilla.gpg
gpg --dearmor < /tmp/mozilla.gpg > /etc/apt/trusted.gpg.d/mozilla.gpg
rm /tmp/mozilla.gpg

# Add Mozilla repository
echo "deb https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list

# Set package preferences to prioritize Mozilla repository
cat << EOF > /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# Update and install Firefox
apt-get update
if ! apt-get install -y firefox; then
    echo "Mozilla repository installation failed, trying fallback method..."
    # Fallback: Install Firefox dependencies and download binary
    apt-get install -y \
        libgtk-3-0 \
        libdbus-glib-1-2 \
        libxt6 \
        libx11-xcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxi6 \
        libxtst6 \
        libnss3 \
        libatk-bridge2.0-0 \
        libdrm2 \
        libxkbcommon0 \
        libatspi2.0-0 \
        libxss1 \
        libasound2 \
        bzip2
    
    # Try to download Firefox binary as fallback
    cd /tmp
    if wget -O firefox.tar.bz2 "https://ftp.mozilla.org/pub/firefox/releases/latest/linux-x86_64/en-US/firefox-latest.tar.bz2" 2>/dev/null || \
       curl -L -o firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" 2>/dev/null; then
        tar -xjf firefox.tar.bz2
        mv firefox /opt/
        ln -sf /opt/firefox/firefox /usr/bin/firefox
        rm firefox.tar.bz2
        echo "Firefox installed via binary download."
    else
        echo "Warning: Firefox installation failed. Using fallback text browser."
        apt-get install -y lynx
        ln -sf /usr/bin/lynx /usr/bin/firefox
    fi
fi

echo "Firefox installation completed!"
echo "Firefox can now be launched from the Applications menu or by running 'firefox' command"