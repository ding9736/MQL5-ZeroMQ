//+------------------------------------------------------------------+
//|   Lang/Native.mqh                                                |
//+------------------------------------------------------------------+

#ifndef MQL_LANG_NATIVE_MQH
#define MQL_LANG_NATIVE_MQH
#import "libzmq.dll"
#import "kernel32.dll"
int native_zmq_errno();
void RtlMoveMemory(uchar &dst[], long src_ptr, ulong length);
void RtlMoveMemory(long dst_ptr, const uchar &src[], ulong length);
int  lstrlenA(long c_string_ptr);
#import

//+------------------------------------------------------------------+
string StringFromUtf8Pointer(const long psz, int len = -1)
{
   if(psz == 0)
      return "";
   if(len < 0)
      len = lstrlenA(psz);
   if(len <= 0)
      return "";
   uchar utf8_bytes[];
   ArrayResize(utf8_bytes, len);
   RtlMoveMemory(utf8_bytes, psz, (ulong)len);
   return CharArrayToString(utf8_bytes, 0, WHOLE_ARRAY, CP_UTF8);
}

//+------------------------------------------------------------------+
string StringFromUtf8(const uchar &utf8_bytes[])
{
   return CharArrayToString(utf8_bytes, 0, WHOLE_ARRAY, CP_UTF8);
}

//+------------------------------------------------------------------+
void StringToUtf8(const string str, uchar &utf8_bytes[], const bool add_null_terminator = true)
{
   const int count = add_null_terminator ? -1 : StringLen(str);
   StringToCharArray(str, utf8_bytes, 0, count, CP_UTF8);
}

//+------------------------------------------------------------------+
long DereferencePointer(const long address_of_pointer)
{
   if(address_of_pointer == 0)
      return 0;
   union PtrConverter
   {
      uchar bytes[sizeof(long)];
      long  value;
   };
   PtrConverter converter;
   RtlMoveMemory(converter.bytes, address_of_pointer, (ulong)sizeof(long));
   return converter.value;
}


#endif // MQL_LANG_NATIVE_MQH
//+------------------------------------------------------------------+
