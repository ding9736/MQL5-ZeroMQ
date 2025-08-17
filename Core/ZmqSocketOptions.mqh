//+------------------------------------------------------------------+
//|   Core/ZmqSocketOptions.mqh                                      |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_SOCKETOPTIONS_MQH
#define MQL_ZMQ_SOCKETOPTIONS_MQH

#include "../Lang/Native.mqh"
#include "../Common/Constants.mqh"

// --- DLL Imports ---

// Core imports for zmq_get/setsockopt with various data types
#import "libzmq.dll"
int zmq_setsockopt(long s, int option, const uchar &optval[], ulong optvallen);
int zmq_getsockopt(const long s, int option, uchar &optval[], ulong &optvallen);
int zmq_setsockopt(long s, int option, const long &optval, ulong optvallen);
int zmq_getsockopt(const long s, int option, long &optval, ulong &optvallen);
int zmq_setsockopt(long s, int option, const ulong &optval, ulong optvallen);
int zmq_getsockopt(const long s, int option, ulong &optval, ulong &optvallen);
int zmq_setsockopt(long s, int option, const int &optval, ulong optvallen);
int zmq_getsockopt(const long s, int option, int &optval, ulong &optvallen);
int zmq_setsockopt(long s, int option, const uint &optval, ulong optvallen);
int zmq_getsockopt(const long s, int option, uint &optval, ulong &optvallen);

// Added necessary import for zmq_errno(), which is used in getStringOption
int zmq_errno();
#import

//+------------------------------------------------------------------+
//| Base class providing a high-level API for ZMQ socket options.    |
//+------------------------------------------------------------------+
class ZmqSocketOptions
{
protected:
   long              m_ref; // Raw handle to the ZMQ socket

   ZmqSocketOptions(long socket_ref) : m_ref(socket_ref) {}

   //--- Low-level generic option wrappers (for various types) ---
   bool setOption(ENUM_ZMQ_SOCKET_OPTION option, const uchar &value[], ulong len)
   {
      return zmq_setsockopt(m_ref, (int)option, value, len) == 0;
   }

   bool getOption(ENUM_ZMQ_SOCKET_OPTION option, uchar &value[], ulong &len) const
   {
      return zmq_getsockopt(m_ref, (int)option, value, len) == 0;
   }

   template<typename T>
   bool setOption(ENUM_ZMQ_SOCKET_OPTION option, T value)
   {
      return zmq_setsockopt(m_ref, (int)option, value, sizeof(T)) == 0;
   }

   template<typename T>
   bool getOption(ENUM_ZMQ_SOCKET_OPTION option, T &value) const
   {
      ulong s = sizeof(T);
      return zmq_getsockopt(m_ref, (int)option, value, s) == 0;
   }

   //--- Specialized helpers for string-based options ---
   bool   setStringOption(ENUM_ZMQ_SOCKET_OPTION option, string value, bool null_terminate = true);

