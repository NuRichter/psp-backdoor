import os
import json
import subprocess
from datetime import datetime
import hashlib
import base64
import socket
import struct
import time
import psutil

# Define constants
REPORT_DIR = "remote_data"
LOG_FILE = "data/logs/my_custom_tool.log"
CONFIG_FILE = "environment/setup_environment.sh"

# Function to log messages with timestamps
def log_message(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as log:
        log.write(f"{timestamp} - {message}\n")

# Function to read configuration from a file
def read_config(file_path):
    if not os.path.exists(file_path):
        log_message("Configuration file does not exist.")
        return {}
    
    try:
        with open(file_path, 'r') as config_file:
            config = json.load(config_file)
            log_message(f"Configuration loaded successfully from {file_path}.")
            return config
    except Exception as e:
        log_message(f"Error reading configuration file: {e}")
        return {}

# Function to execute a shell command and capture its output
def run_command(command):
    try:
        result = subprocess.run(command, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        log_message(f"Command executed successfully: {command}")
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        log_message(f"Command failed: {command}. Error: {e.stderr.strip()}")
        return None

# Function to calculate MD5 hash of a file
def calculate_md5(file_path):
    if not os.path.isfile(file_path):
        log_message("File does not exist.")
        return None
    
    md5_hash = hashlib.md5()
    with open(file_path, 'rb') as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            md5_hash.update(byte_block)
    
    log_message(f"MD5 hash calculated for {file_path}.")
    return md5_hash.hexdigest()

# Function to encode data in base64
def encode_base64(data):
    log_message("Data encoded in base64.")
    return base64.b64encode(data).decode('utf-8')

# Function to decode base64 encoded data
def decode_base64(encoded_data):
    try:
        decoded_data = base64.b64decode(encoded_data)
        log_message("Base64 data decoded successfully.")
        return decoded_data
    except Exception as e:
        log_message(f"Error decoding base64: {e}")
        return None

# Function to check if a port is open on a given IP address
def is_port_open(ip_address, port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(1)
            result = s.connect_ex((ip_address, port))
            if result == 0:
                log_message(f"Port {port} on {ip_address} is open.")
                return True
            else:
                log_message(f"Port {port} on {ip_address} is closed.")
                return False
    except socket.error as e:
        log_message(f"Socket error: {e}")
        return False

# Function to send data over a TCP socket
def send_data(ip_address, port, data):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.connect((ip_address, port))
            s.sendall(data)
            log_message(f"Data sent successfully to {ip_address}:{port}.")
    except Exception as e:
        log_message(f"Error sending data: {e}")

# Function to receive data over a TCP socket
def receive_data(ip_address, port):
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind((ip_address, port))
            s.listen(1)
            conn, addr = s.accept()
            with conn:
                log_message(f"Connected by {addr}")
                data = conn.recv(4096)
                log_message("Data received successfully.")
                return data
    except Exception as e:
        log_message(f"Error receiving data: {e}")
        return None

# Function to calculate the current system uptime
def get_system_uptime():
    try:
        uptime_seconds = psutil.boot_time()
        now = time.time()
        uptime = now - uptime_seconds
        log_message("System uptime calculated.")
        return uptime
    except Exception as e:
        log_message(f"Error getting system uptime: {e}")
        return None

# Function to get the current network interfaces and their status
def get_network_interfaces():
    try:
        interfaces = psutil.net_if_addrs()
        log_message("Network interfaces retrieved.")
        return json.dumps(interfaces, indent=4)
    except Exception as e:
        log_message(f"Error getting network interfaces: {e}")
        return None

# Function to create a report file with system information
def generate_report():
    try:
        report_data = {
            "system_uptime": get_system_uptime(),
            "network_interfaces": json.loads(get_network_interfaces()),
            "current_time": datetime.now().isoformat()
        }
        report_file_path = os.path.join(REPORT_DIR, f"report_{datetime.now().strftime('%Y%m%d%H%M%S')}.json")
        
        with open(report_file_path, 'w') as report_file:
            json.dump(report_data, report_file, indent=4)
        
        log_message(f"Report generated and saved to {report_file_path}.")
    except Exception as e:
        log_message(f"Error generating report: {e}")

# Function to monitor system processes and log any suspicious activity
def monitor_processes():
    try:
        for proc in psutil.process_iter(['pid', 'name', 'username']):
            if "malware" in proc.info['name'].lower() or "backdoor" in proc.info['name'].lower():
                log_message(f"Suspicious process detected: {proc.info}")
    except Exception as e:
        log_message(f"Error monitoring processes: {e}")

# Main function to control the flow
def main():
    log_message("Starting my_custom_tool.py.")
    
    # Read configuration
    config = read_config(CONFIG_FILE)
    
    # Generate report
    generate_report()
    
    # Monitor system processes
    monitor_processes()
    
    # Example of sending data over a socket
    ip_address = "127.0.0.1"
    port = 8080
    data_to_send = b"Hello, this is a test message."
    send_data(ip_address, port, data_to_send)
    
    # Example of receiving data over a socket
    received_data = receive_data(ip_address, port)
    if received_data:
        log_message(f"Received data: {received_data}")
    
    # Check if a specific port is open
    if is_port_open(ip_address, port):
        log_message("Port is open.")
    else:
        log_message("Port is closed.")
    
    # Calculate MD5 hash of a file
    file_path = "sample_data.bin"
    md5_hash = calculate_md5(file_path)
    if md5_hash:
        log_message(f"MD5 hash of {file_path}: {md5_hash}")
    
    # Encode and decode data in base64
    original_data = b"This is some test data."
    encoded_data = encode_base64(original_data)
    decoded_data = decode_base64(encoded_data)
    if decoded_data:
        log_message(f"Decoded data: {decoded_data}")
    
    # Run a shell command
    command_output = run_command(["ls", "-l"])
    if command_output:
        log_message(f"Command output: {command_output}")
    
    log_message("my_custom_tool.py execution completed.")

# Run main function
if __name__ == "__main__":
    main()
