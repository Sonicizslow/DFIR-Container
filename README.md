# DFIR-Container

A Docker container for Digital Forensics and Incident Response (DFIR) investigations. This container provides a secure, web-based desktop environment for analyzing suspicious files, links, and attachments such as PDFs and Office documents.

## Features

- **RDP Access**: Secure Remote Desktop Protocol access to the container desktop
- **Non-root Security**: Runs as a non-privileged user for enhanced security
- **File Analysis Tools**: Includes tools for PDF, Office document, and general file analysis
- **Malware Scanning**: Built-in ClamAV antivirus scanning
- **Read-only Phishing Files**: Maps host phishing folder as read-only for safe file transfer
- **Copy/Paste Support**: Full clipboard integration through RDP clients

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A phishing folder on your host system (typically `~/phishing`)

### Setup and Launch

1. Clone this repository:
   ```bash
   git clone https://github.com/Sonicizslow/DFIR-Container.git
   cd DFIR-Container
   ```

2. Start the container:
   ```bash
   docker-compose up -d
   ```

3. Access the container:
   - Connect using any RDP client:
     - Host: `localhost:3391`
     - Username: `dfiruser`
     - Password: `dfirpassword`

## Usage

### Accessing Files

- **Phishing Files**: Your host phishing folder is mounted at `/home/dfiruser/phishing` (read-only)
- **Analysis Workspace**: Use `/home/dfiruser/analysis` for your investigation work

### Built-in DFIR Tools

The container includes a helper script with common analysis functions. In the terminal, source the tools:

```bash
source ~/dfir-tools.sh
```

Available commands:

- `analyze-pdf <file>` - Analyze PDF files for suspicious content
- `analyze-office <file>` - Analyze Office documents for macros and suspicious content
- `scan-malware <file>` - Scan files with ClamAV antivirus
- `check-url <url>` - Check URL safety and download for analysis
- `extract-metadata <file>` - Extract metadata from files
- `hex-view <file>` - View files in hex editor
- `file-info <file>` - Get detailed file information

### Example Investigation Workflow

1. **File Transfer**: Copy suspicious files to your phishing folder on the host
2. **Access Container**: Connect via RDP using any RDP client to `localhost:3391`
3. **Navigate to Files**: Files are available in `/home/dfiruser/phishing`
4. **Analyze**: Use the built-in tools or GUI applications:
   ```bash
   # In the container terminal:
   source ~/dfir-tools.sh
   analyze-pdf ~/phishing/suspicious.pdf
   scan-malware ~/phishing/document.docx
   ```

### Available Applications

- **Firefox**: Web browser for link investigation (run `./install-firefox.sh` as root in container to install working Firefox)
- **LibreOffice**: Office document analysis
- **Evince**: PDF viewer
- **Text Editors**: nano, vim for file inspection
- **Hex Editors**: hexedit for binary analysis

## Security Considerations

- Container starts as root for setup, then services run as non-root user (`dfiruser`)  
- Phishing folder is mounted read-only
- Resource limits applied (2GB RAM, 2 CPU cores)
- No new privileges allowed
- ClamAV antivirus included for malware detection

## Configuration

### Custom Phishing Path

Edit `docker-compose.yml` to change the phishing folder mapping:

```yaml
volumes:
  - "/path/to/your/phishing:/home/dfiruser/phishing:ro"
```

### Resource Limits

Adjust memory and CPU limits in `docker-compose.yml`:

```yaml
mem_limit: 4g  # Increase memory
cpus: 4.0      # Increase CPU cores
```

## Troubleshooting

### Container won't start
- Ensure Docker is running
- Check if port 3391 is available
- Verify your phishing folder exists

### Can't connect via RDP
- Ensure the container is running: `docker-compose ps`
- Check if port 3391 is accessible: `netstat -an | grep 3391`
- Review logs: `docker-compose logs`

### Permission issues
- Ensure your user ID matches the container user (1000:1000 by default)
- Check volume mount permissions

### Copy/Paste not working
- Enable clipboard sharing in your RDP client settings
- On Windows: Check "Clipboard" in Remote Desktop Connection
- On Linux: Use the `/clipboard` parameter with FreeRDP
- On macOS: Enable clipboard in Microsoft Remote Desktop settings

### Firefox not working
- The default Firefox installation is a transitional snap package that may not work in containers
- To install working Firefox, run as root in the container: `./install-firefox.sh`
- Alternatively, access the container and run: `docker compose exec dfir-container bash` then run the install script

## Development

To rebuild the container after making changes:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## License

This project is provided as-is for DFIR and security research purposes.