   // Default parameter is only specified here in the declaration.
   bool   getStringOption(ENUM_ZMQ_SOCKET_OPTION option, string &value, ulong buffer_size = 256) const;

public:
   // --- MACRO-BASED API GENERATION FOR ALL SOCKET OPTIONS ---

#define SOCKOPT_ACCESSOR(TYPE, NAME, MACRO)                                      \
   bool get##NAME(TYPE &value) const { return getOption(MACRO, value); }         \
   bool set##NAME(TYPE value)        { return setOption(MACRO, value); }

#define SOCKOPT_GETTER(TYPE, NAME, MACRO)                                        \
   bool get##NAME(TYPE &value) const { return getOption(MACRO, value); }

#define SOCKOPT_BOOL_GETTER(NAME, MACRO)                                         \
   bool is##NAME(bool &value) const { int v=0; bool res = getOption(MACRO, v); if(res) value = (v != 0); return res; }

#define SOCKOPT_BOOL_ACCESSOR(NAME, MACRO)                                       \
   bool is##NAME(bool &value) const { int v=0; bool res = getOption(MACRO, v); if(res) value = (v != 0); return res; } \
   bool set##NAME(bool value)       { return setOption(MACRO, (int)(value ? 1 : 0)); }

#define SOCKOPT_STRING_GETTER(NAME, MACRO, BUF_SIZE)                             \
   bool get##NAME(string &value) const { return getStringOption(MACRO, value, BUF_SIZE); }

#define SOCKOPT_STRING_ACCESSOR(NAME, MACRO, BUF_SIZE)                           \
   bool get##NAME(string &value) const { return getStringOption(MACRO, value, BUF_SIZE); } \
   bool set##NAME(string value)        { return setStringOption(MACRO, value, true); }

#define SOCKOPT_BYTES_ACCESSOR(NAME, MACRO, READ_BUF_SIZE)                        \
   bool set##NAME(const uchar &value[]) { return setOption(MACRO, value, (ulong)ArraySize(value)); } \
   bool set##NAME(string value)         { return setStringOption(MACRO, value, false); } \
   bool get##NAME(uchar &value[]) const { ulong len = (ulong)READ_BUF_SIZE; ArrayResize(value, (int)len); bool res = getOption(MACRO, value, len); if(res) ArrayResize(value, (int)len); else ArrayResize(value,0); return res; } \
   bool get##NAME(string &value) const  { return getStringOption(MACRO, value, READ_BUF_SIZE); }

#define SOCKOPT_CURVE_KEY_ACCESSOR(KEYTYPE, MACRO)                               \
   bool getCurve##KEYTYPE##Key(uchar &key[]) const { ulong len=32; ArrayResize(key,32); return getOption(MACRO, key, len); } \
   bool setCurve##KEYTYPE##Key(const uchar &key[]) { if(ArraySize(key)!=32) return false; return setOption(MACRO, key, 32); } \
   bool getCurve##KEYTYPE##Key(string &key_z85) const { uchar buf[41]; ulong len=41; bool res=getOption(MACRO, buf, len); if(res) key_z85 = StringFromUtf8(buf); return res; } \
   bool setCurve##KEYTYPE##Key(string key_z85) { return setStringOption(MACRO, key_z85, true); }

