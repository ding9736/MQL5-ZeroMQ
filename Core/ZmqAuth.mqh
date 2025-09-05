//+------------------------------------------------------------------+
//|  Core/ZmqAuth.mqh                                                |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_AUTH_MQH
#define MQL_ZMQ_AUTH_MQH
#property strict

#include "MqlThread.mqh"
#include "ZmqSocket.mqh"
#include "ZmqZ85Codec.mqh"
#include "MqlIPC.mqh"


#import "libzmq.dll"
long zmq_ctx_new();
int  zmq_ctx_term(long context);
#import

//+------------------------------------------------------------------+
//| CThreadSafeFlag                                                  |
//| A simple thread-safe boolean flag.                               |
//+------------------------------------------------------------------+
class CThreadSafeFlag
{
private:
   CriticalSection   m_cs;
   bool              m_value;

public:
   CThreadSafeFlag() : m_value(false), m_cs("ThreadSafeFlag.Mutex.v2")
   {
   }
   ~CThreadSafeFlag()
   {
   }
   void Set(bool value)
   {
      m_cs.enter();
      m_value = value;
      m_cs.leave();
   }
   bool Get()
   {
      m_cs.enter();
      bool value = m_value;
      m_cs.leave();
      return value;
   }
};

//+------------------------------------------------------------------+
//| CSafePublicKeySet                                                |
//| A thread-safe set to store authorized Z85 public keys.           |
//+------------------------------------------------------------------+
class CSafePublicKeySet
{
private:
     CriticalSection   m_cs;
   string            m_keys[];

public:
   CSafePublicKeySet() : m_cs("Zmq.Auth.PublicKeySet.Mutex.v2")
   {
   }
   ~CSafePublicKeySet()
   {
   }

   void Add(const string z85_public_key)
   {
      m_cs.enter();
      bool found = false;
      for(int i = 0; i < ArraySize(m_keys); i++)
      {
         if(m_keys[i] == z85_public_key)
         {
            found = true;
            break;
         }
      }
      if(!found)
      {
         int last_idx = ArrayResize(m_keys, ArraySize(m_keys) + 1) - 1;
         m_keys[last_idx] = z85_public_key;
      }
      m_cs.leave();
   }

   // [FIX] 'const' removed.
   bool Contains(const string z85_public_key)
   {
      m_cs.enter();
      bool found = false;
      for(int i = 0; i < ArraySize(m_keys); i++)
      {
         if(m_keys[i] == z85_public_key)
         {
            found = true;
            break;
         }
      }
      m_cs.leave();
      return found;
   }

   bool Remove(const string z85_public_key)
   {
      m_cs.enter();
      bool removed = false;
      int size = ArraySize(m_keys);
      for(int i = 0; i < size; i++)
      {
         if(m_keys[i] == z85_public_key)
         {
            for(int j = i; j < size - 1; j++)
            {
               m_keys[j] = m_keys[j + 1];
            }
            ArrayResize(m_keys, size - 1);
            removed = true;
            break;
         }
      }
      m_cs.leave();
      return removed;
   }

   void Clear()
   {
      m_cs.enter();
      ArrayFree(m_keys);
      m_cs.leave();
   }

   // [FIX] 'const' removed.
   int Size()
   {
      m_cs.enter();
      int size = ArraySize(m_keys);
      m_cs.leave();
      return size;
   }
};

//+------------------------------------------------------------------+
//| CZmqZapHandler                                                   |
//| Implements non-blocking IRunnable interface.                     |
//+------------------------------------------------------------------+
class CZmqZapHandler : public IRunnable
{
private:
   CThreadSafeFlag* m_is_running_flag;        // Shared flag to signal termination
   // [MODIFIED] The handler now owns its own, isolated ZMQ context.
   long                m_auth_context_ref;   // The handle for the ZAP-specific context.
   CSafePublicKeySet* m_allowed_keys;        // Pointer to allowed keys set
   ZmqSocket* m_auth_socket;                 // Socket for ZAP communication

   static const string ZAP_HANDLER_ADDRESS;
   static const int    RECV_TIMEOUT_MS;
   static const string ZAP_VERSION;

public:
   // [MODIFIED] Constructor is now self-contained, no longer needs the parent context.
   CZmqZapHandler(CSafePublicKeySet* allowed_keys, CThreadSafeFlag* running_flag)
      : m_allowed_keys(allowed_keys),
        m_is_running_flag(running_flag),
        m_auth_context_ref(0),
        m_auth_socket(NULL)
   {
      if(CheckPointer(m_allowed_keys) == POINTER_INVALID) ZMQ_LOG_ERROR("ZAP Handler: Invalid key set pointer.");
      if(CheckPointer(m_is_running_flag) == POINTER_INVALID) ZMQ_LOG_ERROR("ZAP Handler: Invalid running flag pointer.");
   }

   ~CZmqZapHandler()
   {
   }

