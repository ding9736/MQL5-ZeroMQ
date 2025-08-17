//+------------------------------------------------------------------+
//|   Core/ZeroMQ/ZmqSocket.mqh                                      |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_SOCKET_MQH
#define MQL_ZMQ_SOCKET_MQH

// --- Core Dependencies ---
#include "ZmqContext.mqh"
#include "ZmqMsg.mqh"
#include "ZmqSocketOptions.mqh"
#include "../Common/Constants.mqh"


//+------------------------------------------------------------------+
//| PollItem: The structure used by zmq_poll to monitor multiple     |
//| sockets for I/O readiness. This is the cornerstone of async I/O. |
//+------------------------------------------------------------------+
struct PollItem
{
   long  socket_handle;  // Raw ZMQ socket handle to monitor.
   long  fd;             // File descriptor (not used by MQL5, must be 0).
   short events;         // A bitmask specifying events to monitor (e.g., ZMQ_POLLIN).
   short revents;        // A bitmask filled by zmq_poll with the events that actually occurred.


   bool hasInput()  const
   {
      return (revents & ZMQ_POLLIN) != 0;
   }

   bool hasOutput() const
   {
      return (revents & ZMQ_POLLOUT) != 0;
   }

   bool hasError()  const
   {
      return (revents & ZMQ_POLLERR) != 0;
   }
};

// --- Required DLL Imports for Socket Operations ---
#import "libzmq.dll"
long zmq_socket(long context, int type);
int  zmq_close(long s);
int  zmq_bind(long s, const uchar &addr[]);
int  zmq_connect(long s, const uchar &addr[]);
int  zmq_disconnect(long s, const uchar &addr[]);
int  zmq_unbind(long s, const uchar &addr[]);
int  zmq_send(long s, const uchar &buf[], ulong len, int flags);
int  zmq_msg_send(long s, ZmqMsg &msg, int flags);
int  zmq_msg_recv(long s, ZmqMsg &msg, int flags);
int  zmq_poll(PollItem &items[], int nitems, long timeout);
#import

//+------------------------------------------------------------------+
class ZmqSocket : public ZmqSocketOptions
{
public:

   ZmqSocket(ZmqContext &context, ENUM_ZMQ_SOCKET_TYPE type)

      : ZmqSocketOptions(zmq_socket(context.ref(), (int)type))
   {
   }

   ~ZmqSocket()
   {
      if(m_ref != 0)
      {
         zmq_close(m_ref);
         m_ref = 0; // Prevent dangling handle issues.
      }
   }


   bool isValid() const
   {
      return m_ref != 0;
   }


   long ref() const
   {
      return m_ref;
   }

   bool bind(const string endpoint);
   bool unbind(const string endpoint);
   bool connect(const string endpoint);
   bool disconnect(const string endpoint);
   bool send(const uchar &data[], ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);
   bool send(const string data, ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);
   bool send(ZmqMsg &msg, ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);
   bool recv(uchar &data[], ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);
   bool recv(string &data, ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);
   bool recv(ZmqMsg &msg, ENUM_ZMQ_SEND_RECV_FLAG flags=ZMQ_FLAG_NONE);

   void fillPollItem(PollItem &item, short events) const
   {
      item.socket_handle = m_ref;
      item.fd = 0;
      item.events = events;
      item.revents = 0;
   }

   static int poll(PollItem &items[], long timeout_ms)
   {
      if(ArraySize(items) == 0) return 0;
      return zmq_poll(items, ArraySize(items), timeout_ms);
   }
};

//+------------------------------------------------------------------+
bool ZmqSocket::bind(const string endpoint)
{
   if(!isValid()) return false;
   uchar buf[];
   StringToUtf8(endpoint, buf, true);
   return zmq_bind(m_ref, buf) == 0;
}
//+------------------------------------------------------------------+
bool ZmqSocket::unbind(const string endpoint)
{
   if(!isValid()) return false;
   uchar buf[];
   StringToUtf8(endpoint, buf, true);
   return zmq_unbind(m_ref, buf) == 0;
}
//+------------------------------------------------------------------+
bool ZmqSocket::connect(const string endpoint)
{
   if(!isValid()) return false;
   uchar buf[];
   StringToUtf8(endpoint, buf, true);
   return zmq_connect(m_ref, buf) == 0;
}
//+------------------------------------------------------------------+
bool ZmqSocket::disconnect(const string endpoint)
{
   if(!isValid()) return false;
   uchar buf[];
   StringToUtf8(endpoint, buf, true);
   return zmq_disconnect(m_ref, buf) == 0;
}
//+------------------------------------------------------------------+
bool ZmqSocket::send(const uchar &data[], ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   if(!isValid()) return false;
   return zmq_send(m_ref, data, ArraySize(data), (int)flags) != -1;
}
//+------------------------------------------------------------------+
bool ZmqSocket::send(const string data, ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   uchar buf[];
   StringToUtf8(data, buf, false);
   return send(buf, flags);
}
//+------------------------------------------------------------------+
bool ZmqSocket::send(ZmqMsg &msg, ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   if(!isValid() || !msg.isValid()) return false;
   return zmq_msg_send(m_ref, msg, (int)flags) != -1;
}
//+------------------------------------------------------------------+
bool ZmqSocket::recv(ZmqMsg &msg, ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   if(!isValid()) return false;
   if(!msg.rebuild()) return false;
   return zmq_msg_recv(m_ref, msg, (int)flags) != -1;
}
//+------------------------------------------------------------------+
bool ZmqSocket::recv(uchar &data[], ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   ZmqMsg msg;
   if(recv(msg, flags))
   {
      msg.getData(data);
      return true;
   }
   ArrayResize(data, 0);
   return false;
}
//+------------------------------------------------------------------+
bool ZmqSocket::recv(string &data, ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   ZmqMsg msg;
   if(recv(msg, flags))
   {
      data = msg.getData();
      return true;
   }
   data = "";
   return false;
}
//+------------------------------------------------------------------+
#endif // MQL_ZMQ_SOCKET_MQH
