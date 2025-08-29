#!/bin/bash

# DFIR Analysis Helper Script
# This script provides common DFIR analysis functions

echo "=== DFIR Analysis Tools ==="
echo "Available commands:"
echo "  analyze-pdf <file>     - Analyze PDF file for suspicious content"
echo "  analyze-office <file>  - Analyze Office document for macros/suspicious content"  
echo "  scan-malware <file>    - Scan file with ClamAV"
echo "  check-url <url>        - Check URL safety and download for analysis"
echo "  extract-metadata <file> - Extract metadata from file"
echo "  hex-view <file>        - View file in hex editor"
echo "  file-info <file>       - Get detailed file information"
echo ""

analyze_pdf() {
    if [ -z "$1" ]; then
        echo "Usage: analyze-pdf <file>"
        return 1
    fi
    
    echo "Analyzing PDF: $1"
    echo "=== File Info ==="
    file "$1"
    echo ""
    
    echo "=== PDF Info ==="
    pdfinfo "$1" 2>/dev/null
    echo ""
    
    echo "=== Searching for suspicious content ==="
    pdfgrep -i "javascript\|activex\|embed\|launch" "$1" 2>/dev/null || echo "No suspicious keywords found"
    echo ""
    
    echo "=== Extracting text ==="
    pdftotext "$1" - | head -20
}

analyze_office() {
    if [ -z "$1" ]; then
        echo "Usage: analyze-office <file>"
        return 1
    fi
    
    echo "Analyzing Office document: $1"
    echo "=== File Info ==="
    file "$1"
    echo ""
    
    echo "=== Metadata ==="
    exiftool "$1"
    echo ""
    
    echo "=== OLE Analysis ==="
    python3 -c "
try:
    from oletools.olevba import VBA_Parser
    vba_parser = VBA_Parser('$1')
    if vba_parser.detect_vba_macros():
        print('VBA Macros detected!')
        for (filename, stream_path, vba_filename, vba_code) in vba_parser.extract_macros():
            print(f'Macro in {vba_filename}:')
            print(vba_code[:500] + '...' if len(vba_code) > 500 else vba_code)
    else:
        print('No VBA macros detected')
except ImportError:
    print('oletools not available for macro analysis')
except Exception as e:
    print(f'Error analyzing macros: {e}')
"
}

scan_malware() {
    if [ -z "$1" ]; then
        echo "Usage: scan-malware <file>"
        return 1
    fi
    
    echo "Scanning for malware: $1"
    clamscan "$1"
}

check_url() {
    if [ -z "$1" ]; then
        echo "Usage: check-url <url>"
        return 1
    fi
    
    echo "Checking URL: $1"
    echo "=== URL Headers ==="
    curl -I "$1" 2>/dev/null || echo "Failed to fetch headers"
    echo ""
    
    echo "=== Downloading for analysis ==="
    filename=$(basename "$1")
    if [ -z "$filename" ] || [ "$filename" = "/" ]; then
        filename="downloaded_content"
    fi
    
    curl -L -o "/tmp/$filename" "$1" 2>/dev/null && echo "Downloaded to /tmp/$filename" || echo "Download failed"
}

extract_metadata() {
    if [ -z "$1" ]; then
        echo "Usage: extract-metadata <file>"
        return 1
    fi
    
    echo "Extracting metadata from: $1"
    exiftool "$1"
}

hex_view() {
    if [ -z "$1" ]; then
        echo "Usage: hex-view <file>"
        return 1
    fi
    
    hexedit "$1"
}

file_info() {
    if [ -z "$1" ]; then
        echo "Usage: file-info <file>"
        return 1
    fi
    
    echo "Detailed file information for: $1"
    echo "=== Basic Info ==="
    file "$1"
    ls -la "$1"
    echo ""
    
    echo "=== File signature ==="
    xxd "$1" | head -5
    echo ""
    
    echo "=== Strings (first 20) ==="
    strings "$1" | head -20
}

# Make functions available as commands
alias analyze-pdf='analyze_pdf'
alias analyze-office='analyze_office'
alias scan-malware='scan_malware' 
alias check-url='check_url'
alias extract-metadata='extract_metadata'
alias hex-view='hex_view'
alias file-info='file_info'