//+------------------------------------------------------------------+
//|   Core/Constants.mqh                                             |
//+------------------------------------------------------------------+

#ifndef MQL_ZMQ_CONSTANTS_MQH
#define MQL_ZMQ_CONSTANTS_MQH
#property strict

enum ENUM_ZMQ_ERROR
{
// --- Standard POSIX-like Errors Used by ZMQ ---
   ZMQ_EPERM          = 1,       // Operation not permitted
   ZMQ_ENOENT         = 2,       // No such file or directory
   ZMQ_EINTR          = 4,       // Interrupted system call (e.g., IsStopped() in MQL5)
   ZMQ_EIO            = 5,       // I/O error
   ZMQ_ENXIO          = 6,       // No such device or address
   ZMQ_EBADF          = 9,       // Bad file descriptor
   ZMQ_EAGAIN         = 11,      // Try again (non-blocking operation would block)
   ZMQ_EWOULDBLOCK    = 11,      // Alias for EAGAIN, operation would block
   ZMQ_ENOMEM         = 12,      // Out of memory
   ZMQ_EACCES         = 13,      // Permission denied
   ZMQ_EFAULT         = 14,      // Bad address
   ZMQ_EBUSY          = 16,      // Device or resource busy
   ZMQ_EEXIST         = 17,      // File exists
   ZMQ_ENOTDIR        = 20,      // Not a directory
   ZMQ_EISDIR         = 21,      // Is a directory
   ZMQ_EINVAL         = 22,      // Invalid argument
   ZMQ_ENFILE         = 23,      // Too many open files in system
   ZMQ_EMFILE         = 24,      // Too many open files (per process)
   ZMQ_ENOSPC         = 28,      // No space left on device
   ZMQ_EDOM           = 33,      // Math argument out of domain of func
   ZMQ_ERANGE         = 34,      // Math result not representable
   ZMQ_EDEADLK        = 36,      // Resource deadlock would occur
   ZMQ_ENAMETOOLONG   = 38,      // File name too long
   ZMQ_ENOLCK         = 39,      // No record locks available
   ZMQ_ENOSYS         = 40,      // Function not implemented
   ZMQ_ENOTEMPTY      = 41,      // Directory not empty
   ZMQ_EILSEQ         = 42,      // Illegal byte sequence

   // --- FIX: Correcting EADDRINUSE to match the value returned by some environments/versions (like 100).
   // The original Hausnumero-based value (156384712 + 5) is theoretically correct but not always what zmq_errno() returns in practice for this error.
   ZMQ_EADDRINUSE     = 100,     // Address already in use


// --- ZMQ Native Error Codes (starting from ZMQ_HAUSNUMERO which is base offset) ---
// ZMQ_HAUSNUMERO is internal, errors above it are ZeroMQ specific.
   ZMQ_ENOTSUP        = 156384712 + 1,    // Operation not supported by socket type or transport
   ZMQ_EPROTONOSUPPORT= 156384712 + 2,    // Protocol not supported
   ZMQ_ENOBUFS        = 156384712 + 3,    // No buffer space available
   ZMQ_ENETDOWN       = 156384712 + 4,    // Network is down
   //ZMQ_EADDRINUSE       = 156384712 + 5,  // Original value, now superseded by the corrected one above.
   ZMQ_EADDRNOTAVAIL  = 156384712 + 6,    // Cannot assign requested address
   ZMQ_ECONNREFUSED   = 156384712 + 7,    // Connection refused by peer
   ZMQ_EINPROGRESS    = 156384712 + 8,    // Operation now in progress (non-blocking connect)
   ZMQ_ENOTSOCK       = 156384712 + 9,    // Socket operation on non-socket (bad descriptor)
   ZMQ_EMSGSIZE       = 156384712 + 10,   // Message too long (exceeds ZMQ_MAXMSGSIZE)
   ZMQ_EAFNOSUPPORT   = 156384712 + 11,   // Address family not supported by protocol
   ZMQ_ENETUNREACH    = 156384712 + 12,   // Network is unreachable
   ZMQ_ECONNABORTED   = 156384712 + 13,   // Software caused connection abort
   ZMQ_ECONNRESET     = 156384712 + 14,   // Connection reset by peer
   ZMQ_ENOTCONN       = 156384712 + 15,   // Transport endpoint is not connected
   ZMQ_ETIMEDOUT      = 156384712 + 16,   // Connection timed out
   ZMQ_EHOSTUNREACH   = 156384712 + 17,   // No route to host
   ZMQ_ENETRESET      = 156384712 + 18,   // Network dropped connection because of reset

// --- ZMQ Native Errors (continued) ---
   ZMQ_EFSM           = 156384712 + 51,   // Finite State Machine (FSM) error
   ZMQ_ENOCOMPATPROTO = 156384712 + 52,   // The protocol is not compatible with the socket type
   ZMQ_ETERM          = 156384712 + 53,   // The ZMQ context is terminated (graceful or forced shutdown)
   ZMQ_EMTHREAD       = 156384712 + 54,   // No thread available (context exhausted thread limit)
};

