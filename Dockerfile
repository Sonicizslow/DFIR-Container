# DFIR Container for investigating suspicious files and links
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update && apt-get install -y \
    # Desktop environment
    xfce4 xfce4-goodies \
    # RDP server
    xrdp \
    # Office and document tools
    libreoffice \
    evince \
    # PDF analysis tools
    poppler-utils \
    pdfgrep \
    # Security tools
    clamav clamav-daemon \
    # Network tools
    curl wget net-tools \
    # File analysis tools
    file \
    hexedit \
    binwalk \
    exiftool \
    # Text editors
    nano vim \
    # Archive tools
    unzip p7zip-full \
    # Python for custom analysis
    python3 python3-pip \
    # Clipboard management for copy/paste support
    autocutsel xsel xclip \
    # System utilities
    sudo \
    supervisor \
    # Required for installing Firefox manually
    software-properties-common \
    gnupg \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox by running installation script during build
COPY install-firefox.sh /tmp/install-firefox.sh
RUN chmod +x /tmp/install-firefox.sh && \
    /tmp/install-firefox.sh && \
    rm /tmp/install-firefox.sh

# Install Python packages for document analysis
RUN pip3 install --no-cache-dir --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org \
    oletools \
    pdfplumber \
    yara-python \
    requests \
    beautifulsoup4

# Create non-root user for DFIR work
RUN useradd -m -s /bin/bash -G sudo dfiruser && \
    echo 'dfiruser:dfirpassword' | chpasswd

# Configure XRDP for XFCE4
RUN echo 'xfce4-session' > /home/dfiruser/.xsession && \
    chown dfiruser:dfiruser /home/dfiruser/.xsession && \
    chmod +x /home/dfiruser/.xsession

# Create directories for file analysis
RUN mkdir -p /home/dfiruser/analysis /home/dfiruser/phishing && \
    chown -R dfiruser:dfiruser /home/dfiruser/analysis /home/dfiruser/phishing

# Create desktop directory and Firefox shortcut for easy access
RUN mkdir -p /home/dfiruser/Desktop && \
    echo '[Desktop Entry]\n\
Version=1.0\n\
Name=Firefox\n\
Comment=Web Browser\n\
Exec=firefox\n\
Icon=firefox\n\
Terminal=false\n\
Type=Application\n\
Categories=Network;WebBrowser;\n\
StartupNotify=true' > /home/dfiruser/Desktop/firefox.desktop && \
    chmod +x /home/dfiruser/Desktop/firefox.desktop && \
    chown -R dfiruser:dfiruser /home/dfiruser/Desktop

# Configure supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy DFIR tools script
COPY dfir-tools.sh /home/dfiruser/dfir-tools.sh
RUN chmod +x /home/dfiruser/dfir-tools.sh && \
    chown dfiruser:dfiruser /home/dfiruser/dfir-tools.sh

# Copy startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Add dfir-tools to bashrc for easy access
RUN echo 'source ~/dfir-tools.sh' >> /home/dfiruser/.bashrc && \
    chown dfiruser:dfiruser /home/dfiruser/.bashrc

# Update ClamAV database (allow failure in build environment)
RUN freshclam || echo "ClamAV update failed in build environment (normal)"

# Set working directory
WORKDIR /home/dfiruser

EXPOSE 3389

# Use startup script to ensure proper initialization
CMD ["/usr/local/bin/startup.sh"]