<div align="center">

# MQL5-ZeroMQ

### An Industrial-Grade, High-Performance MQL5 Message Queue Library

</div>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-2.5.9-blue.svg">
  <img alt="Platform" src="https://img.shields.io/badge/platform-MetaTrader%205-orange.svg">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

---

**MQL5-ZeroMQ** is a feature-complete, high-performance message queue library tailored for MetaTrader 5 (MQL5). It seamlessly integrates the power of the world-renowned ZeroMQ (ØMQ, ZMQ) into the MQL5 environment, providing developers with "sockets on steroids"—intelligent message pipelines with built-in concurrency patterns that go beyond traditional TCP/UDP.

Whether you need **low-latency, high-throughput** inter-process communication (IPC) between multiple EAs/indicators, want to build complex distributed computing systems (e.g., offloading computationally intensive tasks to external Python/C++ applications), or require real-time, reliable data exchange with external data sources, MQL5-ZeroMQ is your ultimate solution.

---

## 📚 Table of Contents

- [✨ Core Features](#-core-features)
- [🚀 Performance Highlight: The Unmatched Advantage of `uchar[]`](#-performance-highlight-the-unmatched-advantage-of-uchar)
- [🛠️ Installation & Configuration](#️-installation--configuration)
- [💡 Definitive API Guide & Examples](#-definitive-api-guide--examples)
  - [Request-Reply (REQ/REP)](#part-1-request-reply-reqrep)
  - [Publish-Subscribe (PUB/SUB)](#part-2-publish-subscribe-pubsub)
  - [High-Performance `uchar[]` Struct Transfer](#part-3-high-performance-uchar-struct-transfer)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Core Features

- ⚡️ **Extreme Performance**:
  
  - **Microsecond-Level Latency**: In `inproc` communication, a full request-reply round-trip latency is as low as **~6.18 microseconds**, approaching native function call speed.
  - **Ultra-High Throughput**: Stress tests show that using zero-overhead byte arrays (`uchar[]`) can boost throughput to **50,000+ messages/second**, demonstrating its exceptional capability in data-intensive applications.

- 📡 **Classic Concurrency Messaging Patterns**:
  
  - **Request-Reply (REQ/REP)**: For building robust client-server communication with automatic handling of the strict request-and-reply sequence.
  - **Publish-Subscribe (PUB/SUB)**: Implements one-to-many data distribution, ideal for broadcasting market data and trading signals.
  - **Pipeline/Task Distribution (PUSH/PULL)**: For parallel task distribution among multiple worker units, enabling automatic load balancing.
  - **More Advanced Patterns**: Also supports PAIR, ROUTER, DEALER, XPUB/XSUB, etc., to meet complex routing and asynchronous communication needs.

- 🛡️ **Industrial-Grade Security (Out-of-the-Box)**:
  
  - Built-in powerful **CurveZMQ** encryption protocol. This library **already includes `libsodium.dll`**, allowing you to add enterprise-grade end-to-end encryption to your TCP communications with just a few lines of code, ensuring data security.

- ⚙️ **Advanced Features & Robustness**:
  
  - **Asynchronous I/O (`ZmqPoller`)**: Gracefully manage and listen to multiple socket events simultaneously without complex multi-threaded programming.
  - **Flow Control (HWM)**: Built-in High-Water Mark mechanism automatically handles network back-pressure, preventing memory exhaustion from message backlogs.
  - **Multipart Messages**: Atomically split a single message into multiple frames for transmission, a powerful tool for building protocols and transferring complex data.
  - **Fully Tested**: The entire library is validated by a rigorous test suite with over 80 assertions, covering core functions, advanced features, performance, and error handling to ensure its stability and reliability in a production environment.

- 🧱 **Modern, Object-Oriented API**:
  
  - Provides a series of well-designed classes like `ZmqContext`, `ZmqSocket`, `ZmqMsg` with an intuitive, easy-to-use interface that implements automatic resource management (RAII), eliminating memory leaks.

---

## 🚀 Performance Highlight: The Unmatched Advantage of `uchar[]`

Rigorous testing has shown that transferring data directly using byte arrays (`uchar[]`) is over **110%** faster than using the standard `string` type.

| Benchmark                                    | Result                     |
| -------------------------------------------- | -------------------------- |
| **Latency** - `inproc`                       | **`6.18 µs / round-trip`** |
| **Throughput** - `uchar[]`                   | **`~50,289 messages/sec`** |
| **Throughput** - `string`                    | `~23,892 messages/sec`     |
| **Performance Gain (`uchar[]` vs `string`)** | **`+110.49%`**             |

#### Why is `uchar[]` Faster?

- **Zero Overhead**: In MQL5, `uchar[]` is a contiguous block of bytes in memory. Sending it via `zmq_send()` is essentially a direct memory copy with virtually no extra overhead.
- **Avoids Conversion**: When you send an MQL5 `string`, the library must internally convert it into a UTF-8 encoded byte array that ZeroMQ uses. This process involves additional CPU calculations and temporary memory allocation, which becomes a performance bottleneck during high-frequency sending.

> **⭐ The Golden Rule of Performance**
> For performance-sensitive applications (like HFT strategies or market data forwarders), **always use `uchar[]`** for data transfer. You can use MQL5's built-in `StructToCharArray` and `CharArrayToStruct` functions to efficiently serialize your data structures.

---

## 🛠️ Installation & Configuration

The installation process is very straightforward. Just follow these steps:

#### **Step 1: Copy the MQL5 Library Files**

Copy the entire `ZeroMQ` folder (which contains `ZeroMQ.mqh` and the `Core` subfolder) into your MQL5 `Include` directory.

- **Standard Path**:
  
  ```
  C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Include/
  ```

- **The final directory structure should look like this**:
  
  ```
  MQL5/
  └── Include/
      └── ZeroMQ/              <- Copy this folder here
          ├── ZeroMQ.mqh       <- The main header file
          └── Core/            <- Core modules
              └── ... (multiple .mqh files)
  ```

#### **Step 2: Copy the Dependent DLL Files**

Copy the two pre-compiled DLL files, `libzmq.dll` and `libsodium.dll`, into the **`Libraries`** directory of your MetaTrader 5 terminal (**Note**: not the `Include` directory).

> **Note**: `libsodium.dll` is required even if you are not using encryption, as `libzmq.dll` depends on it.

- **Standard Path**:
  
  ```
  C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Libraries/
  ```

- **Final Directory Structure**:
  
  ```
  MQL5/
  └── Libraries/
      ├── libzmq.dll
      └── libsodium.dll
  ```

#### **Step 3: Enable DLL Imports**

In your MetaTrader 5 terminal, go to **“Tools -> Options -> Expert Advisors”** and **check “Allow DLL imports”**.

#### **Step 4: Reference it in Your Code**

At the beginning of your EA, script, or indicator, simply include the main header file to get started. This path will now perfectly match your directory structure.

```mql5
#include <ZeroMQ/ZeroMQ.mqh>```

---

## 💡 Definitive API Guide & Examples

### Part 1: Request-Reply (REQ/REP)

This is the most basic client-server pattern. The client sends a request, and the server receives and replies.

#### **Server (`Rep_Server.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    if(!context.isValid()) return;

    ZmqSocket server(context, ZMQ_SOCKET_REP);
    if(!server.bind("tcp://*:5555")) return;

    Print("Server started on tcp://*:5555...");

    while(!IsStopped())
    {
        string request;
        if(server.recv(request))
        {
            PrintFormat("Received: '%s'. Replying with 'World'", request);
            server.send("World");
        }
    }
}
```

#### **Client (`Req_Client.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    if(!context.isValid()) return;

    ZmqSocket client(context, ZMQ_SOCKET_REQ);
    if(!client.connect("tcp://localhost:5555")) return;

    Print("Client connected. Sending 'Hello'...");
    client.send("Hello");

    string reply;
    // Set a 5-second timeout for receiving
    client.setReceiveTimeout(5000);
    if(client.recv(reply))
    {
        PrintFormat("Received reply: '%s'", reply);
    }
    else
    {
        Print("Request timed out. Server may not be running.");
    }
}
```

### Part 2: Publish-Subscribe (PUB/SUB)

Used for broadcasting data to multiple subscribers. The publisher doesn't care if there are subscribers; it just sends.

#### **Publisher - Broadcasting Market Ticks (`Publisher.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket publisher(context, ZMQ_SOCKET_PUB);
    publisher.bind("tcp://*:5556");
    Print("Market Data Publisher started...");

    MqlTick tick;
    while(!IsStopped())
    {
        if(SymbolInfoTick(_Symbol, tick))
        {
            // Use uchar[] for maximum performance
            uchar tick_data[];
            StructToCharArray(tick, tick_data);

            // The topic is "TICK.EURUSD", and the message body is the byte stream of the tick data
            publisher.send("TICK." + _Symbol, ZMQ_FLAG_SNDMORE);
            publisher.send(tick_data);
        }
        Sleep(1000);
    }
}
```

#### **Subscriber - Receiving EURUSD Ticks (`Subscriber.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket subscriber(context, ZMQ_SOCKET_SUB);
    subscriber.connect("tcp://localhost:5556");

    // Key: Subscribe to all topics starting with "TICK.EURUSD"
    subscriber.subscribe("TICK.EURUSD");
    Print("Subscribed to 'TICK.EURUSD'. Waiting for data...");

    // ZMQ connection takes a moment to establish, so wait briefly before looping
    Sleep(100);

    MqlTick received_tick;
    string topic;
    uchar tick_data[];

    while(!IsStopped())
    {
        // First, receive the topic
        if(subscriber.recv(topic, ZMQ_FLAG_NONE))
        {
            // If there's another part, receive the message body
            if(subscriber.getReceiveMore(true))
            {
                subscriber.recv(tick_data);
                CharArrayToStruct(received_tick, tick_data, 0);
                PrintFormat("[%s] Ask: %.5f, Bid: %.5f, Volume: %d", 
                            topic, received_tick.ask, received_tick.bid, (int)received_tick.volume);
            }
        }
    }
}```

### Part 3: High-Performance `uchar[]` Struct Transfer

This is the recommended advanced pattern for production environments, achieving zero-overhead data transfer.

#### **Shared Data Structure (`SharedStructures.mqh`)**

It's recommended to create a shared header file so that both the sender and receiver use the exact same data structure.

```mql5
// In file: MQL5/Include/SharedStructures.mqh
struct StrategyParameters
{
    long     magic_number;
    double   lot_size;
    int      max_slippage_points;
    char     symbol[32]; // Use a fixed-size char array to ensure the struct is serializable
};
```

#### **Sender (`Sender.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
#include <SharedStructures.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket pusher(context, ZMQ_SOCKET_PUSH);
    pusher.connect("tcp://localhost:5557");

    // 1. Populate the data structure
    StrategyParameters params;
    params.magic_number = 12345;
    params.lot_size = 0.02;
    params.max_slippage_points = 30;
    StringToCharArray("EURUSD", params.symbol);

    // 2. Serialize to a byte array
    uchar buffer[];
    StructToCharArray(params, buffer);

    // 3. Send the raw bytes
    if(pusher.send(buffer))
    {
        Print("Sent strategy parameters successfully.");
    }
}
```

#### **Receiver (`Receiver.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
#include <SharedStructures.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket puller(context, ZMQ_SOCKET_PULL);
    puller.bind("tcp://*:5557");
    Print("Receiver listening...");

    uchar buffer[];
    // Set a 10-second timeout
    puller.setReceiveTimeout(10000); 

    if(puller.recv(buffer))
    {
        // 1. Receive the raw bytes
        StrategyParameters params;

        // 2. Deserialize back into the data structure
        if(CharArrayToStruct(params, buffer, 0))
        {
            // 3. Use the data
            PrintFormat("Received Parameters: Magic=%d, Lot=%.2f, Symbol=%s",
                        params.magic_number, params.lot_size, CharArrayToString(params.symbol));
        }
    }
    else
    {
        Print("Timed out waiting for parameters.");
    }
}
```

---

## 🤝 Contributing

This library is developed and maintained by **ding9736** in collaboration with **AI assistants**. We welcome community contributions, whether it's reporting issues or submitting pull requests.

- **MQL5 Profile**: [https://www.mql5.com/en/users/ding9736](https://www.mql5.com/en/users/ding9736)
- **GitHub Repository**: https://github.com/ding9736/MQL5-ZeroMQ

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

<details>
<summary>Click to view the full license</summary>

```
MIT License

Copyright (c) 2025 ding9736

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```