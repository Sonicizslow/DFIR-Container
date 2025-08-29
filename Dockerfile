# DFIR Container for investigating suspicious files and links
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system packages
RUN apt-get update && apt-get install -y \
    # Desktop environment
    xfce4 xfce4-goodies \
    # VNC server and web interface
    tightvncserver novnc websockify \
    # Web browsers
    firefox-esr \
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
    # System utilities
    sudo \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for document analysis
RUN pip3 install --no-cache-dir \
    oletools \
    pdfplumber \
    yara-python \
    requests \
    beautifulsoup4

# Create non-root user for DFIR work
RUN useradd -m -s /bin/bash -G sudo dfiruser && \
    echo 'dfiruser:dfirpassword' | chpasswd && \
    mkdir -p /home/dfiruser/.vnc

# Configure VNC
RUN echo 'dfirpassword' | vncpasswd -f > /home/dfiruser/.vnc/passwd && \
    chmod 600 /home/dfiruser/.vnc/passwd && \
    chown -R dfiruser:dfiruser /home/dfiruser/.vnc

# Create xstartup file for VNC
RUN echo '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &' > /home/dfiruser/.vnc/xstartup && \
    chmod +x /home/dfiruser/.vnc/xstartup && \
    chown dfiruser:dfiruser /home/dfiruser/.vnc/xstartup

# Create directories for file analysis
RUN mkdir -p /home/dfiruser/analysis /home/dfiruser/downloads && \
    chown -R dfiruser:dfiruser /home/dfiruser/analysis /home/dfiruser/downloads

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

# Update ClamAV database
RUN freshclam

# Set working directory
WORKDIR /home/dfiruser

# Set VNC display
ENV DISPLAY=:1

EXPOSE 5901 6080

# Use startup script to ensure proper initialization
CMD ["/usr/local/bin/startup.sh"]