   // --- PUBLIC API: All ZMQ Socket Options ---
   SOCKOPT_GETTER(int, Type, ZMQ_OPT_TYPE)
   SOCKOPT_ACCESSOR(ulong, Affinity, ZMQ_OPT_AFFINITY)
   SOCKOPT_ACCESSOR(int, Backlog, ZMQ_OPT_BACKLOG)
   SOCKOPT_ACCESSOR(int, ConnectTimeout, ZMQ_OPT_CONNECT_TIMEOUT)
   SOCKOPT_BOOL_GETTER(ThreadSafe, ZMQ_OPT_THREAD_SAFE)
   SOCKOPT_BOOL_ACCESSOR(Conflate, ZMQ_OPT_CONFLATE)
   SOCKOPT_GETTER(int, Events, ZMQ_OPT_EVENTS)
   SOCKOPT_GETTER(long, FileDescriptor, ZMQ_OPT_FD)
   SOCKOPT_GETTER(int, Mechanism, ZMQ_OPT_MECHANISM)
   SOCKOPT_STRING_ACCESSOR(PlainUsername, ZMQ_OPT_PLAIN_USERNAME, 256)
   SOCKOPT_STRING_ACCESSOR(PlainPassword, ZMQ_OPT_PLAIN_PASSWORD, 256)
   SOCKOPT_BOOL_ACCESSOR(PlainServer, ZMQ_OPT_PLAIN_SERVER)
   // [FIXED] Corrected casing from GssApi to GSSAPI to match Constants.mqh
   SOCKOPT_BOOL_ACCESSOR(GssApiPlainText, ZMQ_OPT_GSSAPI_PLAINTEXT)
   SOCKOPT_BOOL_ACCESSOR(GssApiServer, ZMQ_OPT_GSSAPI_SERVER)
   SOCKOPT_STRING_ACCESSOR(GssApiPrincipal, ZMQ_OPT_GSSAPI_PRINCIPAL, 256)
   SOCKOPT_STRING_ACCESSOR(GssApiServicePrincipal, ZMQ_OPT_GSSAPI_SERVICE_PRINCIPAL, 256)
   SOCKOPT_BOOL_ACCESSOR(CurveServer, ZMQ_OPT_CURVE_SERVER)
   SOCKOPT_CURVE_KEY_ACCESSOR(Public, ZMQ_OPT_CURVE_PUBLICKEY)
   SOCKOPT_CURVE_KEY_ACCESSOR(Secret, ZMQ_OPT_CURVE_SECRETKEY)
   SOCKOPT_CURVE_KEY_ACCESSOR(Server, ZMQ_OPT_CURVE_SERVERKEY)
   SOCKOPT_STRING_GETTER(LastEndpoint, ZMQ_OPT_LAST_ENDPOINT, 256)
   SOCKOPT_ACCESSOR(int, HandshakeInterval, ZMQ_OPT_HANDSHAKE_IVL)
   SOCKOPT_ACCESSOR(int, HeartbeatInterval, ZMQ_OPT_HEARTBEAT_IVL)
   SOCKOPT_ACCESSOR(int, HeartbeatTimeout, ZMQ_OPT_HEARTBEAT_TIMEOUT)
   SOCKOPT_ACCESSOR(int, HeartbeatTtl, ZMQ_OPT_HEARTBEAT_TTL)
   SOCKOPT_BOOL_ACCESSOR(Immediate, ZMQ_OPT_IMMEDIATE)
   SOCKOPT_BOOL_ACCESSOR(Ipv6, ZMQ_OPT_IPV6)
   SOCKOPT_ACCESSOR(int, Linger, ZMQ_OPT_LINGER)
   SOCKOPT_ACCESSOR(long, MaxMessageSize, ZMQ_OPT_MAXMSGSIZE)
   SOCKOPT_ACCESSOR(int, MulticastHops, ZMQ_OPT_MULTICAST_HOPS)
   SOCKOPT_ACCESSOR(int, Rate, ZMQ_OPT_RATE)
   SOCKOPT_ACCESSOR(int, RecoveryInterval, ZMQ_OPT_RECOVERY_IVL)
   SOCKOPT_ACCESSOR(int, ReceiveBuffer, ZMQ_OPT_RCVBUF)
   SOCKOPT_ACCESSOR(int, ReceiveHighWaterMark, ZMQ_OPT_RCVHWM)
   SOCKOPT_ACCESSOR(int, ReceiveTimeout, ZMQ_OPT_RCVTIMEO)
   SOCKOPT_BOOL_GETTER(ReceiveMore, ZMQ_OPT_RCVMORE)
   SOCKOPT_ACCESSOR(int, ReconnectInterval, ZMQ_OPT_RECONNECT_IVL)
   SOCKOPT_ACCESSOR(int, ReconnectIntervalMax, ZMQ_OPT_RECONNECT_IVL_MAX)
   SOCKOPT_BOOL_ACCESSOR(RequestCorrelated, ZMQ_OPT_REQ_CORRELATE)
   SOCKOPT_BOOL_ACCESSOR(RequestRelaxed, ZMQ_OPT_REQ_RELAXED)
   SOCKOPT_BOOL_ACCESSOR(RouterHandover, ZMQ_OPT_ROUTER_HANDOVER)
   SOCKOPT_BOOL_ACCESSOR(RouterMandatory, ZMQ_OPT_ROUTER_MANDATORY)
   SOCKOPT_BOOL_ACCESSOR(RouterRaw, ZMQ_OPT_ROUTER_RAW)
   SOCKOPT_ACCESSOR(int, SendBuffer, ZMQ_OPT_SNDBUF)
   SOCKOPT_ACCESSOR(int, SendHighWaterMark, ZMQ_OPT_SNDHWM)
   SOCKOPT_ACCESSOR(int, SendTimeout, ZMQ_OPT_SNDTIMEO)
   SOCKOPT_STRING_ACCESSOR(SocksProxy, ZMQ_OPT_SOCKS_PROXY, 256)
   SOCKOPT_BOOL_ACCESSOR(StreamNotify, ZMQ_OPT_STREAM_NOTIFY)
   SOCKOPT_BYTES_ACCESSOR(Subscribe, ZMQ_OPT_SUBSCRIBE, 256)
   SOCKOPT_BYTES_ACCESSOR(Unsubscribe, ZMQ_OPT_UNSUBSCRIBE, 256)
   SOCKOPT_ACCESSOR(int, TcpKeepAlive, ZMQ_OPT_TCP_KEEPALIVE)
   SOCKOPT_ACCESSOR(int, TcpKeepAliveCount, ZMQ_OPT_TCP_KEEPALIVE_CNT)
   SOCKOPT_ACCESSOR(int, TcpKeepAliveIdle, ZMQ_OPT_TCP_KEEPALIVE_IDLE)
   SOCKOPT_ACCESSOR(int, TcpKeepAliveInterval, ZMQ_OPT_TCP_KEEPALIVE_INTVL)
   SOCKOPT_ACCESSOR(int, TypeOfService, ZMQ_OPT_TOS)
   SOCKOPT_BYTES_ACCESSOR(Identity, ZMQ_OPT_IDENTITY, 256)
   SOCKOPT_BYTES_ACCESSOR(ConnectRid, ZMQ_OPT_CONNECT_RID, 256)
   SOCKOPT_BOOL_ACCESSOR(XpubVerbose, ZMQ_OPT_XPUB_VERBOSE)
   SOCKOPT_BOOL_ACCESSOR(XpubVerboser, ZMQ_OPT_XPUB_VERBOSER)
   SOCKOPT_BOOL_ACCESSOR(XpubManual, ZMQ_OPT_XPUB_MANUAL)
   SOCKOPT_BOOL_ACCESSOR(XpubNoDrop, ZMQ_OPT_XPUB_NODROP)
   SOCKOPT_BYTES_ACCESSOR(XpubWelcomeMessage, ZMQ_OPT_XPUB_WELCOME_MSG, 256)
   SOCKOPT_BOOL_ACCESSOR(InvertMatching, ZMQ_OPT_INVERT_MATCHING)
   SOCKOPT_STRING_ACCESSOR(ZapDomain, ZMQ_OPT_ZAP_DOMAIN, 256)

