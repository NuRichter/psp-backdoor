#!/bin/bash

# Function to log messages with timestamps
log_message() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $1" >> /var/log/tool2_installer.log
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
Description=Tool 2 Service

[Service]
ExecStart=/usr/local/bin/tool2_start.sh
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
        iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
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

# Function to install additional tools and libraries
install_additional_tools() {
    local tool_list="$1"

    for tool in $tool_list; do
        if ! dpkg -l | grep -q "^ii  $tool "; then
            apt-get update && apt-get install -y "$tool"
            log_message "Additional tool installed: $tool"
        else
            log_message "Tool already installed: $tool"
        fi
    done
}

# Function to configure environment variables
configure_environment() {
    local env_file="/etc/environment"

    if [[ ! -f "$env_file" ]]; then
        touch "$env_file"
    fi

    echo "TOOL2_HOME=/usr/local/tool2" >> "$env_file"
    source "$env_file"

    log_message "Environment variables configured."
}

# Function to create a user for Tool 2
create_tool_user() {
    local username="tool2user"
    local home_dir="/home/$username"

    if ! id "$username" >/dev/null 2>&1; then
        useradd -m -d "$home_dir" "$username"
        log_message "User created: $username"
    else
        log_message "User already exists: $username"
    fi

    # Set password for the user (you may want to use a more secure method)
    echo "$username:password123" | chpasswd
}

# Main function to control the flow
main() {
    log_message "Starting tool2_installer.bash."

    # Check if user has root privileges
    check_root

    # Check for required dependencies
    check_dependencies wget tar unzip build-essential iptables curl

    # Create backup of existing configuration files (if any)
    create_backup "/etc/tool2.conf"

    # Install Tool 2 from source
    install_from_source "https://example.com/tool2-source.tar.gz" "/usr/local/src/tool2"

    # Create systemd service for Tool 2
    create_systemd_service "tool2"

    # Configure firewall to allow necessary ports
    configure_firewall "-p tcp --dport 8081 -j ACCEPT"

    # Install additional tools and libraries required by Tool 2
    install_additional_tools "libssl-dev libcurl4-openssl-dev"

    # Configure environment variables for Tool 2
    configure_environment

    # Create a dedicated user for Tool 2
    create_tool_user

    # Restore backup if needed (e.g., in case of installation failure)
    restore_backup "/etc/tool2.conf.backup.20231005143200"

    # Check the status of Tool 2 service
    check_service_status "tool2"

    log_message "tool2_installer.bash execution completed."
}

# Run main function
main
