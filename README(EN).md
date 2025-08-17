# MQL5-ZeroMQ: Industrial-Grade High-Performance Asynchronous Messaging Library

**MQL5-ZeroMQ** is an industrial-grade, highly optimized ZeroMQ binding for the MQL5 environment. By providing a thin wrapper that directly calls the native `libzmq.dll`, it brings unparalleled asynchronous communication performance to your EAs, indicators, and scripts.

The core design philosophy of this project is **performance-first, MQL5-native, and minimal-dependency**. Whether you need to build complex cross-platform trading systems, conduct low-latency IPC between multiple EAs, or simply receive signals from an external Python script, this library offers the most robust and efficient solution available.

## Core Features

*   **🚀 Peak Performance**: Utilizes a direct native DLL binding architecture, eliminating any unnecessary intermediate layers (like C++/CLI wrappers). This ensures the lowest possible call latency and the highest throughput. The core `ZmqMsg` object is optimized for zero-allocation message receiving in high-frequency scenarios.

*   **🔗 Native MQL5 Experience**: Features an exclusive **cross-program shared `ZmqContext` mechanism** built on MQL5's global variables. Without any configuration, all EAs/indicators running within the same terminal will automatically share a single ZeroMQ context, saving significant system resources and adhering to official ZeroMQ best practices.

*   **🧩 Minimal Dependencies**: **Zero compilation required**. All you need is the `libzmq.dll` file and the `.mqh` header files from this project. No extra wrapper DLLs, no complex build environments—just true "plug and play."

*   **🛡️ Production-Grade Robustness**:
    *   **Full Feature Set**: Complete support for core patterns like REQ/REP, PUB/SUB, PUSH/PULL, as well as advanced patterns like ROUTER/DEALER.
    *   **Enterprise-Grade Security**: Built-in CurveZMQ support allows for state-of-the-art, end-to-end encryption with just a few lines of code.
    *   **`#property strict` Compatible**: The codebase has been meticulously refined to eliminate all compiler warnings, ensuring the highest code quality.
    *   **Comprehensive Socket Options**: Nearly all `zmq_setsockopt` options are exposed through clean, easy-to-use APIs for fine-grained control.

*   **📖 IDE-Embedded Documentation**: No need to leave MetaEditor! The main header file, `ZeroMQ.mqh`, contains an exhaustive **Developer's Manual** covering everything from a quick start guide and core concepts to advanced features and an FAQ.

## Quick Start

#### Step 1: Environment Setup
1.  Based on whether your MetaTrader 5 terminal is 32-bit or 64-bit, copy the corresponding `libzmq.dll` file to the `MQL5\Libraries` directory.
2.  Ensure DLL imports are enabled at the top of your EA or indicator code:
    
    #property script_show_inputs // or expert_show_inputs
    #property strict
    #import "libzmq.dll"
    #import
    
3.  In your EA's "Properties" -> "Common" tab, check the box for **"Allow DLL imports"**.

#### Step 2: Include the Header

#include <Lib/ZeroMQ/ZeroMQ.mqh>


#### Step 3: Write Your Code (Request/Reply Example)

**Client (REQ - Sends a request):**
// MyReqClient.mq5
#include <Lib/ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
   ZmqContext context;
   ZmqSocket requester(context, ZMQ_SOCKET_REQ);
   if (!requester.connect("tcp://localhost:5555"))
   {
      Print("Connection failed!");
      return;
   }
   
   string request = "Hello";
   Print("Client sending: ", request);
   requester.send(request);
   
   ZmqMsg reply;
   // IMPORTANT: Set a 2-second timeout to prevent the EA from freezing indefinitely
   requester.setReceiveTimeout(2000); 
   if (requester.recv(reply))
   {
      Print("Client received: ", reply.getData());
   }
   else
   {
      Print("Receive timeout expired!");
   }
}


**Server (REP - Receives and replies):**

// MyRepServer.mq5
#include <Lib/ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
   ZmqContext context;
   ZmqSocket replier(context, ZMQ_SOCKET_REP);
   if (!replier.bind("tcp://*:5555"))
   {
      Print("Bind failed!");
      return;
   }
   
   Print("Server started, waiting for requests...");
   
   // Performance Best Practice: Declare the ZmqMsg object outside the loop for reuse
   ZmqMsg request;
   
   while(!IsStopped())
   {
      // Use non-blocking receive to avoid getting stuck when no requests are present
      if (replier.recv(request, ZMQ_FLAG_DONTWAIT))
      {
         Print("Server received: ", request.getData());
         replier.send("World");
      }
      Sleep(10); // With non-blocking calls, Sleep is essential to prevent a tight loop
   }
}


## Why Choose This Library? (Comparison with `dingmaotu/mql-zmq`)

While `dingmaotu/mql-zmq` is an excellent open-source project, this library differs in key architectural decisions, giving it an edge in specific scenarios:

1.  **Architectural Advantage -> Ultimate Performance**: This library uses a **direct call** architecture (`MQL5 -> libzmq.dll`), whereas `dingmaotu/mql-zmq` uses a **C++/CLI Wrapper** (`MQL5 -> Wrapper.dll -> libzmq.dll`). For financial applications where lowest latency is paramount, our "closer-to-the-metal" architecture provides the theoretical maximum performance.
2.  **Dependency Advantage -> Simplified Deployment**: This library requires only `libzmq.dll`. `dingmaotu/mql-zmq` requires two DLLs, and any modification to its wrapper DLL needs a C++ build environment. Our library is friendlier for end-users.
3.  **MQL5-Native Advantage -> Intelligent Resource Management**: The unique **automatic shared `ZmqContext`** feature is a deep optimization specifically designed for the MQL5 platform's multi-EA environment, a feature not present in generic wrappers.

## Documentation

**The best documentation is in the code!** Simply open `Lib/ZeroMQ/ZeroMQ.mqh` in MetaEditor. The comment block at the top is a comprehensive **Developer's Manual** covering all core concepts, API usage, advanced features, and an FAQ.

## API Highlights

*   `ZmqContext`: The intelligent manager for the ZeroMQ context. You typically just need to declare `ZmqContext context;` once.
*   `ZmqSocket`: The ZeroMQ socket, providing methods for `bind`, `connect`, `send`, `recv`, `poll`, and all socket options.
*   `ZmqMsg`: The highly efficient message object, which should be reused in high-frequency scenarios.
*   `ZmqZ85Codec`: A utility for generating and handling keys for Curve security.

## License

This project is licensed under the [MIT License](LICENSE).