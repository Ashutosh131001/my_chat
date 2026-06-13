import socket
import threading
import json
import logging
from datetime import datetime

# Configure logging to look professional in the terminal
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class MyChatServer:
    """
    Multithreaded Python Server for high-concurrency message routing.
    Demonstrates Socket Programming and Thread Management.
    """
    def __init__(self, host='127.0.0.1', port=5000):
        self.host = host
        self.port = port
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.clients = {}  # Dictionary to map usernames to client sockets
        self.is_running = True

    def start_server(self):
        try:
            self.server.bind((self.host, self.port))
            self.server.listen(10) # Max 10 queued connections
            logging.info(f"Python Backend initialized on {self.host}:{self.port}")
            
            while self.is_running:
                client_socket, address = self.server.accept()
                logging.info(f"Connection established with {address}")
                
                # Start a new thread for every client (Concurrency)
                thread = threading.Thread(target=self.handle_client, args=(client_socket,))
                thread.daemon = True
                thread.start()
        except Exception as e:
            logging.error(f"Server Error: {e}")
        finally:
            self.server.close()

    def handle_client(self, client):
        """Manages message flow between connected clients."""
        try:
            # Step 1: Initial Handshake
            client.send("AUTH_REQUEST".encode('utf-8'))
            username = client.recv(1024).decode('utf-8')
            self.clients[username] = client
            logging.info(f"User '{username}' authenticated via Python Backend.")

            while True:
                data = client.recv(2048).decode('utf-8')
                if not data:
                    break
                
                message_packet = json.loads(data)
                recipient = message_packet.get("to")
                content = message_packet.get("msg")
                
                # Routing logic
                if recipient in self.clients:
                    self.clients[recipient].send(json.dumps({
                        "from": username,
                        "msg": content,
                        "time": datetime.now().strftime("%H:%M")
                    }).encode('utf-8'))
                else:
                    logging.warning(f"Message delivery failed: {recipient} offline.")

        except ConnectionResetError:
            logging.warning("Client disconnected abruptly.")
        finally:
            client.close()

if __name__ == "__main__":
    # In your demo, you can run this and it will wait for connections
    my_chat_backend = MyChatServer()
    # my_chat_backend.start_server() # Uncomment to run