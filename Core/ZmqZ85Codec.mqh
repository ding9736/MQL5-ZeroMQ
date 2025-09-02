//+------------------------------------------------------------------+
//|   Core/ZmqZ85Codec.mqh                                           |
//+------------------------------------------------------------------+

#ifndef MQL_ZMQ_Z85_CODEC_MQH
#define MQL_ZMQ_Z85_CODEC_MQH
#property strict

#include "Native.mqh"
#import "libzmq.dll"

//
long zmq_z85_encode(uchar &dest[], const uchar &data[], ulong size);
long zmq_z85_decode(uchar &dest[], const uchar &str[]);
int zmq_curve_keypair(uchar &z85_public_key[], uchar &z85_secret_key[]);
int zmq_curve_public(uchar &z85_public_key[], const uchar &z85_secret_key[]);
#import

//
class ZmqZ85Codec
{
public:
   static bool   encode(string &z85_encoded_string, const uchar &binary_data[]);
   static string encode(const uchar &binary_data[]);
   static bool   decode(const string z85_encoded_string, uchar &binary_data[]);
   static bool   generateKeyPair(string &z85_public_key, string &z85_secret_key);
   static string derivePublicKey(const string z85_secret_key);
   static bool   generateKeyPairRaw(uchar &public_key[], uchar &secret_key[]);
   static bool   derivePublicKeyRaw(uchar &public_key[], const uchar &secret_key[]);
};

//
bool ZmqZ85Codec::encode(string &z85_encoded_string, const uchar &binary_data[])
{
   const int data_size = ArraySize(binary_data);
   if(data_size == 0)
   {
      z85_encoded_string = "";
      return false;
   }
   uchar encoded_buffer[];
   ArrayResize(encoded_buffer, (int)(data_size * 1.25) + 1);
   long encoded_len = zmq_z85_encode(encoded_buffer, binary_data, (ulong)data_size);
   if(encoded_len == 0)
   {
      z85_encoded_string = "";
      return false;
   }
   ArrayResize(encoded_buffer, (int)encoded_len + 1);
   z85_encoded_string = StringFromUtf8(encoded_buffer);
   return (StringLen(z85_encoded_string) > 0);
}

//
string ZmqZ85Codec::encode(const uchar &binary_data[])
{
   string result = "";
   encode(result, binary_data);
   return result;
}

//
bool ZmqZ85Codec::decode(const string z85_encoded_string, uchar &binary_data[])
{
   const int str_len = StringLen(z85_encoded_string);
   if(str_len == 0 || str_len % 5 != 0)
   {
      ArrayResize(binary_data, 0);
      return false;
   }
   uchar string_buffer[];
   StringToUtf8(z85_encoded_string, string_buffer, true);
   ArrayResize(binary_data, (int)(str_len * 0.8));
   long decoded_len = zmq_z85_decode(binary_data, string_buffer);
   if(decoded_len == 0)
   {
      ArrayResize(binary_data, 0);
      return false;
   }
   ArrayResize(binary_data, (int)decoded_len);
   return true;
}

//
bool ZmqZ85Codec::generateKeyPair(string &z85_public_key, string &z85_secret_key)
{
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

//
string ZmqZ85Codec::derivePublicKey(const string z85_secret_key)
{
   if(StringLen(z85_secret_key) != 40)
      return "";
   uchar sec_buf[];
   StringToUtf8(z85_secret_key, sec_buf, true);
   uchar pub_buf[41];
   if(zmq_curve_public(pub_buf, sec_buf) == 0)
   {
      return StringFromUtf8(pub_buf);
   }
   return "";
}

//
bool ZmqZ85Codec::generateKeyPairRaw(uchar &public_key[], uchar &secret_key[])
{
   string pub_z85, sec_z85;
   if(!generateKeyPair(pub_z85, sec_z85))
      return false;
// Decode Z85 string keys back to raw 32-byte binary keys
   if(!decode(pub_z85, public_key) || !decode(sec_z85, secret_key))
      return false;
   return (ArraySize(public_key) == 32 && ArraySize(secret_key) == 32);
}
//
bool ZmqZ85Codec::derivePublicKeyRaw(uchar &public_key[], const uchar &secret_key[])
{
   if(ArraySize(secret_key) != 32)
      return false;
   string sec_z85 = encode(secret_key);
   if(sec_z85 == "")
      return false;
   string pub_z85 = derivePublicKey(sec_z85);
   if(pub_z85 == "")
      return false;
   if(!decode(pub_z85, public_key))
      return false;
   return (ArraySize(public_key) == 32);
}

#endif // MQL_ZMQ_Z85_CODEC
//+------------------------------------------------------------------+
