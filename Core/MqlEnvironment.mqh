//+------------------------------------------------------------------+
//|  Core/MqlEnvironment.mqh                                         |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_ENVIRONMENT
#define MQL_ZMQ_ENVIRONMENT
#property strict

#include "Error.mqh"

class MqlEnvironment
{
public:
   static int    GetLastError()
   {
      return ::GetLastError();
   }

   static string GetErrorDescription(int error_code)
   {
      return MqlErrors::GetDescription(error_code);
   }

   static ENUM_PROGRAM_TYPE GetProgramType()
   {
      return (ENUM_PROGRAM_TYPE)MQLInfoInteger(MQL_PROGRAM_TYPE);
   }

   static string            GetProgramName()
   {
      return MQLInfoString(MQL_PROGRAM_NAME);
   }

   static string            GetProgramPath()
   {
      return MQLInfoString(MQL_PROGRAM_PATH);
   }

   static int               GetCodePage()
   {
      return MQLInfoInteger(MQL_CODEPAGE);
   }

   static string GetProgramTypeString()
   {
      switch(GetProgramType())
      {
      case PROGRAM_EXPERT:
         return "Expert Advisor";
      case PROGRAM_INDICATOR:
         return "Indicator";
      case PROGRAM_SCRIPT:
         return "Script";
      default:
         return "Unknown";
      }
   }

   static bool IsScript()
   {
      return GetProgramType() == PROGRAM_SCRIPT;
   }

   static bool IsExpert()
   {
      return GetProgramType() == PROGRAM_EXPERT;
   }

   static bool IsIndicator()
   {
      return GetProgramType() == PROGRAM_INDICATOR;
   }

   static bool IsDebug()
   {
      return (bool)MQLInfoInteger(MQL_DEBUG);
   }

   static bool IsTesting()
   {
      return (bool)MQLInfoInteger(MQL_TESTER);
   }

   static bool IsOptimizing()
   {
      return (bool)MQLInfoInteger(MQL_OPTIMIZATION);
   }
 
   static bool IsVisual()
   {
      return (bool)MQLInfoInteger(MQL_VISUAL_MODE);
   }

   static bool IsStopped()
   {
      return ::IsStopped();
   }

   static bool IsDllsAllowed()
   {
      return (bool)MQLInfoInteger(MQL_DLLS_ALLOWED);
   }

   static bool IsTradeAllowed()
   {
      return (bool)MQLInfoInteger(MQL_TRADE_ALLOWED);
   }

   static bool IsSignalsAllowed()
   {
      return (bool)MQLInfoInteger(MQL_SIGNALS_ALLOWED);
   }

   static ENUM_LICENSE_TYPE GetLicenseType()
   {
      return (ENUM_LICENSE_TYPE)MQLInfoInteger(MQL_LICENSE_TYPE);
   }

   static string GetLicenseTypeString()
   {
      switch(GetLicenseType())
      {
      case LICENSE_DEMO:
         return "Demo";
      case LICENSE_FULL:
         return "Full";
      case LICENSE_TIME:
         return "Time-Limited";
      default:
         return "Unknown";
      }
   }
};

#define ObjectAttr(Type, Private, Public)       \
public:                                         \
   Type Get##Public() const { return Private; } \
   void Set##Public(Type value) { Private = value; } \
private:                                        \
   Type Private

#define ObjectAttrRead(Type, Private, Public)   \
public:                                         \
   Type Get##Public() const { return Private; } \
private:                                        \
   Type Private

#ifdef _DEBUG
#define Debug(msg) PrintFormat("DEBUG | %s:%d | %s() | %s", __FILE__, __LINE__, __FUNCTION__, (string)msg)
#else
#define Debug(msg)
#endif


#endif // MQL_ZMQ_ENVIRONMENT

