//+------------------------------------------------------------------+
//|   Core/ZmqMsg.mqh                                                |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_ZMQMSG_MQH
#define MQL_ZMQ_ZMQMSG_MQH

#include "../Lang/Native.mqh"


struct zmq_msg_t
{
   uchar _[64];
};

#import "libzmq.dll"
int  zmq_msg_init(zmq_msg_t &msg);                           // Initializes an empty message.
int  zmq_msg_init_size(zmq_msg_t &msg, ulong size);          // Initializes a message with a specific size.
int  zmq_msg_close(zmq_msg_t &msg);                          // Closes and frees a message.
int  zmq_msg_move(zmq_msg_t &dest, zmq_msg_t &src);          // Moves message content (destroys src).
int  zmq_msg_copy(zmq_msg_t &dest, zmq_msg_t &src);          // Copies message content.
long zmq_msg_data(zmq_msg_t &msg);                           // Returns pointer to message data.
int  zmq_msg_size(zmq_msg_t &msg);                           // Returns size of message data.
int  zmq_msg_more(zmq_msg_t &msg);                           // Checks if more parts are expected (multi-part message).
int  zmq_msg_get(zmq_msg_t &msg, int property);              // Gets a message property (e.g., identity).
int  zmq_msg_set(zmq_msg_t &msg, int property, int optval);  // Sets a message property.
long zmq_msg_gets(zmq_msg_t &msg, const uchar &property[]);  // Gets a message string property (e.g., User-Id for ZAP).
#import


struct ZmqMsg : zmq_msg_t 
{
private:
   bool m_is_valid; 

   long internal_data_ptr()
   {
      if(!m_is_valid) return 0;
      return zmq_msg_data(this); 
   }

public:

   ZmqMsg()
   {
      m_is_valid = (zmq_msg_init(this) == 0);
   }
   ZmqMsg(const ulong size)
   {
      m_is_valid = (zmq_msg_init_size(this, size) == 0);
   }

   ZmqMsg(const string data, const bool null_terminated = false)
   {
      m_is_valid = false;
      uchar buf[];
      StringToUtf8(data, buf, null_terminated); 
      const ulong len = (ulong)ArraySize(buf);
      if(zmq_msg_init_size(this, len) == 0)
      {
         m_is_valid = true;
         setData(buf); 
      }
   }

   ~ZmqMsg()
   {
      if(m_is_valid)
      {
         zmq_msg_close(this);
         m_is_valid = false; 
      }
   }

   bool isValid() const
   {
      return m_is_valid;
   }

   bool rebuild()
   {
      if(m_is_valid) zmq_msg_close(this); 
      m_is_valid = (zmq_msg_init(this) == 0); 
      return m_is_valid;
   }

   bool rebuild(const ulong size)
   {
      if(m_is_valid) zmq_msg_close(this); 
      m_is_valid = (zmq_msg_init_size(this, size) == 0); 
      return m_is_valid;
   }

   bool rebuild(const string data, const bool null_terminated = false)
   {
      if(!rebuild()) return false; 
      return setData(data, null_terminated); 
   }

   ulong size()
   {
      if(!m_is_valid) return 0;
      return (ulong)zmq_msg_size(this);
   }

   bool more()
   {
      if(!m_is_valid) return false;
      return zmq_msg_more(this) == 1;
   }

   void   getData(uchar &bytes[])
   {
      if(!m_is_valid)
      {
         ArrayResize(bytes, 0); 
         return;
      }
      const ulong msg_size = size();
      if(msg_size == 0)
      {
         ArrayResize(bytes, 0); 
         return;
      }
      const long src_ptr = internal_data_ptr();
      if(src_ptr == 0) 
      {
         ArrayResize(bytes, 0);
         return;
      }
      ArrayResize(bytes, (int)msg_size); 
      RtlMoveMemory(bytes, src_ptr, msg_size); 
   }


   string getData()
   {
      if(!m_is_valid) return "";
      const ulong msg_size = size();
      if(msg_size == 0) return "";
      const long src_ptr = internal_data_ptr();
      if(src_ptr == 0) return "";
      return StringFromUtf8Pointer(src_ptr, (int)msg_size); 
   }

   bool   setData(const uchar &bytes[])
   {
      if(!m_is_valid) return false;
      const long dest_ptr = internal_data_ptr();
      if(dest_ptr == 0) return false;
      const ulong msg_capacity = size(); 
      ulong bytes_to_copy = (ulong)ArraySize(bytes);
      if(bytes_to_copy > msg_capacity)
      {
         bytes_to_copy = msg_capacity;
      }
      if(bytes_to_copy > 0)
         RtlMoveMemory(dest_ptr, bytes, bytes_to_copy);
      return true;
   }

   bool   setData(const string data, const bool null_terminated = false)
   {
      if(!m_is_valid) return false;
      uchar buf[];
      StringToUtf8(data, buf, null_terminated); 
      return setData(buf); 
   }
   
   string getMeta(const string property_name)
   {
      if(!m_is_valid) return "";
      uchar prop_buf[];
      StringToUtf8(property_name, prop_buf, true); 
      const long ref = zmq_msg_gets(this, prop_buf); 
      if(ref == 0) return ""; 
      return StringFromUtf8Pointer(ref); 
   }
};

#endif // MQL_ZMQ_ZMQMSG_MQH
//+------------------------------------------------------------------+
