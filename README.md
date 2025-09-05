# DFIR-Container

A Docker container for Digital Forensics and Incident Response (DFIR) investigations. This container provides a secure, web-based desktop environment for analyzing suspicious files, links, and attachments such as PDFs and Office documents.

## Features

- **RDP Access**: Secure Remote Desktop Protocol access to the container desktop
- **Non-root Security**: Runs as a non-privileged user for enhanced security
- **File Analysis Tools**: Includes tools for PDF, Office document, and general file analysis
- **Malware Scanning**: Built-in ClamAV antivirus scanning
- **Read-only Downloads Access**: Maps the phishing user's Downloads folder as read-only for safe file access
- **Copy/Paste Support**: Full clipboard integration through RDP clients

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- A 'phishing' user account on your host system with a Downloads folder

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

- **Downloads**: The phishing user's Downloads folder is mounted at `/home/dfiruser/phishing/Downloads` (read-only)
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

1. **File Transfer**: Suspicious files should be placed in `/home/phishing/Downloads` on the host
2. **Access Container**: Connect via RDP using any RDP client to `localhost:3391`
3. **Navigate to Files**: Files are available in `/home/dfiruser/phishing/Downloads`
4. **Analyze**: Use the built-in tools or GUI applications:
   ```bash
   # In the container terminal:
   source ~/dfir-tools.sh
   analyze-pdf ~/phishing/Downloads/suspicious.pdf
   scan-malware ~/phishing/Downloads/document.docx
   ```

### Available Applications

- **Web Browser**: Epiphany (GNOME Web) browser for link investigation, accessible via `firefox` command
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

### File Access

The container is configured to access files from a fixed location:
- Host path: `/home/phishing/Downloads` (the phishing user's Downloads folder)
- Container path: `/home/dfiruser/phishing/Downloads` (read-only)

Ensure that:
1. A user named "phishing" exists on your host system
2. The `/home/phishing/Downloads` directory exists and contains the files you want to analyze

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
- Verify the phishing user's Downloads folder exists at `/home/phishing/Downloads`

### Volume path errors
If you see volume-related errors:
- Ensure the phishing user exists on your host system
- Verify `/home/phishing/Downloads` directory exists and is accessible
- Check that the path `/home/phishing/Downloads` has appropriate permissions

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

## Development

To rebuild the container after making changes:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## License

This project is provided as-is for DFIR and security research purposes.
