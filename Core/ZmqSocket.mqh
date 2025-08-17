//+------------------------------------------------------------------+
//|   Core/ZmqSocket.mqh                                             |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_SOCKET_MQH
#define MQL_ZMQ_SOCKET_MQH

#include "ZmqContext.mqh"
#include "ZmqMsg.mqh"
#include "ZmqSocketOptions.mqh"
#include "../Common/Constants.mqh"

//+------------------------------------------------------------------+
struct PollItem
{
   long  socket_handle; // Native ZeroMQ socket handle
   long  fd;            // File descriptor (not directly used by MQL5 ZeroMQ, but part of struct)
   short events;        // Events to monitor (ZMQ_POLLIN, ZMQ_POLLOUT, ZMQ_POLLERR)
   short revents;       // Returned events (actual events that occurred)

   // Helper methods to check for specific returned events
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

#import "libzmq.dll"
long zmq_socket(long context, int type);                           // Creates a ZeroMQ socket.
int  zmq_close(long s);                                            // Closes a ZeroMQ socket.
int  zmq_bind(long s, const uchar &addr[]);                        // Binds a socket to an endpoint.
int  zmq_connect(long s, const uchar &addr[]);                     // Connects a socket to an endpoint.
int  zmq_disconnect(long s, const uchar &addr[]);                  // Disconnects a socket from an endpoint.
int  zmq_unbind(long s, const uchar &addr[]);                      // Unbinds a socket from an endpoint.
int  zmq_send(long s, const uchar &buf[], ulong len, int flags);   // Sends raw data.
int  zmq_msg_send(long s, ZmqMsg &msg, int flags);                 // Sends a ZmqMsg.
int  zmq_msg_recv(long s, ZmqMsg &msg, int flags);                 // Receives into a ZmqMsg.
int  zmq_poll(PollItem &items[], int nitems, long timeout);        // Polls multiple sockets.
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
         m_ref = 0; // Prevent dangling handle issues after closing.
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

   // --- Endpoint Management ---
   // Binds the socket to a given endpoint string (e.g., "tcp://*:5555").
   bool bind(const string endpoint);
   // Unbinds the socket from a given endpoint.
   bool unbind(const string endpoint);
   // Connects the socket to a given endpoint string (e.g., "tcp://localhost:5555").
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
      item.socket_handle = m_ref; // Assign this socket's handle
      item.fd = 0;                // File descriptor is not relevant for MQL5 (usually)
      item.events = events;       // Events to monitor (e.g., ZMQ_POLLIN, ZMQ_POLLOUT)
      item.revents = 0;           // Clear returned events initially
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
   StringToUtf8(endpoint, buf, true); // Convert endpoint string to null-terminated UTF-8
   return zmq_bind(m_ref, buf) == 0;  // 0 on success
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
   return zmq_send(m_ref, data, (ulong)ArraySize(data), (int)flags) != -1;
}
//+------------------------------------------------------------------+
bool ZmqSocket::send(const string data, ENUM_ZMQ_SEND_RECV_FLAG flags)
{
   uchar buf[];
   StringToUtf8(data, buf, false); // Convert string to UTF-8 bytes (no null terminator if not needed)
   return send(buf, flags);        // Use the uchar[] send overload
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
//+------------------------------------------------------------------+