//+------------------------------------------------------------------+
enum ENUM_ZMQ_CONTEXT_OPTION
{
   ZMQ_OPT_IO_THREADS          = 1,   // Number of I/O threads (integer)
   ZMQ_OPT_MAX_SOCKETS         = 2,   // Maximum number of sockets per context (integer)
   ZMQ_OPT_SOCKET_LIMIT        = 3,   // (DEPRECATED) Alias for MAX_SOCKETS
   ZMQ_OPT_THREAD_PRIORITY     = 4,   // I/O thread priority (integer)
   ZMQ_OPT_THREAD_SCHED_POLICY = 5,   // I/O thread scheduling policy (integer)
   ZMQ_OPT_MAX_MSGSZ           = 6    // Maximum message size a context can handle (long, applies to receive operations)
};

//+------------------------------------------------------------------+
enum ENUM_ZMQ_SOCKET_TYPE
{
   ZMQ_SOCKET_PAIR     = 0,  // Pair-to-pair synchronous communication
   ZMQ_SOCKET_PUB      = 1,  // Publish (many-to-many non-guaranteed distribution)
   ZMQ_SOCKET_SUB      = 2,  // Subscribe
   ZMQ_SOCKET_REQ      = 3,  // Request (strict send-recv pattern)
   ZMQ_SOCKET_REP      = 4,  // Reply
   ZMQ_SOCKET_DEALER   = 5,  // Extended REQ (asynchronous, stateless client/worker)
   ZMQ_SOCKET_ROUTER   = 6,  // Extended REP (asynchronous, message routing)
   ZMQ_SOCKET_PULL     = 7,  // Pull (part of pipeline, receives from PUSH)
   ZMQ_SOCKET_PUSH     = 8,  // Push (part of pipeline, sends to PULL)
   ZMQ_SOCKET_XPUB     = 9,  // Extended PUB (can receive subscriptions/unsubscriptions)
   ZMQ_SOCKET_XSUB     = 10, // Extended SUB (can manually send subscriptions)
   ZMQ_SOCKET_STREAM   = 11  // Connected pair using OS streaming I/O
};

//+------------------------------------------------------------------+
enum ENUM_ZMQ_SEND_RECV_FLAG
{
   ZMQ_FLAG_NONE     = 0,  // No flags. Blocking operation by default.
   ZMQ_FLAG_DONTWAIT = 1,  // Non-blocking operation. Return immediately if not ready.
   ZMQ_FLAG_SNDMORE  = 2,  // Indicates this message is part of a multi-part message (more frames to follow).
};

//+------------------------------------------------------------------+
enum ENUM_ZMQ_EVENT
{
   ZMQ_EVENT_CONNECTED       = 0x0001, // A socket connected to a remote peer.
   ZMQ_EVENT_CONNECT_DELAYED = 0x0002, // The connect operation is in progress, and there has been a delay.
   ZMQ_EVENT_CONNECT_RETRIED = 0x0004, // A connect attempt failed, and is being retried.
   ZMQ_EVENT_LISTENING       = 0x0008, // A socket started listening.
   ZMQ_EVENT_BIND_FAILED     = 0x0010, // A bind operation failed.
   ZMQ_EVENT_ACCEPTED        = 0x0020, // A new connection was accepted by a listening socket.
   ZMQ_EVENT_ACCEPT_FAILED   = 0x0040, // A connection accept operation failed.
   ZMQ_EVENT_CLOSED          = 0x0080, // A socket connection was closed.
   ZMQ_EVENT_CLOSE_FAILED    = 0x0100, // (Not usually reported for actual close errors)
   ZMQ_EVENT_DISCONNECTED    = 0x0200, // A socket was disconnected.
   ZMQ_EVENT_MONITOR_STOPPED = 0x0400, // The monitoring socket itself stopped.
   ZMQ_EVENT_ALL             = 0xFFFF  // Bitmask for all possible events.
};

