<div align="center">

# MQL5-ZeroMQ

### 工业级的高性能MQL5消息队列库

</div>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-3.0-blue.svg">
  <img alt="Platform" src="https://img.shields.io/badge/platform-MetaTrader%205-orange.svg">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

---

**MQL5-ZeroMQ** 是一个为 MetaTrader 5 (MQL5) 量身打造的、功能完备、性能卓越的高级消息队列库。它将享誉全球的 ZeroMQ (ØMQ, ZMQ) 的强大能力无缝集成到 MQL5 环境中，为开发者提供了“打了类固醇的套接字 (sockets on steroids)”——超越传统 TCP/UDP 的、内置并发模式的智能消息管道。

这个 `3.0` 版本代表了一次重大的架构改革，专注于极致的健壮性、稳定性以及对生产级软件工程原则的遵循。后台服务模型（如ZAP认证）已使用MQL5原生的协作式任务调度器重建，确保了在MetaTrader沙箱环境中的最高稳定性和兼容性。

---

## 📚 目录

- [✨ 核心特性](#-核心特性)
- [🚀 性能亮点：uchar[] 的极致优势](#-性能亮点uchar-的极致优势)
- [🛠️ 安装与配置](#️-安装与配置)
- [💡 权威API指南与示例](#-权威api指南与示例)
  - [⚠️ EA开发重要提示 (必读)](#️-ea开发重要提示-必读)
  - [请求-应答 (REQ/REP)](#part-1-请求-应答-reqrep)
  - [发布-订阅 (PUB/SUB)](#part-2-发布-订阅-pubsub)
  - [ZAP 认证 (CURVE 安全)](#part-3-zap-认证-curve-安全)
  - [高性能 `uchar[]` 数据结构传输](#part-4-高性能-uchar-数据结构传输)
- [🤝 贡献](#-贡献)
- [📄 授权许可 (License)](#-授权许可-license)

---

## ✨ 核心特性

- ⚡️ **极致性能**:
  
  - **微秒级延迟**: 在进程内(`inproc`)通信中，完整的请求-应答往返延迟低至 **~6.14 微秒**。
  - **超高吞吐量**: 压力测试显示，使用零开销的字节数组(`uchar[]`)，吞吐量可飙升至 **1380万+ 条消息/秒**，性能远超旧版。

- 📡 **经典的并发消息模式**:
  
  - **请求-应答 (REQ/REP)**: 用于构建健壮的客户端-服务器通信。
  - **发布-订阅 (PUB/SUB)**: 实现一对多的数据分发，是行情数据、交易信号广播的理想选择。
  - **管道/任务分配 (PUSH/PULL)**: 用于在多个工作单元之间并行分配任务。
  - **更多高级模式**: 同时支持 PAIR, ROUTER, DEALER, XPUB/XSUB 等。

- 🛡️ **工业级安全 (开箱即用)**:
  
  - 内置强大的 **CurveZMQ** 加密协议，通过ZAP认证器实现。本库**已包含 `libsodium.dll`**，仅需几行代码即可为您的TCP通信添加企业级的端到端加密。
  - **简化的API**: 通过 `ZmqContext` 上的 `authStart()` 和 `authAllowClient()` 方法，即可轻松启动和管理服务端认证。

- ⚙️ **健壮的架构**:
  
  - **MQL5原生后台服务**: 所有后台任务（如ZAP认证）都在一个MQL5原生的协作式调度器上运行，避免了直接调用操作系统线程API的风险，与EA的事件模型（`OnTimer`）完美集成，确保了最高稳定性。
  - **异步 I/O (`ZmqPoller`)**: 无需复杂的多线程编程，即可优雅地同时管理和监听多个套接字事件。
  - **流量控制 (HWM)**: 内置高水位标记机制，自动处理网络背压，防止消息积压导致内存耗尽。
  - **经过全面测试**: 整个库经过了包含89项断言的严格测试套件验证，所有测试均已通过，确保了其在生产环境中的稳定可靠。

- 🧱 **现代化的面向对象API**:
  
  - 提供 `ZmqContext`, `ZmqSocket`, `ZmqMsg` 等一系列设计精良的类，接口直观、易于使用且实现了自动资源管理 (RAII)，杜绝内存泄漏。

---

## 🚀 性能亮点：`uchar[]` 的极致优势

经过严格测试，直接使用字节数组 (`uchar[]`) 进行数据传输比使用标准 `string` 类型快 **136%** 以上。

| 基准测试项 (Benchmark)                | 性能结果 (Result)              |
| -------------------------------- | -------------------------- |
| **延迟 (Latency)** - `inproc`      | **`6.14 µs / round-trip`** |
| **吞吐量 (Throughput)** - `uchar[]` | **`~13,888,889 消息/秒`**     |
| **吞吐量 (Throughput)** - `string`  | `~5,865,103 消息/秒`          |
| **性能增益 (`uchar[]` vs `string`)** | **`+136.81%`**             |

#### 为什么 `uchar[]` 更快？

- **零开销**: MQL5 中的 `uchar[]` 在内存中是连续的字节块。通过 `zmq_send()` 发送它，本质上是一次直接的内存复制，几乎没有额外开销。
- **避免转换**: 当您发送一个 MQL5 `string` 时，库必须在内部将其转换为 ZeroMQ 使用的 UTF-8 编码字节数组。这个过程涉及额外的CPU计算和临时内存分配，从而在高频率发送时成为性能瓶颈。

> **⭐ 性能黄金法则**
> 对于性能敏感的应用（如高频策略、行情转发），请**始终使用 `uchar[]`** 进行数据传输。您可以使用 MQL5 内置的 `StructToCharArray` 和 `CharArrayToStruct` 等函数来高效地序列化您的数据结构。

---

## 🛠️ 安装与配置

安装过程非常简单，遵循以下步骤即可完成：

#### **第 1 步: 复制 MQL5 库文件**

将整个 `ZeroMQ` 文件夹复制到您的 MQL5 `Include` 目录下。

- **路径**: `C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Include/`

#### **第 2 步: 复制依赖的 DLL 文件**

将 `libzmq.dll` 和 `libsodium.dll` 这两个 DLL 文件复制到 `Libraries` 目录下。

> **注意**: 即使您不使用加密功能，`libsodium.dll` 也是必需的。

- **路径**: `C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Libraries/`

#### **第 3 步: 启用 DLL 导入**

在MT5终端中，进入 **“工具 -> 选项 -> EA交易”**，并**勾选 “允许DLL导入”**。

#### **第 4 步: 在代码中引用**

在您的代码开头包含主头文件即可。```mql5
#include <ZeroMQ/ZeroMQ.mqh>

```
## 💡 权威API指南与示例

### ⚠️ EA开发重要提示 (必读)
> MQL5-ZeroMQ 的高级功能（如 ZAP 安全认证）依赖于一个内置的、MQL5 原生的后台任务调度器。为了让这些后台任务（例如处理加密握手）能够运行，您 **必须** 在EA的 `OnTimer()` 函数中定期调用 `your_context.ProcessAuthTasks()`。
>
> 这是一个强制性步骤，否则认证将永远不会成功。

### Part 1: 请求-应答 (REQ/REP)
这是最基础的客户端-服务器模式。

#### **服务器 (`Rep_Server.mq5`)**
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

#### **客户端 (`Req_Client.mq5`)**

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

### Part 2: 发布-订阅 (PUB/SUB)

用于向多个订阅者广播数据。

#### **发布者 (`Publisher.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket publisher(context.ref(), ZMQ_SOCKET_PUB);
    publisher.bind("tcp://*:5556");
    Print("Publisher started...");

    // 等待订阅者连接
    Sleep(100); 

    // 发送一个带主题的多部分消息
    string update = {"EURUSD", "Price is 1.0855"};
    publisher.sendMultipart(update);
    Print("Published EURUSD update.");
}
```

#### **订阅者 (`Subscriber.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket subscriber(context.ref(), ZMQ_SOCKET_SUB);
    subscriber.connect("tcp://localhost:5556");

    // 关键: 订阅 "EURUSD" 主题
    subscriber.subscribe("EURUSD");
    Print("Subscribed to 'EURUSD'...");

    string received_parts[];
    if(subscriber.recvMultipart(received_parts)) {
        PrintFormat("Received update for %s: %s", received_parts[0], received_parts[1]);
    }
}
```

### Part 3: ZAP 认证 (CURVE 安全)

端到端加密与客户端认证。

> **请记住**: 以下服务端代码若在 EA 中运行, 必须在 `OnTimer` 中调用 `g_secure_context.ProcessAuthTasks()`。

#### **服务端 ZAP 设置**

```mql5
// 全局上下文
ZmqContext *g_secure_context = NULL; 

void StartSecureServer() {
    g_secure_context = new ZmqContext();

    // 1. 启动认证服务
    if (!g_secure_context.authStart()) {
        Print("Failed to start ZAP service!");
        return;
    }

    // 2. 生成密钥对
    string s_pub, s_sec, c_pub, c_sec;
    ZmqZ85Codec::generateKeyPair(s_pub, s_sec);
    ZmqZ85Codec::generateKeyPair(c_pub, c_sec);
    Print("Client Public Key for client's setup: ", c_pub);

    // 3. 将授权客户端的公钥加入白名单
    g_secure_context.authAllowClient(c_pub);

    // 4. 配置服务器套接字
    ZmqSocket server(g_secure_context.ref(), ZMQ_SOCKET_REP);
    server.setCurveServer(true);
    server.setCurveSecretKey(s_sec);

    // 5. 绑定
    if(server.bind("tcp://*:5557")) {
        Print("Secure server is listening...");
    }
}
```

#### **客户端 ZAP 设置**

```mql5
void RunSecureClient()
{
    ZmqContext context;

    // 从服务器管理员那里获取的密钥
    string server_public_key = "在此处填写服务器的公钥";
    string client_public_key = "在此处填写您的客户端公钥";
    string client_secret_key = "在此处填写您的客户端私钥";

    ZmqSocket client(context.ref(), ZMQ_SOCKET_REQ);
    client.setCurveServerKey(server_public_key);
    client.setCurvePublicKey(client_public_key);
    client.setCurveSecretKey(client_secret_key);

    client.connect("tcp://localhost:5557");
    client.send("Secure Hello");
    // ...
}
```

### Part 4: 高性能 `uchar[]` 数据结构传输

这是推荐用于生产环境的高级模式。

#### **共享数据结构 (`SharedStructures.mqh`)**

```mql5
// MQL5/Include/SharedStructures.mqh
struct StrategyParameters {
    long   magic_number;
    double lot_size;
    char   symbol[32]; // 使用固定长度数组保证结构体可序列化
};
```

#### **发送方 (`Sender.mq5`)**

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
    StructToCharArray(params, buffer); // 序列化为字节数组

    if(pusher.send(buffer)) {
        Print("Sent parameters successfully.");
    }
}
```

#### **接收方 (`Receiver.mq5`)**

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
        // 反序列化回数据结构
        if(CharArrayToStruct(params, buffer, 0))
        {
            PrintFormat("Received: Magic=%d, Symbol=%s",
                        params.magic_number, CharArrayToString(params.symbol));
        }
    }
}
```

---

## 🤝 贡献

本库由 **ding9736** 开发与维护。我们欢迎社区的贡献。

- **MQL5 Profile**: [https://www.mql5.com/en/users/ding9736](https://www.mql5.com/en/users/ding9736)
- **GitHub Repository**: https://github.com/ding9736/MQL5-ZeroMQ

---

## 📄 授权许可 (License)

本项目基于 [MIT License](LICENSE) 授权。

<details>
<summary>点击查看许可证全文</summary>

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

</details>
