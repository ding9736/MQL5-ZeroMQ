//+------------------------------------------------------------------+
//|    Core/Diagnostics.mqh                                          |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_DIAGNOSTICS
#define MQL_ZMQ_DIAGNOSTICS
#property strict

//#define ZMQ_DEBUG_MODE
#ifdef ZMQ_DEBUG_MODE
   #define ZMQ_LOG_DEBUG(message) PrintFormat("[ZMQ-Debug] in %s:%d | %s", __FILE__, __LINE__, message)
#else

   #define ZMQ_LOG_DEBUG(message)
#endif

#define ZMQ_LOG_ERROR(message) PrintFormat("[ZMQ-ERROR] in %s:%d | %s", __FILE__, __LINE__, message)

#endif // MQL_ZMQ_DIAGNOSTICS