//+------------------------------------------------------------------+
//| Module:      Security/ZmqZ85Codec.mqh                            |
//+------------------------------------------------------------------+

#ifndef MQL_ZMQ_Z85_CODEC_MQH
#define MQL_ZMQ_Z85_CODEC_MQH

#include "../Lang/Native.mqh"

#import "libzmq.dll"
// Encodes binary data into a Z85 string.
long zmq_z85_encode(uchar &dest[], const uchar &data[], ulong size);
// Decodes a Z85 string back into binary data.
long zmq_z85_decode(uchar &dest[], const uchar &str[]);
// Generates a new CURVE key pair (public and secret keys).
int zmq_curve_keypair(uchar &z85_public_key[], uchar &z85_secret_key[]);
// Derives the public key from a given secret key.
int zmq_curve_public(uchar &z85_public_key[], const uchar &z85_secret_key[]);
#import


//+------------------------------------------------------------------+
class ZmqZ85Codec
{
public:
   // --- Z85 Encoding/Decoding ---
   static bool   encode(string &z85_encoded_string, const uchar &binary_data[]);
   static string encode(const uchar &binary_data[]);
   static bool   decode(const string z85_encoded_string, uchar &binary_data[]);

   // --- CURVE Key Management (Z85 encoded strings) ---
   static bool   generateKeyPair(string &z85_public_key, string &z85_secret_key);
   static string derivePublicKey(const string z85_secret_key);

   // --- CURVE Key Management (raw binary) ---
   // Corrected Syntax: Parameters passed by reference must be dynamic arrays `[]`.
   static bool   generateKeyPairRaw(uchar &public_key[], uchar &secret_key[]);
   static bool   derivePublicKeyRaw(uchar &public_key[], const uchar &secret_key[]);
};


//+------------------------------------------------------------------+
bool ZmqZ85Codec::encode(string &z85_encoded_string, const uchar &binary_data[])
{
   const int data_size = ArraySize(binary_data);
   if(data_size == 0 || data_size % 4 != 0)
   {
      // Z85 requires input length to be a multiple of 4
      z85_encoded_string = "";
      return false;
   }
   uchar encoded_buffer[];
   ArrayResize(encoded_buffer, (int)(data_size * 1.25) + 1);
   if(zmq_z85_encode(encoded_buffer, binary_data, (ulong)data_size) == 0)
   {
      z85_encoded_string = "";
      return false;
   }
   z85_encoded_string = StringFromUtf8(encoded_buffer);
   return (StringLen(z85_encoded_string) > 0);
}

//+------------------------------------------------------------------+
//| Overload that returns the encoded string directly for convenience|
//+------------------------------------------------------------------+
string ZmqZ85Codec::encode(const uchar &binary_data[])
{
   string result = "";
   encode(result, binary_data);
   return result;
}

//+------------------------------------------------------------------+
//| Decodes a Z85 encoded string back to a binary byte array.        |
//| Note: Input string length must be a multiple of 5.               |
//+------------------------------------------------------------------+
bool ZmqZ85Codec::decode(const string z85_encoded_string, uchar &binary_data[])
{
   const int str_len = StringLen(z85_encoded_string);
   if(str_len == 0 || str_len % 5 != 0)
   {
      // Z85 requires input length to be a multiple of 5
      ArrayResize(binary_data, 0);
      return false;
   }
   uchar string_buffer[];
// Convert string to a null-terminated char array for the DLL function.
   StringToUtf8(z85_encoded_string, string_buffer, true);
// Z85 decoding shrinks data size by 4/5.
   ArrayResize(binary_data, (int)(str_len * 0.8));
   if(zmq_z85_decode(binary_data, string_buffer) == 0)
   {
      ArrayResize(binary_data, 0); // Clear array on failure
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Generates a new Curve25519 key pair, returned as Z85 strings.    |
//+------------------------------------------------------------------+
bool ZmqZ85Codec::generateKeyPair(string &z85_public_key, string &z85_secret_key)
{
// Buffers are 41 bytes to accommodate the 40-char Z85 string + null terminator.
   uchar pub_buf[41], sec_buf[41];
   if(zmq_curve_keypair(pub_buf, sec_buf) == 0)
   {
      z85_public_key = StringFromUtf8(pub_buf);
      z85_secret_key = StringFromUtf8(sec_buf);
      return true;
   }
   z85_public_key = "";
   z85_secret_key = "";
   return false;
}

//+------------------------------------------------------------------+
//| Derives a public key from a secret key (both Z85 strings).       |
//+------------------------------------------------------------------+
string ZmqZ85Codec::derivePublicKey(const string z85_secret_key)
{
   if(StringLen(z85_secret_key) != 40)
      return ""; // Invalid Z85 secret key length
   uchar sec_buf[];
// Pass true to ensure null terminator for the C function
   StringToUtf8(z85_secret_key, sec_buf, true);
   uchar pub_buf[41]; // Buffer for the output key
   if(zmq_curve_public(pub_buf, sec_buf) == 0)
   {
      return StringFromUtf8(pub_buf);
   }
   return "";
}

//+------------------------------------------------------------------+
//| Generates a new Curve25519 key pair as raw 32-byte arrays.       |
//+------------------------------------------------------------------+
bool ZmqZ85Codec::generateKeyPairRaw(uchar &public_key[], uchar &secret_key[])
{
   string pub_z85, sec_z85;
   if(!generateKeyPair(pub_z85, sec_z85))
      return false;
// Decode the Z85 strings back to binary
   if(!decode(pub_z85, public_key) || !decode(sec_z85, secret_key))
      return false;
   return (ArraySize(public_key) == 32 && ArraySize(secret_key) == 32);
}

//+------------------------------------------------------------------+
//| Derives a raw 32-byte public key from a raw 32-byte secret key.  |
//+------------------------------------------------------------------+
bool ZmqZ85Codec::derivePublicKeyRaw(uchar &public_key[], const uchar &secret_key[])
{
   if(ArraySize(secret_key) != 32)
      return false;
// We must encode the secret key to Z85 to use the zmq_curve_public function,
// as it expects a Z85-encoded secret key string.
   string sec_z85 = encode(secret_key);
   if(sec_z85 == "")
      return false;
   string pub_z85 = derivePublicKey(sec_z85);
   if(pub_z85 == "")
      return false;
// Decode the resulting Z85 public key back to binary.
   if(!decode(pub_z85, public_key))
      return false;
   return (ArraySize(public_key) == 32);
}

#endif // MQL_ZMQ_Z85_CODEC_MQH
//+------------------------------------------------------------------+