   virtual void OnStart()
   {
      ZMQ_LOG_DEBUG("ZAP Handler -> Task starting...");

      // [ADDED] Create a dedicated context for the ZAP handler. This is the core architectural fix.
      m_auth_context_ref = zmq_ctx_new();
      if(m_auth_context_ref == 0)
      {
         ZMQ_LOG_ERROR("ZAP Handler -> FAILED to create its own ZMQ context!");
         return; // Fail starting the task.
      }
      ZMQ_LOG_DEBUG("ZAP Handler -> Dedicated ZMQ context created.");

      if(InitializeSocket())
      {
         if(CheckPointer(m_is_running_flag) != POINTER_INVALID)
         {
            m_is_running_flag.Set(true);
         }
      }
   }

   virtual bool Execute()
   {
      if(CheckPointer(m_is_running_flag) == POINTER_INVALID || !m_is_running_flag.Get())
      {
         return false; // Stop the task
      }
      if(CheckPointer(m_auth_socket) != POINTER_INVALID && m_auth_socket.isValid())
      {
         string request[];
         if(m_auth_socket.recvMultipart(request, ZMQ_FLAG_DONTWAIT))
         {
            ProcessAuthRequest(request);
         }
      }
      return true; // Keep the task running
   }

   virtual void OnStop()
   {
      if(CheckPointer(m_auth_socket) == POINTER_DYNAMIC)
      {
         delete m_auth_socket;
         m_auth_socket = NULL;
      }
      
      // [ADDED] Clean up the dedicated ZAP context upon stopping.
      if(m_auth_context_ref != 0)
      {
         zmq_ctx_term(m_auth_context_ref);
         m_auth_context_ref = 0;
         ZMQ_LOG_DEBUG("ZAP Handler -> Dedicated ZMQ context terminated.");
      }
      
      ZMQ_LOG_DEBUG("ZAP Handler -> Task terminated.");
   }

private:
   bool InitializeSocket()
   {
      // [MODIFIED] The socket is now created from its own internal context handle.
      m_auth_socket = new ZmqSocket(m_auth_context_ref, ZMQ_SOCKET_REP);
      if(!m_auth_socket.isValid())
      {
         ZMQ_LOG_ERROR("ZAP Handler -> Failed to create REP socket.");
         delete m_auth_socket;
         m_auth_socket = NULL;
         return false;
      }
      if(!m_auth_socket.bind(ZAP_HANDLER_ADDRESS))
      {
         ZMQ_LOG_ERROR("ZAP Handler -> Failed to bind to " + ZAP_HANDLER_ADDRESS);
         delete m_auth_socket;
         m_auth_socket = NULL;
         return false;
      }
      if(!m_auth_socket.setReceiveTimeout(RECV_TIMEOUT_MS))
      {
         ZMQ_LOG_DEBUG("ZAP Handler -> WARNING: Failed to set receive timeout.");
      }
      ZMQ_LOG_DEBUG("ZAP Handler -> Successfully bound to " + ZAP_HANDLER_ADDRESS);
      return true;
   }

   bool ProcessAuthRequest(string &request[])
   {
      if(ArraySize(request) < 7)
      {
         ZMQ_LOG_ERROR(StringFormat("ZAP Handler -> Malformed request with %d parts.", ArraySize(request)));
         return false;
      }
      string version = request[0];
      string req_id = request[1];
      string mechanism = request[5];
      if(version != ZAP_VERSION)
      {
         return SendResponse(version, req_id, "400", "Unsupported Version", "", "");
      }
      if(mechanism == "CURVE")
      {
         return ProcessCurveAuth(version, req_id, request[6]);
      }
      return SendResponse(version, req_id, "400", "Mechanism Not Supported", "", "");
   }

   bool ProcessCurveAuth(const string version, const string req_id, const string &client_key_frame)
   {
      uchar client_key_bin[];
      StringToCharArray(client_key_frame, client_key_bin);
      if(ArraySize(client_key_bin) != 32)
      {
         return SendResponse(version, req_id, "400", "Invalid Key Size", "", "");
      }
      string client_key_z85 = ZmqZ85Codec::encode(client_key_bin);
      if(client_key_z85 == "" || CheckPointer(m_allowed_keys) == POINTER_INVALID)
      {
         return SendResponse(version, req_id, "500", "Internal Server Error", "", "");
      }
      if(m_allowed_keys.Contains(client_key_z85))
      {
         return SendResponse(version, req_id, "200", "OK", "authorized_user", "");
      }
      else
      {
         return SendResponse(version, req_id, "403", "Forbidden", "", "");
      }
   }

   bool SendResponse(const string v, const string id, const string code, const string text, const string user, const string meta)
   {
      if(CheckPointer(m_auth_socket) == POINTER_INVALID) return false;
      string response[];
      ArrayResize(response, 6);
      response[0] = v;
      response[1] = id;
      response[2] = code;
      response[3] = text;
      response[4] = user;
      response[5] = meta;
      return m_auth_socket.sendMultipart(response);
   }
};

const string CZmqZapHandler::ZAP_HANDLER_ADDRESS = "inproc://zeromq.zap.01";
const int    CZmqZapHandler::RECV_TIMEOUT_MS = 250;
const string CZmqZapHandler::ZAP_VERSION = "1.0";

#endif // MQL_ZMQ_AUTH_MQH