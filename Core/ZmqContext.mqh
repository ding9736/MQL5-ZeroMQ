//+------------------------------------------------------------------+
//|   Core/ZmqContext.mqh                                            |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_CONTEXT_MQH
#define MQL_ZMQ_CONTEXT_MQH


#include "../Lang/MqlIPC.mqh"
#include "../Common/Constants.mqh"

// --- DLL Imports for ZMQ Context Functions ---
#import "libzmq.dll"
long zmq_ctx_new();
int  zmq_ctx_term(long context);
int  zmq_ctx_shutdown(long context);
int  zmq_ctx_set(long context, int option, int optval);
int  zmq_ctx_get(const long context, int option);
#import

//+------------------------------------------------------------------+
//| Manages the lifecycle of a raw ZMQ context handle. This class    |
//| is used internally by the GlobalHandle template to ensure that   |
//| the shared context is properly created and destroyed.            |
//+------------------------------------------------------------------+
class ZmqContextHandleManager : public HandleManager<long>
{
protected:
   //--- Creates a new ZMQ context handle
   virtual long create() override
   {
      return zmq_ctx_new();
   }

   //--- Destroys the ZMQ context handle
   virtual void destroy(long handle) override
   {
      if(handle != 0)
      {
         zmq_ctx_term(handle);
      }
   }
};

//+------------------------------------------------------------------+
//| An object-oriented, reference-counted wrapper for a ZMQ context. |
//| Inherits its shared handle logic from GlobalHandle.              |
//+------------------------------------------------------------------+
class ZmqContext : public GlobalHandle<long, ZmqContextHandleManager>
{
private:
   //--- Helper to get an integer context option using the enum
   int getOption(const ENUM_ZMQ_CONTEXT_OPTION option) const
   {
      if(m_ref == 0) return -1;
      return zmq_ctx_get(m_ref, (int)option);
   }

   //--- Helper to set an integer context option using the enum
   bool setOption(const ENUM_ZMQ_CONTEXT_OPTION option, const int value)
   {
      if(m_ref == 0) return false;
      return (zmq_ctx_set(m_ref, (int)option, value) == 0);
   }

public:
   //--- Constructor: Manages the shared global handle.
   ZmqContext(const string shared_name = "mql-zmq::global::context")
      : GlobalHandle<long, ZmqContextHandleManager>(shared_name)
   {
   }

   //--- Checks if the context was successfully initialized.
   bool isValid() const
   {
      return (ref() != 0);
   }

   //--- Gracefully shuts down the context (non-blocking).
   bool shutdown()
   {
      if(!isValid()) return false;
      return (zmq_ctx_shutdown(m_ref) == 0);
   }

   //--- Context-level options ---
   int  getIoThreads() const
   {
      return getOption(ZMQ_OPT_IO_THREADS);
   }
   bool setIoThreads(const int value)
   {
      return setOption(ZMQ_OPT_IO_THREADS, value);
   }

   int  getMaxSockets() const
   {
      return getOption(ZMQ_OPT_MAX_SOCKETS);
   }
   bool setMaxSockets(const int value)
   {
      return setOption(ZMQ_OPT_MAX_SOCKETS, value);
   }

   long getMaxMessageSize() const
   {
      return (long)getOption(ZMQ_OPT_MAX_MSGSZ);
   }

   int  getSocketLimit() const
   {
      return getOption(ZMQ_OPT_SOCKET_LIMIT);
   }
};

#endif // MQL_ZMQ_CONTEXT_MQH
//+------------------------------------------------------------------+
