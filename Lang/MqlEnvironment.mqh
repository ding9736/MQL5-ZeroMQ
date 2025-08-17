//+------------------------------------------------------------------+
//| Module:      Lang/MqlEnvironment.mqh                             |
//| Description: Provides a static utility class `MqlEnvironment`    |
//|              that offers a clean, robust, and extended interface |
//|              for querying the MQL5 program environment state.    |
//+------------------------------------------------------------------+
#ifndef MQL_LANG_MQL_ENVIRONMENT_MQH
#define MQL_LANG_MQL_ENVIRONMENT_MQH

#property strict

#include "Error.mqh"

//+------------------------------------------------------------------+
//| MqlEnvironment: A static class for accessing MQL environment info|
//+------------------------------------------------------------------+
class MqlEnvironment
{
public:
   // --- Error Handling ---
   static int    GetLastError()
   {
      return ::GetLastError();
   }
   static string GetErrorDescription(int error_code)
   {
      return MqlErrors::GetDescription(error_code);
   }

   // --- Program Information ---
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

   // --- Enhanced Program Information (Enum to String) ---

   // @brief  Returns the program type as a human-readable string.
   // @return e.g., "Expert Advisor", "Script", "Indicator", or "Unknown".
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

   // --- Execution Environment Checks ---
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

   // --- Permissions & License ---
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

   // --- Enhanced License Information (Enum to String) ---

   // @brief  Returns the license type as a human-readable string.
   // @return e.g., "Demo", "Full", "Time-Limited", or "Unknown".
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
      // CORRECTED: LICENSE_SUBSCRIPTION does not exist in ENUM_LICENSE_TYPE.
      default:
         return "Unknown";
      }
   }
};


//+------------------------------------------------------------------+
//| General-Purpose Helper Macros                                    |
//| These are separated from the MqlEnvironment class to maintain    |
//| its single responsibility of querying the MQL environment.       |
//+------------------------------------------------------------------+

// @brief Macro for generating boilerplate property accessors (get/set).
// @example ObjectAttr(string, m_name, Name) creates GetName() and SetName(string value).
#define ObjectAttr(Type, Private, Public)       \
public:                                         \
   Type Get##Public() const { return Private; } \
   void Set##Public(Type value) { Private = value; } \
private:                                        \
   Type Private

// @brief Macro for generating read-only property accessors (get only).
#define ObjectAttrRead(Type, Private, Public)   \
public:                                         \
   Type Get##Public() const { return Private; } \
private:                                        \
   Type Private

// @brief Debug logging macro. It automatically includes file, line, and function
//        information. The code is only compiled in debug builds (_DEBUG is defined).
#ifdef _DEBUG
#define Debug(msg) PrintFormat("DEBUG | %s:%d | %s() | %s", __FILE__, __LINE__, __FUNCTION__, (string)msg)
#else
#define Debug(msg)
#endif


#endif // MQL_LANG_MQL_ENVIRONMENT_MQH
//+------------------------------------------------------------------+
