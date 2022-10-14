
# Define functions to retrieve and parse a private authentication key

'''
These functions have all been written with Snowflake in mind,
so assumptions have been made that the key is in pkcs8 PEM format
'''

## Import packages with which to parse the private key
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

## Define function to encode the passphrase for a private key
def encode_private_key_passphrase(
    private_key_passphrase: str = None
  ):

  ### Ingest private key passphrase if provided
  private_key_passphrase_encoded = None
  if private_key_passphrase is not None :
    if len(private_key_passphrase) > 0 and private_key_passphrase != "None" :
      private_key_passphrase_encoded = private_key_passphrase.encode()

  return private_key_passphrase_encoded

## Define function to load a private key
def load_private_key_from_bytes(
      private_key_encoded: bytes
    , private_key_passphrase_encoded: bytes = None
  ):
  
  ### Load private key, leveraging passphrase if needed
  private_key_loaded = serialization.load_pem_private_key(
      private_key_encoded
    , password = private_key_passphrase_encoded
    , backend = default_backend()
  )

  return private_key_loaded

## Define function to serialize an loaded private key
def serialize_loaded_private_key(
    private_key_loaded: bytes
  ):

  ### Serialize loaded private key
  private_key_serialized = private_key_loaded.private_bytes(
      encoding = serialization.Encoding.DER
    , format = serialization.PrivateFormat.PKCS8
    , encryption_algorithm = serialization.NoEncryption()
  )

  return private_key_serialized

## Define function to decode a loaded private key
def decode_loaded_private_key(
    private_key_loaded: bytes
  ):

  ### Decode loaded private key
  private_key_decoded = private_key_loaded.private_bytes(
      encoding = serialization.Encoding.PEM
    , format = serialization.PrivateFormat.PKCS8
    , encryption_algorithm = serialization.NoEncryption()
  ).decode('utf-8')

  return private_key_decoded

def serialize_encoded_private_key(
      private_key_encoded: bytes
    , private_key_passphrase: str = None
    , private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''

  ### Encode private key passphrase if provided
  private_key_passphrase_encoded = encode_private_key_passphrase(private_key_passphrase)
  
  ### Retrieve private key from path, leveraging passphrase if needed
  private_key_loaded = load_private_key_from_bytes(private_key_encoded, private_key_passphrase_encoded)

  ### Encrypt private key
  if private_key_output_format == 'snowpipe' :
    private_key_decoded = decode_loaded_private_key(private_key_loaded)
    return private_key_decoded
  else :
    private_key_serialized = serialize_loaded_private_key(private_key_loaded)
    return private_key_serialized
  
def serialize_private_key_from_path(
      private_key_path: str = None
    , private_key_passphrase: str = None
    , private_key_output_format: str = 'snowpark'
  ):

  '''
  private_key_output_format options are:
  - Snowpark : Intended for creating Snowpark sessions
  - Snowpipe : Intended for creating Snowpipe SimpleIngestManager objects
  '''
  
  ### Retrieve private key from path, leveraging passphrase if needed
  with open(private_key_path, "rb") as private_key_encoded_io:
    private_key_encoded = private_key_encoded_io.read()
  
  private_key_serialized = serialize_encoded_private_key(private_key_encoded, private_key_passphrase, private_key_output_format)

  return private_key_serialized