#!/bin/bash

# Define target IP and port range
TARGET_IP="192.168.1.1"
START_PORT=1024
END_PORT=65535

# Output file for scan results
OUTPUT_FILE="data/raw/initial_scan_results.json"

# Clear previous scan results if exists
> "$OUTPUT_FILE"

# Function to check if a port is open
check_port() {
    local PORT=$1
    timeout 1 bash -c "echo >/dev/tcp/$TARGET_IP/$PORT" &>/dev/null && echo $PORT >> /tmp/open_ports.txt
}

# Scan ports in the specified range
for ((port=START_PORT; port<=END_PORT; port++)); do
    check_port $port &
done

# Wait for all background processes to finish
wait

# Collect open ports and save results as JSON
OPEN_PORTS=$(cat /tmp/open_ports.txt | tr '\n' ',' | sed 's/,$//')
echo "{\"target_ip\": \"$TARGET_IP\", \"open_ports\": [$OPEN_PORTS]}" > "$OUTPUT_FILE"

# Clean up temporary file
rm /tmp/open_ports.txt

echo "Port scanning completed. Results saved in $OUTPUT_FILE"
