//+------------------------------------------------------------------+
//| Module:      Common/Constants.mqh                                |
//+------------------------------------------------------------------+

#ifndef MQL_ZMQ_CONSTANTS_MQH
#define MQL_ZMQ_CONSTANTS_MQH


enum ENUM_ZMQ_ERROR
{
// --- Standard POSIX-like Errors Used by ZMQ ---
   ZMQ_EPERM           = 1,       // Operation not permitted
   ZMQ_ENOENT          = 2,       // No such file or directory
   ZMQ_EINTR           = 4,       // Interrupted system call
   ZMQ_EIO             = 5,       // I/O error
   ZMQ_ENXIO           = 6,       // No such device or address
   ZMQ_EBADF           = 9,       // Bad file descriptor
   ZMQ_EAGAIN          = 11,      // Try again
   ZMQ_EWOULDBLOCK     = 11,      // Operation would block (alias for EAGAIN)
   ZMQ_ENOMEM          = 12,      // Out of memory
   ZMQ_EACCES          = 13,      // Permission denied
   ZMQ_EFAULT          = 14,      // Bad address
   ZMQ_EBUSY           = 16,      // Device or resource busy
   ZMQ_EEXIST          = 17,      // File exists
   ZMQ_ENOTDIR         = 20,      // Not a directory
   ZMQ_EISDIR          = 21,      // Is a directory
   ZMQ_EINVAL          = 22,      // Invalid argument
   ZMQ_ENFILE          = 23,      // Too many open files in system
   ZMQ_EMFILE          = 24,      // Too many open files
   ZMQ_ENOSPC          = 28,      // No space left on device
   ZMQ_EDOM            = 33,      // Math argument out of domain of func
   ZMQ_ERANGE          = 34,      // Math result not representable
   ZMQ_EDEADLK         = 36,      // Resource deadlock would occur
   ZMQ_ENAMETOOLONG    = 38,      // File name too long
   ZMQ_ENOLCK          = 39,      // No record locks available
   ZMQ_ENOSYS          = 40,      // Function not implemented
   ZMQ_ENOTEMPTY       = 41,      // Directory not empty
   ZMQ_EILSEQ          = 42,      // Illegal byte sequence

// --- ZMQ Native Error Codes (starting from ZMQ_HAUSNUMERO = 156384712) ---
   ZMQ_ENOTSUP         = 156384712 + 1,   // Operation not supported
   ZMQ_EPROTONOSUPPORT = 156384712 + 2,   // Protocol not supported
   ZMQ_ENOBUFS         = 156384712 + 3,   // No buffer space available
   ZMQ_ENETDOWN        = 156384712 + 4,   // Network is down
   ZMQ_EADDRINUSE      = 156384712 + 5,   // Address already in use
   ZMQ_EADDRNOTAVAIL   = 156384712 + 6,   // Cannot assign requested address
   ZMQ_ECONNREFUSED    = 156384712 + 7,   // Connection refused
   ZMQ_EINPROGRESS     = 156384712 + 8,   // Operation now in progress
   ZMQ_ENOTSOCK        = 156384712 + 9,   // Socket operation on non-socket
   ZMQ_EMSGSIZE        = 156384712 + 10,  // Message too long
   ZMQ_EAFNOSUPPORT    = 156384712 + 11,  // Address family not supported by protocol
   ZMQ_ENETUNREACH     = 156384712 + 12,  // Network is unreachable
   ZMQ_ECONNABORTED    = 156384712 + 13,  // Software caused connection abort
   ZMQ_ECONNRESET      = 156384712 + 14,  // Connection reset by peer
   ZMQ_ENOTCONN        = 156384712 + 15,  // Transport endpoint is not connected
   ZMQ_ETIMEDOUT       = 156384712 + 16,  // Connection timed out
   ZMQ_EHOSTUNREACH    = 156384712 + 17,  // No route to host
   ZMQ_ENETRESET       = 156384712 + 18,  // Network dropped connection because of reset

// --- ZMQ Native Errors (continued) ---
   ZMQ_EFSM            = 156384712 + 51,  // The ZMQ state machine assertion evaluated to false
   ZMQ_ENOCOMPATPROTO  = 156384712 + 52,  // The protocol is not compatible with the socket type
   ZMQ_ETERM           = 156384712 + 53,  // The ZMQ context is terminated
   ZMQ_EMTHREAD        = 156384712 + 54,  // No thread available
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Context Options                              |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_CONTEXT_OPTION
{
   ZMQ_OPT_IO_THREADS          = 1,   // Number of I/O threads
   ZMQ_OPT_MAX_SOCKETS         = 2,   // Maximum number of sockets
   ZMQ_OPT_SOCKET_LIMIT        = 3,   // (DEPRECATED) Alias for MAX_SOCKETS
   ZMQ_OPT_THREAD_PRIORITY     = 4,   // Thread priority
   ZMQ_OPT_THREAD_SCHED_POLICY = 5,   // Thread scheduling policy
   ZMQ_OPT_MAX_MSGSZ           = 6    // Maximum message size
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Socket Types                                 |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_SOCKET_TYPE
{
   ZMQ_SOCKET_PAIR     = 0,
   ZMQ_SOCKET_PUB      = 1,
   ZMQ_SOCKET_SUB      = 2,
   ZMQ_SOCKET_REQ      = 3,
   ZMQ_SOCKET_REP      = 4,
   ZMQ_SOCKET_DEALER   = 5,
   ZMQ_SOCKET_ROUTER   = 6,
   ZMQ_SOCKET_PULL     = 7,
   ZMQ_SOCKET_PUSH     = 8,
   ZMQ_SOCKET_XPUB     = 9,
   ZMQ_SOCKET_XSUB     = 10,
   ZMQ_SOCKET_STREAM   = 11
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Send/Receive Flags                           |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_SEND_RECV_FLAG
{
   ZMQ_FLAG_NONE       = 0,
   ZMQ_FLAG_DONTWAIT   = 1,  // For non-blocking operations
   ZMQ_FLAG_SNDMORE    = 2,  // Indicates this is a multi-part message
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Socket Monitor Events                        |
//| These are bit flags and can be combined.                         |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_EVENT
{
   ZMQ_EVENT_CONNECTED       = 0x0001,
   ZMQ_EVENT_CONNECT_DELAYED = 0x0002,
   ZMQ_EVENT_CONNECT_RETRIED = 0x0004,
   ZMQ_EVENT_LISTENING       = 0x0008,
   ZMQ_EVENT_BIND_FAILED     = 0x0010,
   ZMQ_EVENT_ACCEPTED        = 0x0020,
   ZMQ_EVENT_ACCEPT_FAILED   = 0x0040,
   ZMQ_EVENT_CLOSED          = 0x0080,
   ZMQ_EVENT_CLOSE_FAILED    = 0x0100,
   ZMQ_EVENT_DISCONNECTED    = 0x0200,
   ZMQ_EVENT_MONITOR_STOPPED = 0x0400,
   ZMQ_EVENT_ALL             = 0xFFFF
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Poll Item Events                             |
//| These are bit flags for input/output readiness.                  |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_POLL_EVENT
{
   ZMQ_POLLIN   = 1,    // Check for pending messages to be received
   ZMQ_POLLOUT  = 2,    // Check if the socket is ready for sending
   ZMQ_POLLERR  = 4,    // Check for error conditions (less common with ZMQ)
   ZMQ_POLLPRI  = 8     // Check for high-priority messages (not used by ZMQ)
};


//+------------------------------------------------------------------+
//| Enumeration of ZMQ Socket Options                                |
//| Comprehensive list of all get/set socket options.                |
//+------------------------------------------------------------------+
enum ENUM_ZMQ_SOCKET_OPTION
{
   ZMQ_OPT_AFFINITY                 = 4,
   ZMQ_OPT_IDENTITY                 = 5,
   ZMQ_OPT_SUBSCRIBE                = 6,
   ZMQ_OPT_UNSUBSCRIBE              = 7,
   ZMQ_OPT_RATE                     = 8,
   ZMQ_OPT_RECOVERY_IVL             = 9,
   ZMQ_OPT_SNDBUF                   = 11,
   ZMQ_OPT_RCVBUF                   = 12,
   ZMQ_OPT_RCVMORE                  = 13,
   ZMQ_OPT_FD                       = 14,
   ZMQ_OPT_EVENTS                   = 15,
   ZMQ_OPT_TYPE                     = 16,
   ZMQ_OPT_LINGER                   = 17,
   ZMQ_OPT_RECONNECT_IVL            = 18,
   ZMQ_OPT_BACKLOG                  = 19,
   ZMQ_OPT_RECONNECT_IVL_MAX        = 21,
   ZMQ_OPT_MAXMSGSIZE               = 22,
   ZMQ_OPT_SNDHWM                   = 23,
   ZMQ_OPT_RCVHWM                   = 24,
   ZMQ_OPT_MULTICAST_HOPS           = 25,
   ZMQ_OPT_RCVTIMEO                 = 27,
   ZMQ_OPT_SNDTIMEO                 = 28,
   ZMQ_OPT_LAST_ENDPOINT            = 32,
   ZMQ_OPT_ROUTER_MANDATORY         = 33,
   ZMQ_OPT_TCP_KEEPALIVE            = 34,
   ZMQ_OPT_TCP_KEEPALIVE_CNT        = 35,
   ZMQ_OPT_TCP_KEEPALIVE_IDLE       = 36,
   ZMQ_OPT_TCP_KEEPALIVE_INTVL      = 37,
   ZMQ_OPT_IMMEDIATE                = 39,
   ZMQ_OPT_XPUB_VERBOSE             = 40,
   ZMQ_OPT_ROUTER_RAW               = 41,
   ZMQ_OPT_IPV6                     = 42,
   ZMQ_OPT_MECHANISM                = 43,
   ZMQ_OPT_PLAIN_SERVER             = 44,
   ZMQ_OPT_PLAIN_USERNAME           = 45,
   ZMQ_OPT_PLAIN_PASSWORD           = 46,
   ZMQ_OPT_CURVE_SERVER             = 47,
   ZMQ_OPT_CURVE_PUBLICKEY          = 48,
   ZMQ_OPT_CURVE_SECRETKEY          = 49,
   ZMQ_OPT_CURVE_SERVERKEY          = 50,
   ZMQ_OPT_PROBE_ROUTER             = 51,
   ZMQ_OPT_REQ_CORRELATE            = 52,
   ZMQ_OPT_REQ_RELAXED              = 53,
   ZMQ_OPT_CONFLATE                 = 54,
   ZMQ_OPT_ZAP_DOMAIN               = 55,
   ZMQ_OPT_ROUTER_HANDOVER          = 56,
   ZMQ_OPT_TOS                      = 57,
   ZMQ_OPT_CONNECT_RID              = 61,
   ZMQ_OPT_GSSAPI_SERVER            = 62,
   ZMQ_OPT_GSSAPI_PRINCIPAL         = 63,
   ZMQ_OPT_GSSAPI_SERVICE_PRINCIPAL = 64,
   ZMQ_OPT_GSSAPI_PLAINTEXT         = 65,
   ZMQ_OPT_HANDSHAKE_IVL            = 66,
   ZMQ_OPT_SOCKS_PROXY              = 68,
   ZMQ_OPT_XPUB_NODROP              = 69,
   ZMQ_OPT_BLOCKY                   = 70, // Deprecated
   ZMQ_OPT_XPUB_MANUAL              = 71,
   ZMQ_OPT_XPUB_WELCOME_MSG         = 72,
   ZMQ_OPT_STREAM_NOTIFY            = 73,
   ZMQ_OPT_INVERT_MATCHING          = 74,
   ZMQ_OPT_HEARTBEAT_IVL            = 75,
   ZMQ_OPT_HEARTBEAT_TTL            = 76,
   ZMQ_OPT_HEARTBEAT_TIMEOUT        = 77,
   ZMQ_OPT_XPUB_VERBOSER            = 78,
   ZMQ_OPT_CONNECT_TIMEOUT          = 79,
   ZMQ_OPT_TCP_MAXRT                = 80,
   ZMQ_OPT_THREAD_SAFE              = 81,
   ZMQ_OPT_MULTICAST_MAXTPDU        = 84,
   ZMQ_OPT_VMCI_BUFFER_SIZE         = 85,
   ZMQ_OPT_VMCI_BUFFER_MIN_SIZE     = 86,
   ZMQ_OPT_VMCI_BUFFER_MAX_SIZE     = 87,
   ZMQ_OPT_VMCI_CONNECT_TIMEOUT     = 88,
   ZMQ_OPT_USE_FD                   = 89
};


#endif // MQL_ZMQ_CONSTANTS_MQH
//+------------------------------------------------------------------+
