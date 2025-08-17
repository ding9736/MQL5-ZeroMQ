//+--------------------------------------------------------------------+
//| Module:      Lang/MqlIPC.mqh                                       |
//| Description: Provides classes for Inter-Process Communication (IPC)|
//|              and synchronization using MQL5 Global Variables.      |
//|              Includes synchronization primitives like critical     |
//|              sections and a powerful reference-counted shared      |
//|              handle mechanism (`GlobalHandle`).                    |
//+--------------------------------------------------------------------+
#ifndef MQL_LANG_IPC_MQH
#define MQL_LANG_IPC_MQH

#property strict

//+------------------------------------------------------------------+
//| GlobalVariable: A static wrapper for MQL5's global var functions.|
//+------------------------------------------------------------------+
class GlobalVariable
{
public:
   static int        total()
   {
      return GlobalVariablesTotal();
   }
   static string     name(int index)
   {
      return GlobalVariableName(index);
   }
   static void       flush()
   {
      GlobalVariablesFlush();
   }

   static bool       exists(string name)
   {
      return GlobalVariableCheck(name);
   }
   static datetime   lastAccess(string name)
   {
      return GlobalVariableTime(name);
   }

   static bool       makeTemp(string name)
   {
      return GlobalVariableTemp(name);
   }
   static double     get(string name)
   {
      return GlobalVariableGet(name);
   }
   static bool       get(string name,double &value)
   {
      return (bool)GlobalVariableGet(name,value);
   }
   static bool       set(string name,double value)
   {
      return (bool)GlobalVariableSet(name,value);
   }
   static bool       setOn(string name,double value,double check)
   {
      return GlobalVariableSetOnCondition(name,value,check);
   }

   static bool       remove(string name)
   {
      return (bool)GlobalVariableDel(name);
   }
   static bool       removeAll(string prefix=NULL,datetime before=0)
   {
      return (bool)GlobalVariablesDeleteAll(prefix,before);
   }
};

//+------------------------------------------------------------------+
//| TempVar: RAII wrapper for a temporary global variable.           |
//| Automatically deletes the variable upon destruction.             |
//+------------------------------------------------------------------+
class TempVar
{
private:
   string            m_name;
   bool              m_owned;
public:
   TempVar(string name,bool create=false):m_name(name),m_owned(create)
   {
      if(create)
      {
         GlobalVariable::makeTemp(name);
      }
   }
   ~TempVar()
   {
      if(m_owned && isValid())
      {
         GlobalVariable::remove(m_name);
      }
   }

   bool              isValid() const
   {
      return GlobalVariable::exists(m_name);
   }
   string            getName() const
   {
      return m_name;
   }
   bool              set(double value)
   {
      return GlobalVariable::set(m_name,value);
   }
   double            get() const
   {
      return GlobalVariable::get(m_name);
   }
   bool              setOn(double value,double check)
   {
      return GlobalVariable::setOn(m_name,value,check);
   }
   datetime          lastAccess() const
   {
      return GlobalVariable::lastAccess(m_name);
   }
};

//+------------------------------------------------------------------+
//| GlobalSpinCounter: A counter based on a Global Variable.         |
//| @warning This class uses a spin-lock on MQL Global Variables     |
//| (which involves file I/O) and is NOT high-performance.           |
//| It can cause high CPU usage under contention. Use only for       |
//| low-frequency, inter-program coordination, not for high-speed    |
//| counting or frequent locking.                                    |
//+------------------------------------------------------------------+
class GlobalSpinCounter: public TempVar
{
public:
   GlobalSpinCounter(string name,long initial,bool create=false):TempVar(name,create)
   {
      set(initial);
   }
   long              increment(long by=1);
   long              decrement(long by=1)
   {
      return increment(-by);
   }
};
//+------------------------------------------------------------------+
long GlobalSpinCounter::increment(long by)
{
   bool success=false;
   long value;
   do
   {
      value=(long)get();
      success=setOn(value+by,value);
   }
   while(!success && !IsStopped());
   return (value+by);
}

