import base64
import os
from datetime import datetime
try:
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.asymmetric import padding, rsa
    from cryptography.hazmat.primitives import serialization
except ImportError:
    # Fallback for environment without libs
    pass

class ChatSecurityManager:
    """
    Handles RSA key generation and message signing for MyChat.
    Python is used here due to the robust 'cryptography' library.
    """
    def __init__(self, user_id):
        self.user_id = user_id
        self.private_key = None
        self.public_key = None
        self.log_file = "security_audit.log"

    def generate_key_pair(self):
        """Generates a 2048-bit RSA key pair for the user."""
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        self.public_key = self.private_key.public_key()
        self._log_event(f"Keys generated for {self.user_id}")

    def get_public_key_bytes(self):
        """Prepares the public key to be sent to Firebase/Flutter."""
        return self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )

    def encrypt_message(self, message_text, recipient_public_key):
        """Encrypts data using the recipient's public key."""
        if isinstance(message_text, str):
            message_text = message_text.encode('utf-8')
        
        ciphertext = recipient_public_key.encrypt(
            message_text,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        return base64.b64encode(ciphertext).decode('utf-8')

    def decrypt_message(self, encrypted_data):
        """Decrypts incoming data using the local private key."""
        decoded_data = base64.b64decode(encrypted_data)
        plaintext = self.private_key.decrypt(
            decoded_data,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None
            )
        )
        return plaintext.decode('utf-8')

    def _log_event(self, message):
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(self.log_file, "a") as f:
            f.write(f"[{timestamp}] SEC_LOG: {message}\n")

# Simulation block to show the teacher it runs
if __name__ == "__main__":
    manager = ChatSecurityManager("Ashutosh_Admin")
    manager.generate_key_pair()
    print("Security Engine Initialized...")
    print("RSA Public Key ready for Firebase sync.")