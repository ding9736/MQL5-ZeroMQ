<div align="center">

# MQL5-ZeroMQ

### An Industrial-Grade, High-Performance MQL5 Message Queue Library

</div>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-3.0-blue.svg">
  <img alt="Platform" src="https://img.shields.io/badge/platform-MetaTrader%205-orange.svg">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

---

**MQL5-ZeroMQ** is a feature-complete, high-performance message queue library tailored for MetaTrader 5 (MQL5). It seamlessly integrates the power of the world-renowned ZeroMQ (ØMQ, ZMQ) into the MQL5 environment, providing developers with "sockets on steroids"—intelligent message pipelines with built-in concurrency patterns that go beyond traditional TCP/UDP.

This `3.0` release represents a major architectural overhaul focused on extreme robustness, stability, and adherence to production-grade software engineering principles. The background service model (e.g., for ZAP authentication) has been rebuilt using a cooperative MQL5-native task scheduler, ensuring maximum stability and compatibility within the MetaTrader sandbox.

---

## 📚 Table of Contents

- [✨ Core Features](#-core-features)
- [🚀 Performance Highlight: The Unmatched Advantage of `uchar[]`](#-performance-highlight-the-unmatched-advantage-of-uchar)
- [🛠️ Installation & Configuration](#️-installation--configuration)
- [💡 Definitive API Guide & Examples](#-definitive-api-guide--examples)
  - [⚠️ Important Note for EA Developers (MUST-READ)](#️-important-note-for-ea-developers-must-read)
  - [Request-Reply (REQ/REP)](#part-1-request-reply-reqrep)
  - [Publish-Subscribe (PUB/SUB)](#part-2-publish-subscribe-pubsub)
  - [ZAP Authentication (CURVE Security)](#part-3-zap-authentication-curve-security)
  - [High-Performance `uchar[]` Struct Transfer](#part-4-high-performance-uchar-struct-transfer)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## ✨ Core Features

- ⚡️ **Extreme Performance**:
  
  - **Microsecond-Level Latency**: In `inproc` communication, a full request-reply round-trip latency is as low as **~6.14 microseconds**.
  - **Ultra-High Throughput**: Stress tests show that using zero-overhead byte arrays (`uchar[]`) can boost throughput to **13.8 Million+ messages/second**, a massive improvement.

- 📡 **Classic Concurrency Messaging Patterns**:
  
  - **Request-Reply (REQ/REP)**: For building robust client-server communication.
  - **Publish-Subscribe (PUB/SUB)**: Ideal for broadcasting market data and trading signals.
  - **Pipeline/Task Distribution (PUSH/PULL)**: For parallel task distribution among worker units.
  - **More Advanced Patterns**: Also supports PAIR, ROUTER, DEALER, XPUB/XSUB.

- 🛡️ **Industrial-Grade Security (Out-of-the-Box)**:
  
  - Built-in powerful **CurveZMQ** encryption protocol via a ZAP authenticator. This library **already includes `libsodium.dll`**, allowing you to add enterprise-grade end-to-end encryption with just a few lines of code.
  - **Simplified API**: Easily start and manage the server-side authenticator with `authStart()` and `authAllowClient()` methods on the `ZmqContext`.

- ⚙️ **Robust Architecture**:
  
  - **MQL5-Native Background Services**: All background tasks (like ZAP authentication) run on an MQL5-native cooperative scheduler, avoiding risky OS-level thread API calls and integrating perfectly with an EA's event model (via `OnTimer`) for maximum stability.
  - **Asynchronous I/O (`ZmqPoller`)**: Gracefully manage and listen to multiple socket events simultaneously without blocking.
  - **Flow Control (HWM)**: Built-in High-Water Mark mechanism automatically handles network back-pressure.
  - **Fully Tested**: The entire library is validated by a rigorous test suite with 89 assertions (all passed), ensuring its reliability in a production environment.

- 🧱 **Modern, Object-Oriented API**:
  
  - Provides a series of well-designed classes like `ZmqContext`, `ZmqSocket`, `ZmqMsg` with an intuitive interface that implements automatic resource management (RAII), eliminating memory leaks.

---

## 🚀 Performance Highlight: The Unmatched Advantage of `uchar[]`

Rigorous testing has shown that transferring data directly using byte arrays (`uchar[]`) is over **136%** faster than using the standard `string` type.

| Benchmark                                    | Result                     |
| -------------------------------------------- | -------------------------- |
| **Latency** - `inproc`                       | **`6.14 µs / round-trip`** |
| **Throughput** - `uchar[]`                   | **`~13.88M messages/sec`** |
| **Throughput** - `string`                    | `~5.86M messages/sec`      |
| **Performance Gain (`uchar[]` vs `string`)** | **`+136.81%`**             |

#### Why is `uchar[]` Faster?

- **Zero Overhead**: `uchar[]` is a contiguous block of bytes. Sending it is essentially a direct memory copy.
- **Avoids Conversion**: Sending a `string` requires an internal conversion to a UTF-8 byte array, which adds CPU and memory overhead, creating a bottleneck at high frequencies.

> **⭐ The Golden Rule of Performance**
> For performance-sensitive applications, **always use `uchar[]`** for data transfer. Use MQL5's built-in `StructToCharArray` and `CharArrayToStruct` to efficiently serialize your data structures.

---

## 🛠️ Installation & Configuration

#### **Step 1: Copy the MQL5 Library Files**

Copy the entire `ZeroMQ` folder to your MQL5 `Include` directory.

- **Path**: `C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Include/`

#### **Step 2: Copy the Dependent DLL Files**

Copy `libzmq.dll` and `libsodium.dll` to the `Libraries` directory.

> **Note**: `libsodium.dll` is required even if you are not using encryption.

- **Path**: `C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Libraries/`

#### **Step 3: Enable DLL Imports**

In MT5, go to **“Tools -> Options -> Expert Advisors”** and **check “Allow DLL imports”**.

#### **Step 4: Reference it in Your Code**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
```

---

## 💡 Definitive API Guide & Examples

### ⚠️ Important Note for EA Developers (MUST-READ)

> Advanced features of MQL5-ZeroMQ, like **ZAP security**, rely on a built-in, MQL5-native background task scheduler. To allow these background tasks (e.g., processing encryption handshakes) to execute, you **MUST** periodically call `your_context.ProcessAuthTasks()` from within your EA's `OnTimer()` function.
> 
> This is a mandatory step; otherwise, authentication will never complete.

### Part 1: Request-Reply (REQ/REP)

The most basic client-server pattern.

#### **Server (`Rep_Server.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    if(!context.isValid()) return;

    ZmqSocket server(context.ref(), ZMQ_SOCKET_REP);
    if(!server.bind("tcp://*:5555")) return;

    Print("Server started...");
    string request;
    if(server.recv(request)) {
        PrintFormat("Received: '%s'. Replying with 'World'", request);
        server.send("World");
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

    ZmqSocket client(context.ref(), ZMQ_SOCKET_REQ);
    if(!client.connect("tcp://localhost:5555")) return;

    Print("Client sending 'Hello'...");
    client.send("Hello");

    string reply;
    client.setReceiveTimeout(5000);
    if(client.recv(reply)) {
        PrintFormat("Received reply: '%s'", reply);
    } else {
        Print("Request timed out.");
    }
}
```

### Part 2: Publish-Subscribe (PUB/SUB)

Used for broadcasting data to multiple subscribers.

#### **Publisher (`Publisher.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket publisher(context.ref(), ZMQ_SOCKET_PUB);
    publisher.bind("tcp://*:5556");
    Print("Publisher started...");

    Sleep(100); // Wait for subscribers to connect

    string update[] = {"EURUSD", "Price is 1.0855"};
    publisher.sendMultipart(update);
    Print("Published EURUSD update.");
}
```

#### **Subscriber (`Subscriber.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket subscriber(context.ref(), ZMQ_SOCKET_SUB);
    subscriber.connect("tcp://localhost:5556");

    subscriber.subscribe("EURUSD");
    Print("Subscribed to 'EURUSD'...");

    string received_parts[];
    if(subscriber.recvMultipart(received_parts)) {
        PrintFormat("Received update for %s: %s", received_parts[0], received_parts[1]);
    }
}
```

### Part 3: ZAP Authentication (CURVE Security)

End-to-end encryption and client authentication.

> **Remember**: If running the server code below in an EA, you must call `g_secure_context.ProcessAuthTasks()` inside `OnTimer`.

#### **Server-Side ZAP Setup**

```mql5
ZmqContext *g_secure_context = NULL; 

void StartSecureServer() {
    g_secure_context = new ZmqContext();

    // 1. Start the authentication service
    if (!g_secure_context.authStart()) {
        Print("Failed to start ZAP service!");
        return;
    }

    // 2. Generate key pairs
    string s_pub, s_sec, c_pub, c_sec;
    ZmqZ85Codec::generateKeyPair(s_pub, s_sec);
    ZmqZ85Codec::generateKeyPair(c_pub, c_sec);
    Print("Client Public Key for client's setup: ", c_pub);

    // 3. Whitelist the authorized client's public key
    g_secure_context.authAllowClient(c_pub);

    // 4. Configure the server socket
    ZmqSocket server(g_secure_context.ref(), ZMQ_SOCKET_REP);
    server.setCurveServer(true);
    server.setCurveSecretKey(s_sec);

    // 5. Bind
    if(server.bind("tcp://*:5557")) {
        Print("Secure server is listening...");
    }
}
```

#### **Client-Side ZAP Setup**

```mql5
void RunSecureClient()
{
    ZmqContext context;

    // Keys provided by the server administrator
    string server_public_key = "SERVER_PUBLIC_KEY_HERE";
    string client_public_key = "YOUR_CLIENT_PUBLIC_KEY";
    string client_secret_key = "YOUR_CLIENT_SECRET_KEY";

    ZmqSocket client(context.ref(), ZMQ_SOCKET_REQ);
    client.setCurveServerKey(server_public_key);
    client.setCurvePublicKey(client_public_key);
    client.setCurveSecretKey(client_secret_key);

    client.connect("tcp://localhost:5557");
    client.send("Secure Hello");
    // ...
}
```

### Part 4: High-Performance `uchar[]` Struct Transfer

The recommended pattern for production environments.

#### **Shared Data Structure (`SharedStructures.mqh`)**

```mql5
// MQL5/Include/SharedStructures.mqh
struct StrategyParameters {
    long   magic_number;
    double lot_size;
    char   symbol[32]; // Use fixed-size array to ensure struct is serializable
};
```

#### **Sender (`Sender.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
#include <SharedStructures.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket pusher(context.ref(), ZMQ_SOCKET_PUSH);
    pusher.connect("tcp://localhost:5558");

    StrategyParameters params;
    params.magic_number = 12345;
    params.lot_size = 0.02;
    StringToCharArray("EURUSD", params.symbol);

    uchar buffer[];
    StructToCharArray(params, buffer); // Serialize to byte array

    if(pusher.send(buffer)) {
        Print("Sent parameters successfully.");
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
    ZmqSocket puller(context.ref(), ZMQ_SOCKET_PULL);
    puller.bind("tcp://*:5558");
    Print("Receiver listening...");

    uchar buffer[];
    if(puller.recv(buffer))
    {
        StrategyParameters params;
        // Deserialize back into the struct
        if(CharArrayToStruct(params, buffer, 0))
        {
            PrintFormat("Received: Magic=%d, Symbol=%s",
                        params.magic_number, CharArrayToString(params.symbol));
        }
    }
}
```

---

## 🤝 Contributing

This library is developed and maintained by **ding9736** 

. We welcome community contributions.

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
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

</details>