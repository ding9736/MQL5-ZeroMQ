//+------------------------------------------------------------------+
//|   Core/ZmqMsg.mqh                                                |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_ZMQMSG_MQH
#define MQL_ZMQ_ZMQMSG_MQH

#include "../Lang/Native.mqh"

// The low-level C struct that the MQL5 wrapper will manage.
struct zmq_msg_t
{
   uchar _[64]; // Internal opaque buffer, must match libzmq's definition.
};

// --- DLL Imports for ZMQ Message Functions ---
#import "libzmq.dll"
int  zmq_msg_init(zmq_msg_t &msg);
int  zmq_msg_init_size(zmq_msg_t &msg, ulong size);
int  zmq_msg_close(zmq_msg_t &msg);
int  zmq_msg_move(zmq_msg_t &dest, zmq_msg_t &src);
int  zmq_msg_copy(zmq_msg_t &dest, zmq_msg_t &src);
long zmq_msg_data(zmq_msg_t &msg);
int  zmq_msg_size(zmq_msg_t &msg);
int  zmq_msg_more(zmq_msg_t &msg);
int  zmq_msg_get(zmq_msg_t &msg, int property);
int  zmq_msg_set(zmq_msg_t &msg, int property, int optval);
long zmq_msg_gets(zmq_msg_t &msg, const uchar &property[]);
#import

//+------------------------------------------------------------------+
//| A RAII-style wrapper for a ZMQ message (zmq_msg_t).              |
//| It ensures resources are always properly initialized and released.|
//+------------------------------------------------------------------+
struct ZmqMsg : zmq_msg_t
{
private:
   // [NEW] Tracks if the message was initialized successfully.
   bool m_is_valid;

   // Private helper to get the data pointer.
   long internal_data_ptr()
   {
      if(!m_is_valid) return 0;
      return zmq_msg_data(this);
   }

public:
   // --- Constructors ---

   // Default constructor for an empty message.
   ZmqMsg()
   {
      // [OPTIMIZED] Set validity based on init result, remove logging.
      m_is_valid = (zmq_msg_init(this) == 0);
   }

   // Creates a message with a pre-allocated buffer of 'size' bytes.
   ZmqMsg(const ulong size)
   {
      m_is_valid = (zmq_msg_init_size(this, size) == 0);
   }

   // Creates a message from an MQL string (converted to UTF-8).
   ZmqMsg(const string data, const bool null_terminated = false)
   {
      m_is_valid = false; // Assume failure until success
      uchar buf[];
      StringToUtf8(data, buf, null_terminated);
      const ulong len = (ulong)ArraySize(buf);
      if(zmq_msg_init_size(this, len) == 0)
      {
         // Only if init succeeds, set valid and copy data
         m_is_valid = true;
         setData(buf);
      }
   }

   // Destructor: ensures resources are released.
   ~ZmqMsg()
   {
      if(m_is_valid)
      {
         zmq_msg_close(this);
      }
   }

   // --- State Validation ---

   // @brief  Checks if the message object was initialized correctly.
   // @return true if the message is valid and safe to use.
   bool isValid() const
   {
      return m_is_valid;
   }

   // --- Rebuild Methods (for reusing an existing ZmqMsg object) ---

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

   // --- Data Access & Properties ---

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

   // --- Data Manipulation ---

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
         // Truncate data if it doesn't fit, this is expected behavior.
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
