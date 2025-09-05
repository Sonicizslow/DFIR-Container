# DFIR-Container

A Docker container for Digital Forensics and Incident Response (DFIR) investigations. This container provides a secure, web-based desktop environment for analyzing suspicious files, links, and attachments such as PDFs and Office documents.

## Features

- **RDP Access**: Secure Remote Desktop Protocol access to container desktops
- **Non-root Security**: Runs as a non-privileged user for enhanced security
- **Separate Browser Container**: Dedicated browser container with proper permissions for web investigation
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

2. Start the containers:
   ```bash
   docker-compose up -d
   ```

3. Access the containers:
   - **Main DFIR Analysis Container**:
     - Host: `localhost:3391`
     - Username: `dfiruser`
     - Password: `dfirpassword`
   - **Browser Container** (for link investigation):
     - Host: `localhost:3392`
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

**Main DFIR Container:**
- **LibreOffice**: Office document analysis
- **Evince**: PDF viewer
- **Text Editors**: nano, vim for file inspection
- **Hex Editors**: hexedit for binary analysis

**Browser Container:**
- **Epiphany (GNOME Web)**: Dedicated web browser for link investigation with proper sandboxing support

## Security Considerations

- **Main DFIR Container**: Runs with strict security (`no-new-privileges:true`) for safe file analysis
- **Browser Container**: Runs with minimal additional privileges needed for browser sandboxing
- Phishing folder is mounted read-only in both containers
- Resource limits applied (Main: 2GB RAM, 2 CPU cores; Browser: 1GB RAM, 1 CPU core)
- ClamAV antivirus included for malware detection
- Both containers run services as non-root user (`dfiruser`)

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
- Check if ports 3391 and 3392 are available
- Verify the phishing user's Downloads folder exists at `/home/phishing/Downloads`

### Volume path errors
If you see volume-related errors:
- Ensure the phishing user exists on your host system
- Verify `/home/phishing/Downloads` directory exists and is accessible
- Check that the path `/home/phishing/Downloads` has appropriate permissions

### Can't connect via RDP
- Ensure the containers are running: `docker-compose ps`
- Check if ports are accessible: 
  - Main container: `netstat -an | grep 3391`
  - Browser container: `netstat -an | grep 3392`
- Review logs: `docker-compose logs`

### Permission issues
- Ensure your user ID matches the container user (1000:1000 by default)
- Check volume mount permissions

### Browser issues
- If browser fails to start with namespace errors, ensure you're using the dedicated browser container on port 3392
- The main container (port 3391) no longer includes a browser for security reasons
- Browser container has the necessary permissions for Epiphany's sandboxing requirements

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
