//+------------------------------------------------------------------+
//|   Core/ZmqContext.mqh                                            |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_CONTEXT_MQH
#define MQL_ZMQ_CONTEXT_MQH

#include "../Lang/MqlIPC.mqh"
#include "../Common/Constants.mqh"

#import "libzmq.dll"
long zmq_ctx_new();                                      // Creates a new ZeroMQ context.
int  zmq_ctx_term(long context);                         // Terminates a ZeroMQ context.
int  zmq_ctx_shutdown(long context);                     // Forces shutdown of a context (for hung applications).
int  zmq_ctx_set(long context, int option, int optval);  // Sets a context option.
int  zmq_ctx_get(const long context, int option);        // Gets a context option.
#import


class ZmqContextHandleManager : public HandleManager<long>
{
public: 
  
   virtual long create() override
   {
      return zmq_ctx_new();
   }

   virtual void destroy(long handle) override
   {
      if(handle != 0)
      {
         zmq_ctx_term(handle); 
      }
   }
};

class ZmqContext : public GlobalHandle<long, ZmqContextHandleManager>
{
private:
   int getOption(const ENUM_ZMQ_CONTEXT_OPTION option) const
   {
      if(m_ref == 0) return -1; 
      return zmq_ctx_get(m_ref, (int)option);
   }


   bool setOption(const ENUM_ZMQ_CONTEXT_OPTION option, const int value)
   {
      if(m_ref == 0) return false; 
      return (zmq_ctx_set(m_ref, (int)option, value) == 0);
   }

public:

   ZmqContext(const string shared_name = "mql-zmq::global::context")
      : GlobalHandle<long, ZmqContextHandleManager>(shared_name)
   {
   }

   bool isValid() const
   {
      return (ref() != 0);
   }

   bool shutdown()
   {
      if(!isValid()) return false;
      return (zmq_ctx_shutdown(m_ref) == 0);
   }

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
