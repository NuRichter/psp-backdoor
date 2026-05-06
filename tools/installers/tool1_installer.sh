  #!/bin/bash

# Function to log messages with timestamps
log_message() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> /var/log/tool1_installer.log
}

# Function to check if a user has root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "Installer requires root privileges. Please run as root."
        exit 1
    fi
}

# Function to check for required dependencies
check_dependencies() {
    local missing_packages=()
    for package in "$@"; do
        dpkg-query -Wf'${Status}' "$package" 2>/dev/null | grep "install ok installed" > /dev/null || missing_packages+=("$package")
    done

    if [[ ${#missing_packages[@]} -ne 0 ]]; then
        log_message "Missing dependencies: ${missing_packages[*]}"
        exit 1
    fi
}

# Function to download a file from the internet
download_file() {
    local url="$1"
    local destination="$2"

    if wget "$url" -O "$destination" 2>/dev/null; then
        log_message "File downloaded successfully: $url -> $destination"
    else
        log_message "Failed to download file: $url"
        exit 1
    fi
}

# Function to extract a compressed archive
extract_archive() {
    local archive="$1"
    local destination="${2:-$(dirname "$archive")}"

    if [[ "$archive" == *.tar.gz ]]; then
        tar -xzf "$archive" -C "$destination"
    elif [[ "$archive" == *.zip ]]; then
        unzip "$archive" -d "$destination"
    else
        log_message "Unsupported archive format: $archive"
        exit 1
    fi

    log_message "Archive extracted successfully: $archive -> $destination"
}

# Function to compile and install a package from source
install_from_source() {
    local source_url="$1"
    local destination="$2"

    download_file "$source_url" "/tmp/source.tar.gz"
    extract_archive "/tmp/source.tar.gz" "$destination"
    cd "$destination"

    ./configure && make && make install

    log_message "Package installed from source: $source_url"
}

# Function to create a systemd service
create_systemd_service() {
    local service_name="$1"
    local service_file="/etc/systemd/system/$service_name.service"

    cat <<EOF > "$service_file"
[Unit]
Description=Tool 1 Service

[Service]
ExecStart=/usr/local/bin/tool1_start.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$service_name"
    systemctl start "$service_name"

    log_message "Systemd service created and started: $service_name"
}

# Function to configure firewall rules
configure_firewall() {
    local rule="$1"

    if iptables -S | grep -q "$rule"; then
        log_message "Firewall rule already exists: $rule"
    else
        iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
        iptables-save > /etc/iptables/rules.v4

        log_message "Firewall rule added: $rule"
    fi
}

# Function to create a backup of an existing file or directory
create_backup() {
    local original="$1"
    local backup="${original}.backup.$(date +%Y%m%d%H%M%S)"

    if [[ -e "$original" ]]; then
        cp -r "$original" "$backup"
        log_message "Backup created: $original -> $backup"
    else
        log_message "Original file or directory does not exist: $original"
    fi
}

# Function to restore a backup
restore_backup() {
    local backup="$1"
    local original="${backup%.backup.*}"

    if [[ -e "$backup" ]]; then
        cp -r "$backup" "$original"
        log_message "Backup restored: $backup -> $original"
    else
        log_message "Backup file does not exist: $backup"
    fi
}

# Function to check the status of a service
check_service_status() {
    local service_name="$1"

    if systemctl is-active --quiet "$service_name"; then
        log_message "Service is running: $service_name"
    else
        log_message "Service is not running: $service_name"
    fi
}

# Main function to control the flow
main() {
    log_message "Starting tool1_installer.sh."

    # Check if user has root privileges
    check_root

    # Check for required dependencies
    check_dependencies wget tar unzip build-essential iptables

    # Create backup of existing configuration files (if any)
    create_backup "/etc/tool1.conf"

    # Install Tool 1 from source
    install_from_source "https://example.com/tool1-source.tar.gz" "/usr/local/src/tool1"

    # Create systemd service for Tool 1
    create_systemd_service "tool1"

    # Configure firewall to allow necessary ports
    configure_firewall "-p tcp --dport 8080 -j ACCEPT"

    # Restore backup if needed (e.g., in case of installation failure)
    restore_backup "/etc/tool1.conf.backup.20231005143200"

    # Check the status of Tool 1 service
    check_service_status "tool1"

    log_message "tool1_installer.sh execution completed."
}

# Run main function
main
