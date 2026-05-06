import os
import sys
import socket
import subprocess
import psutil
import json
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(filename='logs/data_collector.log', level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class DataCollector:
    def __init__(self):
        self.data = {}
        self.hostname = socket.gethostname()
        self.ip_address = socket.gethostbyname(self.hostname)

    def collect_system_info(self):
        try:
            system_info = {
                'hostname': self.hostname,
                'ip_address': self.ip_address,
                'os': os.name,
                'platform': sys.platform,
                'architecture': platform.architecture(),
                'processor': platform.processor(),
                'python_version': sys.version
            }
            self.data['system_info'] = system_info
        except Exception as e:
            logging.error(f"Failed to collect system info: {e}")

    def collect_processes(self):
        try:
            processes = []
            for proc in psutil.process_iter(['pid', 'name', 'status']):
                processes.append({
                    'pid': proc.info['pid'],
                    'name': proc.info['name'],
                    'status': proc.info['status']
                })
            self.data['processes'] = processes
        except Exception as e:
            logging.error(f"Failed to collect process information: {e}")

    def collect_network_interfaces(self):
        try:
            interfaces = {}
            for interface, addrs in psutil.net_if_addrs().items():
                ifaddrs = []
                for addr in addrs:
                    ifaddr = {
                        'family': addr.family.name,
                        'address': addr.address
                    }
                    ifaddr.update(addr.__dict__)
                    ifaddrs.append(ifaddr)
                interfaces[interface] = ifaddrs
            self.data['network_interfaces'] = interfaces
        except Exception as e:
            logging.error(f"Failed to collect network interface information: {e}")

    def collect_disk_usage(self):
        try:
            disk_usage = {}
            for partition in psutil.disk_partitions():
                usage = psutil.disk_usage(partition.mountpoint)
                disk_info = {
                    'device': partition.device,
                    'mountpoint': partition.mountpoint,
                    'fstype': partition.fstype,
                    'opts': partition.opts,
                    'total': usage.total,
                    'used': usage.used,
                    'free': usage.free,
                    'percent': usage.percent
                }
                disk_usage[partition.device] = disk_info
            self.data['disk_usage'] = disk_usage
        except Exception as e:
            logging.error(f"Failed to collect disk usage information: {e}")

    def collect_open_connections(self):
        try:
            connections = []
            for conn in psutil.net_connections(kind='inet'):
                conn_info = {
                    'fd': conn.fd,
                    'family': socket.AF_INET if conn.family == socket.AF_INET else 'AF_INET6',
                    'type': conn.type.name,
                    'local_address': (conn.laddr.ip, conn.laddr.port),
                    'remote_address': (conn.raddr.ip, conn.raddr.port) if conn.raddr else None,
                    'status': conn.status
                }
                connections.append(conn_info)
            self.data['open_connections'] = connections
        except Exception as e:
            logging.error(f"Failed to collect open connection information: {e}")

    def collect_running_services(self):
        try:
            services = []
            for service in psutil.win_service_iter():
                service_info = {
                    'name': service.name(),
                    'display_name': service.display_name(),
                    'status': service.status()
                }
                services.append(service_info)
            self.data['running_services'] = services
        except Exception as e:
            logging.error(f"Failed to collect running services: {e}")

    def collect_user_accounts(self):
        try:
            users = []
            for user in psutil.users():
                user_info = {
                    'name': user.name,
                    'terminal': user.terminal or None,
                    'host': user.host or None,
                    'started': user.started
                }
                users.append(user_info)
            self.data['user_accounts'] = users
        except Exception as e:
            logging.error(f"Failed to collect user accounts: {e}")

    def collect_firewall_rules(self):
        try:
            firewall_rules = []
            output = subprocess.check_output(['iptables', '-L', '-v', '-n']).decode('utf-8')
            rules = [line.strip() for line in output.split('\n') if line]
            current_chain = None
            for rule in rules:
                if rule.startswith('Chain'):
                    current_chain = rule.split()[1]
                    firewall_rules.append({'chain': current_chain, 'rules': []})
                else:
                    firewall_rules[-1]['rules'].append(rule)
            self.data['firewall_rules'] = firewall_rules
        except Exception as e:
            logging.error(f"Failed to collect firewall rules: {e}")

    def collect_scheduled_tasks(self):
        try:
            tasks = []
            output = subprocess.check_output(['schtasks', '/query', '/fo', 'list']).decode('utf-8')
            task_data = [line.strip() for line in output.split('\n') if line]
            current_task = {}
            for line in task_data:
                if ':' in line:
                    key, value = line.split(':', 1)
                    current_task[key.strip()] = value.strip()
                else:
                    tasks.append(current_task)
                    current_task = {}
            self.data['scheduled_tasks'] = tasks
        except Exception as e:
            logging.error(f"Failed to collect scheduled tasks: {e}")

    def collect_installed_software(self):
        try:
            software = []
            output = subprocess.check_output(['wmic', 'product', 'get', 'name,version', '/format:value']).decode('utf-8')
            software_info = [line.strip() for line in output.split('\n') if line]
            current_item = {}
            for info in software_info:
                if '=' in info:
                    key, value = info.split('=', 1)
                    current_item[key] = value
                else:
                    software.append(current_item)
                    current_item = {}
            self.data['installed_software'] = software
        except Exception as e:
            logging.error(f"Failed to collect installed software: {e}")

    def collect_registry_keys(self):
        try:
            registry_keys = []
            output = subprocess.check_output(['reg', 'query', 'HKLM\\SOFTWARE']).decode('utf-8')
            keys = [line.strip() for line in output.split('\n') if line]
            current_key = {}
            for key in keys:
                if '\\' in key and not key.startswith('HKEY_'):
                    parts = key.split('\\')
                    current_key['path'] = '\\'.join(parts[:-1])
                    current_key['name'] = parts[-1]
                    registry_keys.append(current_key)
                    current_key = {}
            self.data['registry_keys'] = registry_keys
        except Exception as e:
            logging.error(f"Failed to collect registry keys: {e}")

    def save_data(self, filename):
        try:
            with open(filename, 'w') as file:
                json.dump(self.data, file, indent=4)
            logging.info(f"Data saved to {filename}")
        except Exception as e:
            logging.error(f"Failed to save data: {e}")

if __name__ == "__main__":
    collector = DataCollector()
    collector.collect_system_info()
    collector.collect_processes()
    collector.collect_network_interfaces()
    collector.collect_disk_usage()
    collector.collect_open_connections()
    collector.collect_running_services()
    collector.collect_user_accounts()
    collector.collect_firewall_rules()
    collector.collect_scheduled_tasks()
    collector.collect_installed_software()
    collector.collect_registry_keys()

    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    output_file = f'data/remote_data/{timestamp}_data_collector_output.json'
    collector.save_data(output_file)
