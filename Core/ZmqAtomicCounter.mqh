//+------------------------------------------------------------------+
//|   Core/ZmqAtomicCounter.mqh                                      |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_ATOMICCOUNTER_MQH
#define MQL_ZMQ_ATOMICCOUNTER_MQH

#property strict

// Retaining include for project structure consistency
#include "../Lang/Native.mqh"

// --- DLL Imports for ZMQ Atomic Counter Functions ---
// MQL5 uses 'long' to hold 64-bit pointers/handles from DLLs.
#import "libzmq.dll"
long zmq_atomic_counter_new();
void zmq_atomic_counter_set(long counter, int value);
int  zmq_atomic_counter_inc(long counter);
int  zmq_atomic_counter_dec(long counter);
int  zmq_atomic_counter_value(long counter);
void zmq_atomic_counter_destroy(long &counter_p);
#import

//+------------------------------------------------------------------+
//| ZmqAtomicCounter: A simple, robust, and efficient RAII wrapper   |
//| for ZMQ's atomic counter. It ensures that the counter's          |
//| resources are automatically created and destroyed.               |
//+------------------------------------------------------------------+
class ZmqAtomicCounter
{
private:
   long              m_counter_ref; // Handle to the native ZMQ atomic counter object. Use 'long' for 64-bit handles.

public:
   //--- Constructor: Creates a new atomic counter instance.
   ZmqAtomicCounter() : m_counter_ref(zmq_atomic_counter_new())
   {
   }

   //--- Destructor: Destroys the atomic counter, releasing its resources.
   ~ZmqAtomicCounter()
   {
      // The zmq_atomic_counter_destroy function expects a reference
      // to the handle, which it will nullify after destruction.
      if(m_counter_ref != 0)
      {
         zmq_atomic_counter_destroy(m_counter_ref);
      }
   }

   //--- Atomically increments the counter and returns the new value.
   int increment()
   {
      if(m_counter_ref == 0) return 0; // Or some error indicator
      return zmq_atomic_counter_inc(m_counter_ref);
   }

   //--- Atomically decrements the counter and returns the new value.
   int decrement()
   {
      if(m_counter_ref == 0) return 0; // Or some error indicator
      return zmq_atomic_counter_dec(m_counter_ref);
   }

   //--- Returns the current value of the counter.
   int getValue() const
   {
      if(m_counter_ref == 0) return 0; // Or some error indicator
      return zmq_atomic_counter_value(m_counter_ref);
   }

   //--- Sets the counter to a specific value.
   void setValue(int value)
   {
      if(m_counter_ref != 0)
      {
         zmq_atomic_counter_set(m_counter_ref, value);
      }
   }

   //--- Checks if the counter handle is valid.
   bool isValid() const
   {
      return m_counter_ref != 0;
   }
};

#endif // MQL_ZMQ_ATOMICCOUNTER_MQH
//+------------------------------------------------------------------+
