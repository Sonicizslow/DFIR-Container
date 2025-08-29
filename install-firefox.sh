#!/bin/bash

# Script to install real Firefox in DFIR container
# This can be run after container startup to get working Firefox

echo "Installing Firefox from Mozilla repository..."

# Remove the snap transitional package
apt-get remove -y firefox

# Install dependencies
apt-get update
apt-get install -y wget gnupg

# Add Mozilla's signing key and repository
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | apt-key add -
echo "deb https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list

# Set package preferences to prioritize Mozilla repository
cat << EOF > /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# Update and install Firefox
apt-get update
apt-get install -y firefox

echo "Firefox installation completed!"
echo "Firefox can now be launched from the Applications menu or by running 'firefox' command"