# DFIR Container Permission Fix Summary

## Issues Fixed

The original Docker Compose setup had permission errors that prevented the container from starting:

```
chown: changing ownership of '/home/dfiruser/downloads/...': Read-only file system
chown: changing ownership of '/home/dfiruser/analysis': Operation not permitted  
Error: Can't drop privilege as nonroot user
vncserver: The USER environment variable is not set.
```

## Root Cause

1. **User Restriction Conflict**: `user: "1000:1000"` in docker-compose.yml forced the container to run as non-root from startup
2. **Permission Setup Failure**: The startup script needed root privileges to set file permissions with `chown`
3. **Supervisord Privilege Issues**: Supervisord couldn't drop privileges because it was already running as non-root
4. **Read-only Mount Issues**: The startup script tried to `chown -R` the entire `/home/dfiruser` directory, including read-only mounted volumes
5. **VNC Environment Variable**: The VNC server required the USER environment variable to be set when running as dfiruser through supervisord

## Changes Made

### 1. Directory Mount Change
- **Before**: `${HOME}/Downloads:/home/dfiruser/downloads:ro`  
- **After**: `${HOME}/phishing:/home/dfiruser/phishing:ro`

### 2. Container User Strategy  
- **Before**: Container forced to run as `user: "1000:1000"` from startup
- **After**: Container starts as root, performs setup, then supervisord drops privileges to `dfiruser` for services

### 3. Startup Script Fix
- **Before**: `chown -R dfiruser:dfiruser /home/dfiruser` (failed on read-only mounts)
- **After**: Selective permission setting on specific files/directories only

### 4. VNC Environment Variable Fix
- **Before**: VNC server failing with "USER environment variable is not set" error
- **After**: Added `environment=USER=dfiruser` to both vncserver and novnc programs in supervisord.conf

### 5. Files Updated
- `docker-compose.yml` - Changed mount point and removed user restriction
- `startup.sh` - Fixed permission handling to avoid read-only volumes  
- `Dockerfile` - Updated to create phishing directory instead of downloads
- `README.md` - Updated all documentation references
- `quick-start.sh` - Updated for phishing directory
- `.env.example` - Updated path variables
- `supervisord.conf` - Added USER environment variable for VNC processes

## Security Model

✅ **Container starts as root** - Only for initial setup and permission management  
✅ **Services run as dfiruser** - VNC server, noVNC, and user applications run as non-root  
✅ **Read-only phishing mount** - Host files mounted read-only for safety  
✅ **No new privileges** - Security option prevents privilege escalation  
✅ **Resource limits** - Memory and CPU limits applied  

## Testing

Run the verification script to confirm the fix:

```bash
./verify-fix.sh
```

## Usage

1. **Create phishing directory**: `mkdir -p ~/phishing`
2. **Copy suspicious files**: Place files to analyze in `~/phishing/`  
3. **Start container**: `docker-compose up -d`
4. **Access via browser**: `http://localhost:6080`
5. **Files available at**: `/home/dfiruser/phishing/` (read-only)
6. **Analysis workspace**: `/home/dfiruser/analysis/` (writable)