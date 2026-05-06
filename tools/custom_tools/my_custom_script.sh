#!/bin/bash

# Function to log messages with timestamps
log_message() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> /var/log/my_custom_script.log
}

# Function to read configuration from a file
read_config() {
    if [[ ! -f "$1" ]]; then
        log_message "Configuration file does not exist."
        return 1
    fi

    source "$1"
    log_message "Configuration loaded successfully from $1."
}

# Function to execute a shell command and capture its output
run_command() {
    local result=$(eval "$1" 2>&1)
    if [[ $? -eq 0 ]]; then
        log_message "Command executed successfully: $1"
        echo "$result"
    else
        log_message "Command failed: $1. Error: $result"
        return 1
    fi
}

# Function to calculate MD5 hash of a file
calculate_md5() {
    if [[ ! -f "$1" ]]; then
        log_message "File does not exist."
        return 1
    fi

    local md5_hash=$(md5sum "$1" | awk '{ print $1 }')
    log_message "MD5 hash calculated for $1."
    echo "$md5_hash"
}

# Function to encode data in base64
encode_base64() {
    local encoded_data=$(echo -n "$1" | base64)
    log_message "Data encoded in base64."
    echo "$encoded_data"
}

# Function to decode base64 encoded data
decode_base64() {
    local decoded_data=$(echo -n "$1" | base64 --decode)
    log_message "Base64 data decoded successfully."
    echo "$decoded_data"
}

# Function to check if a port is open on a given IP address
is_port_open() {
    local ip_address="$1"
    local port="$2"

    if nc -zv "$ip_address" "$port" 2>/dev/null; then
        log_message "Port $port on $ip_address is open."
        return 0
    else
        log_message "Port $port on $ip_address is closed."
        return 1
    fi
}

# Function to send data over a TCP socket
send_data() {
    local ip_address="$1"
    local port="$2"
    local data="$3"

    echo -n "$data" | nc "$ip_address" "$port"
    log_message "Data sent successfully to $ip_address:$port."
}

# Function to receive data over a TCP socket
receive_data() {
    local ip_address="$1"
    local port="$2"

    while true; do
        nc -lvp "$port" | while read line; do
            echo "$line"
            log_message "Data received successfully from $ip_address."
            break
        done
        break
    done
}

# Function to calculate the current system uptime
get_system_uptime() {
    local uptime_seconds=$(cat /proc/uptime | awk '{ print $1 }')
    local uptime=$((uptime_seconds / 60))
    log_message "System uptime calculated."
    echo "$uptime"
}

# Function to get the current network interfaces and their status
get_network_interfaces() {
    local interfaces=$(ip link show)
    log_message "Network interfaces retrieved."
    echo "$interfaces"
}

# Function to create a report file with system information
generate_report() {
    local report_data=$(cat <<EOF
{
  "system_uptime": $(get_system_uptime),
  "network_interfaces": "$(get_network_interfaces)",
  "current_time": "$(date -Is)"
}
EOF
)
    local report_file_path="/var/reports/report_$(date +%Y%m%d%H%M%S).json"

    echo "$report_data" > "$report_file_path"
    log_message "Report generated and saved to $report_file_path."
}

# Function to monitor system processes and log any suspicious activity
monitor_processes() {
    while true; do
        for proc in $(ps aux); do
            if [[ "$proc" == *"malware"* ]] || [[ "$proc" == *"backdoor"* ]]; then
                log_message "Suspicious process detected: $proc"
            fi
        done
        sleep 60
    done
}

# Main function to control the flow
main() {
    log_message "Starting my_custom_script.sh."

    # Read configuration
    read_config "/etc/my_custom_tool.conf"

    # Generate report
    generate_report

    # Monitor system processes
    monitor_processes &

    # Example of sending data over a socket
    ip_address="127.0.0.1"
    port=8080
    data_to_send="Hello, this is a test message."
    send_data "$ip_address" "$port" "$data_to_send"

    # Example of receiving data over a socket
    received_data=$(receive_data "$ip_address" "$port")
    if [[ -n "$received_data" ]]; then
        log_message "Received data: $received_data"
    fi

    # Check if a specific port is open
    if is_port_open "$ip_address" "$port"; then
        log_message "Port is open."
    else
        log_message "Port is closed."
    fi

    # Calculate MD5 hash of a file
    file_path="/var/data/sample_data.bin"
    md5_hash=$(calculate_md5 "$file_path")
    if [[ -n "$md5_hash" ]]; then
        log_message "MD5 hash of $file_path: $md5_hash"
    fi

    # Encode and decode data in base64
    original_data="This is some test data."
    encoded_data=$(encode_base64 "$original_data")
    decoded_data=$(decode_base64 "$encoded_data")
    if [[ -n "$decoded_data" ]]; then
        log_message "Decoded data: $decoded_data"
    fi

    # Run a shell command
    command_output=$(run_command "ls -l")
    if [[ -n "$command_output" ]]; then
        log_message "Command output: $command_output"
    fi

    log_message "my_custom_script.sh execution completed."
}

# Run main function
main