   //--- Convenience methods for common SUB/XSUB socket operations ---
   bool subscribe(string channel)
   {
      return setSubscribe(channel);
   }
   bool unsubscribe(string channel)
   {
      return setUnsubscribe(channel);
   }
};

//+------------------------------------------------------------------+
//| Sets a socket option using a string value.                       |
//+------------------------------------------------------------------+
bool ZmqSocketOptions::setStringOption(ENUM_ZMQ_SOCKET_OPTION option, const string value, bool null_terminate)
{
   uchar buf[];
   StringToUtf8(value, buf, null_terminate);
   return setOption(option, buf, (ulong)ArraySize(buf));
}

//+------------------------------------------------------------------+
//| [OPTIMIZED] Gets a socket option that is a string.               |
//+------------------------------------------------------------------+
bool ZmqSocketOptions::getStringOption(ENUM_ZMQ_SOCKET_OPTION option, string &value, ulong buffer_size) const
{
   uchar dummy[];
   ulong required_size = 0;
   if(zmq_getsockopt(m_ref, (int)option, dummy, required_size) != 0 && zmq_errno() != ZMQ_EMSGSIZE)
   {
      value = "";
      return false;
   }
   if(required_size <= 0)
   {
      value = "";
      return true;
   }
   uchar buf[];
   if(ArrayResize(buf, (int)required_size) < (int)required_size)
   {
      value = "";
      return false;
   }
   if(zmq_getsockopt(m_ref, (int)option, buf, required_size) == 0)
   {
      ArrayResize(buf, (int)required_size);
      value = StringFromUtf8(buf);
      return true;
   }
   value = "";
   return false;
}

#endif // MQL_ZMQ_SOCKETOPTIONS_MQH
//+------------------------------------------------------------------+
