import socket
import threading
import logging
from datetime import datetime

logging.basicConfig(filename='data/logs/socket_logs.txt', level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

class BackdoorScanner:
    def __init__(self, target_ip, start_port=1024, end_port=65535):
        self.target_ip = target_ip
        self.start_port = start_port
        self.end_port = end_port
        self.open_ports = []

    def scan_port(self, port):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((self.target_ip, port))
            if result == 0:
                logging.info(f'Port {port} is open')
                self.open_ports.append(port)
            else:
                logging.debug(f'Port {port} is closed')
            sock.close()
        except Exception as e:
            logging.error(f'Scan error on port {port}: {e}')

    def scan_range(self):
        try:
            for port in range(self.start_port, self.end_port + 1):
                threading.Thread(target=self.scan_port, args=(port,)).start()
            while threading.active_count() > 1:
                pass
        except Exception as e:
            logging.error(f'Scan range error: {e}')

    def save_results(self):
        try:
            with open('data/raw/initial_scan_results.json', 'w') as f:
                json.dump({'target_ip': self.target_ip, 'open_ports': self.open_ports}, f)
        except Exception as e:
            logging.error(f'Error saving results: {e}')

if __name__ == '__main__':
    scanner = BackdoorScanner('192.168.1.1')
    try:
        scanner.scan_range()
        scanner.save_results()
    except KeyboardInterrupt:
        logging.info('Scan interrupted by user')
