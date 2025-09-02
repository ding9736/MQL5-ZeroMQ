//+------------------------------------------------------------------+
//|   Core/ZmqAtomicCounter.mqh                                      |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_ATOMICCOUNTER
#define MQL_ZMQ_ATOMICCOUNTER
#property strict

#include "Native.mqh"
#import "libzmq.dll"
long zmq_atomic_counter_new();                          // Creates a new atomic counter instance.
void zmq_atomic_counter_set(long counter, int value);   // Sets the counter's value.
int  zmq_atomic_counter_inc(long counter);              // Atomically increments and returns new value.
int  zmq_atomic_counter_dec(long counter);              // Atomically decrements and returns new value.
int  zmq_atomic_counter_value(long counter);            // Gets the current value of the counter.
void zmq_atomic_counter_destroy(long &counter_p);       // Destroys the atomic counter instance.
#import

//
class ZmqAtomicCounter
{
private:
   long              m_counter_ref;

public:
   ZmqAtomicCounter() : m_counter_ref(zmq_atomic_counter_new())
   {
   }
   ~ZmqAtomicCounter()
   {
      if(m_counter_ref != 0)
      {
         zmq_atomic_counter_destroy(m_counter_ref);
         m_counter_ref = 0;
      }
   }

   int increment()
   {
      if(m_counter_ref == 0) return 0;
      return zmq_atomic_counter_inc(m_counter_ref);
   }


   int decrement()
   {
      if(m_counter_ref == 0) return 0;
      return zmq_atomic_counter_dec(m_counter_ref);
   }


   int getValue() const
   {
      if(m_counter_ref == 0) return 0;
      return zmq_atomic_counter_value(m_counter_ref);
   }

   void setValue(int value)
   {
      if(m_counter_ref != 0)
      {
         zmq_atomic_counter_set(m_counter_ref, value);
      }
   }

   bool isValid() const
   {
      return m_counter_ref != 0;
   }
};

#endif // MQL_ZMQ_ATOMICCOUNTER

