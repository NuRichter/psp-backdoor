import socket
import threading
import logging
from datetime import datetime
import json
import os

# Configure logging
logging.basicConfig(filename='data/logs/socket_logs.txt', level=logging.INFO, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

class SocketAnalyzer:
    def __init__(self, host='0.0.0.0', port=4455):
        self.host = host
        self.port = port
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.clients = []

    def start_server(self):
        try:
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(10)
            logging.info(f'Socket server started on {self.host}:{self.port}')
            while True:
                client_socket, addr = self.server_socket.accept()
                logging.info(f'New connection from {addr[0]}:{addr[1]}')
                self.clients.append(client_socket)
                threading.Thread(target=self.handle_client, args=(client_socket,)).start()
        except Exception as e:
            logging.error(f'Socket server error: {e}')

    def handle_client(self, client_socket):
        try:
            while True:
                data = client_socket.recv(1024).decode('utf-8')
                if not data:
                    break
                logging.info(f'Received data from {client_socket.getpeername()}: {data}')
                self.analyze_data(data)
        except Exception as e:
            logging.error(f'Error handling client: {e}')
        finally:
            client_socket.close()
            self.clients.remove(client_socket)

    def analyze_data(self, data):
        try:
            if not isinstance(data, dict):
                data = json.loads(data)
            
            if 'command' in data and data['command'] == 'connect':
                logging.info(f'Device connected: {data["device_id"]}')
            elif 'command' in data and data['command'] == 'disconnect':
                logging.info(f'Device disconnected: {data["device_id"]}')
            else:
                self.process_data(data)
        except json.JSONDecodeError as e:
            logging.error(f'JSON decoding error: {e}')

    def process_data(self, data):
        try:
            # Example processing
            if 'type' in data and data['type'] == 'sensor':
                sensor_data = data.get('data', {})
                logging.info(f'Sensor data received: {sensor_data}')
                self.save_to_csv(sensor_data)
            elif 'type' in data and data['type'] == 'event':
                event_data = data.get('data', {})
                logging.info(f'Event data received: {event_data}')
                self.log_event(event_data)
        except Exception as e:
            logging.error(f'Data processing error: {e}')

    def save_to_csv(self, sensor_data):
        try:
            with open('data/processed/analyzed_data.csv', 'a') as csvfile:
                for key, value in sensor_data.items():
                    csvfile.write(f'{datetime.now()},{key},{value}\n')
        except Exception as e:
            logging.error(f'Error saving to CSV: {e}')

    def log_event(self, event_data):
        try:
            with open('data/processed/cleaned_logs.log', 'a') as logfile:
                logfile.write(f'{datetime.now()} - Event - {event_data}\n')
        except Exception as e:
            logging.error(f'Error logging event: {e}')

    def stop_server(self):
        for client in self.clients:
            client.close()
        self.server_socket.close()
        logging.info('Socket server stopped')

if __name__ == '__main__':
    analyzer = SocketAnalyzer()
    try:
        analyzer.start_server()
    except KeyboardInterrupt:
        analyzer.stop_server()