//+------------------------------------------------------------------+
//| GlobalSpinSemaphore: A semaphore implementation using a Global Var.|
//| @warning Like GlobalSpinCounter, this class uses a spin-lock     |
//| via file I/O and is NOT suitable for high-frequency or           |
//| performance-critical locking. High contention will lead to       |
//| significant CPU load. Use sparingly for coarse-grained           |
//| inter-program synchronization.                                   |
//+------------------------------------------------------------------+
class GlobalSpinSemaphore
{
private:
   TempVar           m_var;
public:
   GlobalSpinSemaphore(string name,long initial=0);
   bool              isValid() const
   {
      return m_var.isValid();
   }
   bool              acquire();
   void              release();
};
//+------------------------------------------------------------------+
GlobalSpinSemaphore::GlobalSpinSemaphore(string name,long initial)
   :m_var(name,initial!=0)
{
   if(initial!=0)
   {
      m_var.set(initial);
   }
}
//+------------------------------------------------------------------+
bool GlobalSpinSemaphore::acquire(void)
{
   bool success=false;
   do
   {
      long value=(long)m_var.get();
      if(value == 0)
         return false;
      success=m_var.setOn(value-1,value);
   }
   while(!success && !IsStopped());
   return success;
}
//+------------------------------------------------------------------+
void GlobalSpinSemaphore::release(void)
{
   bool success=false;
   do
   {
      long value=(long)m_var.get();
      success=m_var.setOn(value+1,value);
   }
   while(!success && !IsStopped());
}

//+------------------------------------------------------------------+
//| CriticalSection: A mutual exclusion lock. More efficient than    |
//| a semaphore for simple locking as it uses a "sleep-wait" loop.   |
//+------------------------------------------------------------------+
class CriticalSection
{
private:
   const string      m_name;
public:
   CriticalSection(string name):m_name(name) {}

   bool              isValid() const
   {
      return m_name!=NULL;
   }
   string            getName() const
   {
      return m_name;
   }

   void              enter()
   {
      GlobalVariable::remove(m_name);
      while(!GlobalVariable::makeTemp(m_name) && !IsStopped())
         Sleep(100); // Sleep-wait is less CPU intensive than a spin-lock.
   }
   bool              tryEnter()
   {
      return GlobalVariable::makeTemp(m_name);
   }
   void              leave()
   {
      GlobalVariable::remove(m_name);
   }
};

//+------------------------------------------------------------------+
//| HandleManager: Interface for custom handle creation/destruction. |
//+------------------------------------------------------------------+
template<typename T>
interface HandleManager
{
   T         create();
   void      destroy(T);
};

//+------------------------------------------------------------------+
//| GlobalHandle: A reference-counted, globally shared handle/pointer. |
//| This is the cornerstone for sharing resources like a ZmqContext   |
//| across multiple EAs/scripts in the same terminal instance.       |
//+------------------------------------------------------------------+
template<typename T,typename HM>
class GlobalHandle
{
private:
   CriticalSection   m_cs;
   string            m_refName;
   string            m_counterName;
protected:
   T                 m_ref;
   HandleManager<T>  *m_hm;
public:
   GlobalHandle(string sharedKey=NULL):m_cs(sharedKey)
   {
      m_refName=m_cs.getName()+"_Ref";
      m_counterName=m_cs.getName()+"_Count";
      m_hm = new HM;
      if(!m_cs.isValid())
         m_ref = m_hm.create();
      else
      {
         m_cs.enter();
         if(!GlobalVariable::exists(m_counterName))
         {
            GlobalVariable::makeTemp(m_counterName);
            GlobalVariable::set(m_counterName,0);
         }
         if(long(GlobalVariable::get(m_counterName))==0)
         {
            m_ref = m_hm.create();
            if(!GlobalVariable::exists(m_refName))
            {
               GlobalVariable::makeTemp(m_refName);
               GlobalVariable::set(m_refName,m_ref);
            }
         }
         else
         {
            m_ref=(T)(GlobalVariable::get(m_refName));
         }
         GlobalVariable::set(m_counterName,GlobalVariable::get(m_counterName)+1);
         m_cs.leave();
      }
   }
   ~GlobalHandle()
   {
      if(!m_cs.isValid())
      {
         m_hm.destroy(m_ref);
      }
      else
      {
         m_cs.enter();
         GlobalVariable::set(m_counterName,GlobalVariable::get(m_counterName)-1);
         if(long(GlobalVariable::get(m_counterName))==0)
         {
            m_hm.destroy(m_ref);
            GlobalVariable::remove(m_refName);
            GlobalVariable::remove(m_counterName);
         }
         m_cs.leave();
      }
      delete m_hm;
   }

   T                 ref() const
   {
      return m_ref;
   }
};

#endif // MQL_LANG_IPC_MQH
//+------------------------------------------------------------------+