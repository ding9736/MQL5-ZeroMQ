//+------------------------------------------------------------------+
//| Module:      Lang/Native.mqh                                     |
//+------------------------------------------------------------------+

#ifndef MQL_LANG_NATIVE_MQH
#define MQL_LANG_NATIVE_MQH
#import "libzmq.dll"
#import "kernel32.dll"
int native_zmq_errno();
// Copies a block of memory from a C-pointer to an MQL array.
void RtlMoveMemory(uchar &dst[], long src_ptr, ulong length);

// Copies a block of memory from an MQL array to a C-pointer.
void RtlMoveMemory(long dst_ptr, const uchar &src[], ulong length);

// Determines the length of a null-terminated single-byte string.
int  lstrlenA(long c_string_ptr);
#import

//+------------------------------------------------------------------+
string StringFromUtf8Pointer(const long psz, int len = -1)
{
   if(psz == 0)
      return "";
// If length is not provided, determine it using the Windows API.
   if(len < 0)
      len = lstrlenA(psz);
   if(len <= 0)
      return "";
// 1. Create a byte buffer in MQL.
   uchar utf8_bytes[];
   ArrayResize(utf8_bytes, len);
// 2. Copy the raw string data from the C pointer into our buffer.
   RtlMoveMemory(utf8_bytes, psz, (ulong)len);
// 3. Use MQL's built-in function to convert the UTF-8 byte array to an MQL string.
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
// Use a union for clean and efficient type punning.
   union PtrConverter
   {
      uchar bytes[sizeof(long)];
      long  value;
   };
   PtrConverter converter;
// Copy bytes from the target memory location directly into the union's byte array.
   RtlMoveMemory(converter.bytes, address_of_pointer, (ulong)sizeof(long));
// Return the reinterpreted value.
   return converter.value;
}


#endif // MQL_LANG_NATIVE_MQH
//+------------------------------------------------------------------+