//+------------------------------------------------------------------+
//| Enumeration for ZMQ Poll Item Events                             |
//| These are bit flags used with zmq_poll() to indicate readiness states.
//+------------------------------------------------------------------+
enum ENUM_ZMQ_POLL_EVENT
{
   ZMQ_POLLIN  = 1,   // The socket is ready to receive a message.
   ZMQ_POLLOUT = 2,   // The socket is ready to send a message.
   ZMQ_POLLERR = 4,   // An asynchronous error has occurred on the socket. (Less common in practice for ZMQ sockets as errors tend to terminate connection).
   ZMQ_POLLPRI = 8    // Not used by ZeroMQ; often seen in generic socket polling APIs.
};


//+------------------------------------------------------------------+
enum ENUM_ZMQ_SOCKET_OPTION
{
   ZMQ_OPT_AFFINITY             = 4,   // I/O thread affinity (bitmask)
   ZMQ_OPT_IDENTITY             = 5,   // Socket identity (string/bytes)
   ZMQ_OPT_SUBSCRIBE            = 6,   // Subscribe filter (bytes)
   ZMQ_OPT_UNSUBSCRIBE          = 7,   // Unsubscribe filter (bytes)
   ZMQ_OPT_RATE                 = 8,   // Multicast data rate limit
   ZMQ_OPT_RECOVERY_IVL         = 9,   // Multicast recovery interval
   ZMQ_OPT_SNDBUF               = 11,  // Send buffer size
   ZMQ_OPT_RCVBUF               = 12,  // Receive buffer size
   ZMQ_OPT_RCVMORE              = 13,  // Check if more message parts are waiting (read-only)
   ZMQ_OPT_FD                   = 14,  // Get file descriptor of socket (read-only)
   ZMQ_OPT_EVENTS               = 15,  // Current socket events (read-only, combine ZMQ_POLLIN | ZMQ_POLLOUT)
   ZMQ_OPT_TYPE                 = 16,  // Socket type (read-only)
   ZMQ_OPT_LINGER               = 17,  // Socket linger period (ms)
   ZMQ_OPT_RECONNECT_IVL        = 18,  // Reconnect interval (ms)
   ZMQ_OPT_BACKLOG              = 19,  // Max pending connections for bind
   ZMQ_OPT_RECONNECT_IVL_MAX    = 21,  // Max reconnect interval (ms)
   ZMQ_OPT_MAXMSGSIZE           = 22,  // Max incoming message size
   ZMQ_OPT_SNDHWM               = 23,  // Send high water mark (outgoing message queue limit)
   ZMQ_OPT_RCVHWM               = 24,  // Receive high water mark (incoming message queue limit)
   ZMQ_OPT_MULTICAST_HOPS       = 25,  // Multicast hops limit
   ZMQ_OPT_RCVTIMEO             = 27,  // Receive timeout (ms)
   ZMQ_OPT_SNDTIMEO             = 28,  // Send timeout (ms)
   ZMQ_OPT_LAST_ENDPOINT        = 32,  // Last bound/connected endpoint (read-only string)
   ZMQ_OPT_ROUTER_MANDATORY     = 33,  // For ROUTER sockets, mandatory routing flag
   ZMQ_OPT_TCP_KEEPALIVE        = 34,  // TCP keep-alive settings
   ZMQ_OPT_TCP_KEEPALIVE_CNT    = 35,  // TCP keep-alive probes count
   ZMQ_OPT_TCP_KEEPALIVE_IDLE   = 36,  // TCP keep-alive idle time
   ZMQ_OPT_TCP_KEEPALIVE_INTVL  = 37,  // TCP keep-alive interval
   ZMQ_OPT_IMMEDIATE            = 39,  // Send without waiting for peers (non-queueing)
   ZMQ_OPT_XPUB_VERBOSE         = 40,  // For XPUB, enable verbose subscription forwarding
   ZMQ_OPT_ROUTER_RAW           = 41,  // For ROUTER, receive raw frames including identity
   ZMQ_OPT_IPV6                 = 42,  // Enable IPv6
   ZMQ_OPT_MECHANISM            = 43,  // Get security mechanism type (read-only)
   ZMQ_OPT_PLAIN_SERVER         = 44,  // Set as PLAIN authentication server
   ZMQ_OPT_PLAIN_USERNAME       = 45,  // PLAIN username
   ZMQ_OPT_PLAIN_PASSWORD       = 46,  // PLAIN password
   ZMQ_OPT_CURVE_SERVER         = 47,  // Set as CURVE authentication server
   ZMQ_OPT_CURVE_PUBLICKEY      = 48,  // CURVE public key
   ZMQ_OPT_CURVE_SECRETKEY      = 49,  // CURVE secret key
   ZMQ_OPT_CURVE_SERVERKEY      = 50,  // CURVE server public key (client side)
   ZMQ_OPT_PROBE_ROUTER         = 51,  // For ROUTER, receive identity of connecting peer on connect
   ZMQ_OPT_REQ_CORRELATE        = 52,  // For REQ, enforce strict request-reply cycle
   ZMQ_OPT_REQ_RELAXED          = 53,  // For REQ, relax request-reply cycle
   ZMQ_OPT_CONFLATE             = 54,  // Discard old messages if new arrives (queue latest)
   ZMQ_OPT_ZAP_DOMAIN           = 55,  // ZAP domain for authentication
   ZMQ_OPT_ROUTER_HANDOVER      = 56,  // Router socket allows client re-connection handover
   ZMQ_OPT_TOS                  = 57,  // Type-of-Service for IP packets
   ZMQ_OPT_CONNECT_RID          = 61,  // For DEALER, provide ROUTER identity for connect
   ZMQ_OPT_GSSAPI_SERVER        = 62,  // Set as GSSAPI authentication server
   ZMQ_OPT_GSSAPI_PRINCIPAL     = 63,  // GSSAPI principal
   ZMQ_OPT_GSSAPI_SERVICE_PRINCIPAL = 64,  // GSSAPI service principal
   ZMQ_OPT_GSSAPI_PLAINTEXT     = 65,  // GSSAPI authentication accepts plaintext (insecure)
   ZMQ_OPT_HANDSHAKE_IVL        = 66,  // Handshake interval (ms)
   ZMQ_OPT_SOCKS_PROXY          = 68,  // SOCKS5 proxy URI
   ZMQ_OPT_XPUB_NODROP          = 69,  // XPUB will not drop messages even if queue is full
   ZMQ_OPT_BLOCKY               = 70,  // Deprecated. Blocking behavior, use ZMQ_FLAG_DONTWAIT.
   ZMQ_OPT_XPUB_MANUAL          = 71,  // XPUB will send subscription messages manually
   ZMQ_OPT_XPUB_WELCOME_MSG     = 72,  // XPUB welcome message for new subscribers
   ZMQ_OPT_STREAM_NOTIFY        = 73,  // For STREAM, notify about connection events
   ZMQ_OPT_INVERT_MATCHING      = 74,  // Invert subscribe/unsubscribe logic (blacklist vs whitelist)
   ZMQ_OPT_HEARTBEAT_IVL        = 75,  // Heartbeat interval (ms)
   ZMQ_OPT_HEARTBEAT_TTL        = 76,  // Heartbeat time-to-live (ms)
   ZMQ_OPT_HEARTBEAT_TIMEOUT    = 77,  // Heartbeat timeout (ms)
   ZMQ_OPT_XPUB_VERBOSER        = 78,  // Even more verbose XPUB subscriptions (send XSUB data as is)
   ZMQ_OPT_CONNECT_TIMEOUT      = 79,  // Connect timeout (ms)
   ZMQ_OPT_TCP_MAXRT            = 80,  // Max TCP retransmit attempts
   ZMQ_OPT_THREAD_SAFE          = 81,  // Check if the socket type is thread-safe (read-only)
   ZMQ_OPT_MULTICAST_MAXTPDU    = 84,  // Max transfer unit for multicast (TPDU size)
   ZMQ_OPT_VMCI_BUFFER_SIZE     = 85,  // VMCI buffer size (bytes)
   ZMQ_OPT_VMCI_BUFFER_MIN_SIZE = 86,  // VMCI min buffer size (bytes)
   ZMQ_OPT_VMCI_BUFFER_MAX_SIZE = 87,  // VMCI max buffer size (bytes)
   ZMQ_OPT_VMCI_CONNECT_TIMEOUT = 88,  // VMCI connect timeout (ms)
   ZMQ_OPT_USE_FD               = 89   // Deprecated. Use file descriptor instead of ZeroMQ's own transport for I/O.
};


#endif // MQL_ZMQ_CONSTANTS
