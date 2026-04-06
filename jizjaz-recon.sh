#!/bin/bash

# JIZJAZ RECON - Professional Reconnaissance Tool
# Colors
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
BOLD='\e[1m'
NC='\e[0m' # No Color

# Banner ASCII (Improved JIZJAZ Branding)
echo -e "${CYAN}${BOLD}"
cat << "EOF"
      _ _ ______      _   _   ______ 
     | | |___  /     | | / \ |___  / 
     | | |  / /      | |/ _ \   / /  
  _  | | | / /    _  | / ___ \ / /   
 | |_| |_|/ /___ | |_|/ /   \ \/ /___
  \___/|_/_____/ \___/_/   \_\/____/ 
                                     
      [ JIZJAZ RECONNAISSANCE v2.0 ]
EOF
echo -e "${NC}"
echo -e "${YELLOW}${BOLD}[*] System: $(uname -s) | User: $(whoami) | Date: $(date)${NC}"
echo -e "${MAGENTA}================================================================================${NC}"

# Usage check
if [ -z "$1" ]; then
    echo -e "${RED}[!] Usage: ./jizjaz-recon.sh <target_domain_or_ip>${NC}"
    exit 1
fi

TARGET=$1
OUTPUT_DIR="output/$TARGET"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

# Create output directory
mkdir -p "$OUTPUT_DIR"
echo -e "${BLUE}[➤] Initializing workspace at: ${BOLD}$OUTPUT_DIR${NC}"

# 1. Nmap Scanning (Top 1000 ports)
echo -e "\n${GREEN}${BOLD}[STAGE 01] Performing Advanced Nmap Discovery...${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
nmap -sV --top-ports 1000 "$TARGET" -oN "$OUTPUT_DIR/nmap_$DATE.txt"
echo -e "${YELLOW}[!] Discovery results saved to: $OUTPUT_DIR/nmap_$DATE.txt${NC}"

# 2. HTTP Fuzzing with FFUF
WORDLIST="/usr/share/wordlists/dirb/common.txt"
[ ! -f "$WORDLIST" ] && WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"

echo -e "\n${GREEN}${BOLD}[STAGE 02] Launching FFUF Directory Fuzzing...${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
HTTP_URL="http://$TARGET"

# Run FFUF
ffuf -u "$HTTP_URL/FUZZ" -w "$WORDLIST" -t 50 -mc 200,204,301,302,307,401,403 -o "$OUTPUT_DIR/ffuf_$DATE.json" -of json -s

# Create a neat summary using jq
if command -v jq &> /dev/null; then
    SUMMARY_FILE="$OUTPUT_DIR/ffuf_summary_$DATE.txt"
    echo -e "STATUS\tSIZE\tWORDS\tURL" > "$SUMMARY_FILE"
    echo -e "------\t----\t-----\t---" >> "$SUMMARY_FILE"
    jq -r '.results[] | "\(.status)\t\(.length)\t\(.words)\t\(.url)"' "$OUTPUT_DIR/ffuf_$DATE.json" | sort -k1 -n >> "$SUMMARY_FILE"
    
    echo -e "${MAGENTA}[#] HIGH-VALUE ENDPOINTS DETECTED:${NC}"
    head -n 15 "$SUMMARY_FILE" | column -t
    echo -e "\n${YELLOW}[!] Detailed summary: $SUMMARY_FILE${NC}"
else
    echo -e "${RED}[!] jq not found, skipping visual summary.${NC}"
fi

# 3. Spidering & Endpoint Discovery with Katana
echo -e "\n${GREEN}${BOLD}[STAGE 03] Deploying Katana Crawler...${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
if command -v katana &> /dev/null; then
    KATANA_OUT="$OUTPUT_DIR/katana_endpoints.txt"
    katana -u "$HTTP_URL" -o "$KATANA_OUT" -silent
    ENDPOINTS_COUNT=$(wc -l < "$KATANA_OUT" 2>/dev/null || echo "0")
    echo -e "${MAGENTA}[#] Discovery complete: ${BOLD}$ENDPOINTS_COUNT unique endpoints found.${NC}"
    echo -e "${YELLOW}[!] Endpoint list: $KATANA_OUT${NC}"
else
    echo -e "${RED}[!] Katana not found, skipping spidering phase.${NC}"
fi

# 4. SSL/TLS Vulnerability Scan
echo -e "\n${GREEN}${BOLD}[STAGE 04] Auditing SSL/TLS Security...${NC}"
echo -e "${CYAN}--------------------------------------------------------------------------------${NC}"
nmap --script ssl-enum-ciphers,ssl-heartbleed,ssl-ccs-injection -p 443 "$TARGET" -oN "$OUTPUT_DIR/ssl_$DATE.txt"
echo -e "${YELLOW}[!] Audit results: $OUTPUT_DIR/ssl_$DATE.txt${NC}"

echo -e "\n${MAGENTA}================================================================================${NC}"
echo -e "${GREEN}${BOLD}[✔] JIZJAZ RECON COMPLETE! Access all data in: $OUTPUT_DIR${NC}"
echo -e "${MAGENTA}================================================================================${NC}"
