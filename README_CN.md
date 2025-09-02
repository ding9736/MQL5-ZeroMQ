<div align="center">

# MQL5-ZeroMQ

### 工业级的高性能MQL5消息队列库

</div>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-2.5.9-blue.svg">
  <img alt="Platform" src="https://img.shields.io/badge/platform-MetaTrader%205-orange.svg">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

---

**MQL5-ZeroMQ** 是一个为 MetaTrader 5 (MQL5) 量身打造的、功能完备、性能卓越的高级消息队列库。它将享誉全球的 ZeroMQ (ØMQ, ZMQ) 的强大能力无缝集成到 MQL5 环境中，为开发者提供了“打了类固醇的套接字 (sockets on steroids)”——超越传统 TCP/UDP 的、内置并发模式的智能消息管道。

无论您需要在多个EA/指标之间进行**低延迟、高吞吐**的进程间通信(IPC)，构建复杂的分布式计算系统（例如，将计算密集型任务卸载到外部Python/C++应用），还是与外部数据源进行实时、可靠的数据交换，MQL5-ZeroMQ 都是您的终极解决方案。

---

## 📚 目录

- [✨ 核心特性](#-核心特性)
- [🚀 性能亮点：uchar[] 的极致优势](#-性能亮点uchar-的极致优势)
- [🛠️ 安装与配置](#️-安装与配置)
- [💡 权威API指南与示例](#-权威api指南与示例)
  - [请求-应答 (REQ/REP)](#part-1-请求-应答-reqrep)
  - [发布-订阅 (PUB/SUB)](#part-2-发布-订阅-pubsub)
  - [高性能 `uchar[]` 数据结构传输](#part-3-高性能-uchar-数据结构传输)
- [🤝 贡献](#-贡献)
- [📄 授权许可 (License)](#-授权许可-license)

---

## ✨ 核心特性

- ⚡️ **极致性能**:
  
  - **微秒级延迟**: 在进程内(`inproc`)通信中，完整的请求-应答往返延迟低至 **~6.18 微秒**，接近原生函数调用速度。
  - **超高吞吐量**: 压力测试显示，使用零开销的字节数组(`uchar[]`)，吞吐量可飙升至 **50,000+ 条消息/秒**，证明了其在数据密集型应用中的卓越能力。

- 📡 **经典的并发消息模式**:
  
  - **请求-应答 (REQ/REP)**: 用于构建健壮的客户端-服务器通信，自动处理请求与回复的严格序列。
  - **发布-订阅 (PUB/SUB)**: 实现一对多的数据分发，是行情数据、交易信号广播的理想选择。
  - **管道/任务分配 (PUSH/PULL)**: 用于在多个工作单元之间并行分配任务，实现自动负载均衡。
  - **更多高级模式**: 同时支持 PAIR, ROUTER, DEALER, XPUB/XSUB 等，满足复杂路由和异步通信需求。

- 🛡️ **工业级安全 (开箱即用)**:
  
  - 内置强大的 **CurveZMQ** 加密协议。本库**已包含 `libsodium.dll`**，仅需几行代码即可为您的TCP通信添加企业级的端到端加密，确保数据安全。

- ⚙️ **高级功能 & 健壮性**:
  
  - **异步 I/O (`ZmqPoller`)**: 无需复杂的多线程编程，即可优雅地同时管理和监听多个套接字事件。
  - **流量控制 (HWM)**: 内置高水位标记(High-Water Mark)机制，自动处理网络背压，防止消息积压导致内存耗尽。
  - **多部分消息 (Multipart Messages)**: 可将单个消息原子化地拆分为多个帧进行传输，是构建协议和传输复杂数据的利器。
  - **经过全面测试**: 整个库经过了包含80多项断言的严格测试套件验证，覆盖了核心功能、高级特性、性能和错误处理，确保了其在生产环境中的稳定可靠。

- 🧱 **现代化的面向对象API**:
  
  - 提供 `ZmqContext`, `ZmqSocket`, `ZmqMsg` 等一系列设计精良的类，接口直观、易于使用且实现了自动资源管理 (RAII)，杜绝内存泄漏。

---

## 🚀 性能亮点：`uchar[]` 的极致优势

经过严格测试，直接使用字节数组 (`uchar[]`) 进行数据传输比使用标准 `string` 类型快 **110%** 以上。

| 基准测试项 (Benchmark)                | 性能结果 (Result)              |
| -------------------------------- | -------------------------- |
| **延迟 (Latency)** - `inproc`      | **`6.18 µs / round-trip`** |
| **吞吐量 (Throughput)** - `uchar[]` | **`~50,289 消息/秒`**         |
| **吞吐量 (Throughput)** - `string`  | `~23,892 消息/秒`             |
| **性能增益 (`uchar[]` vs `string`)** | **`+110.49%`**             |

#### 为什么 `uchar[]` 更快？

- **零开销**: MQL5 中的 `uchar[]` 在内存中是连续的字节块。通过 `zmq_send()` 发送它，本质上是一次直接的内存复制，几乎没有额外开销。
- **避免转换**: 当您发送一个 MQL5 `string` 时，库必须在内部将其转换为 ZeroMQ 使用的 UTF-8 编码字节数组。这个过程涉及额外的CPU计算和临时内存分配，从而在高频率发送时成为性能瓶颈。

> **⭐ 性能黄金法则**
> 对于性能敏感的应用（如高频策略、行情转发），请**始终使用 `uchar[]`** 进行数据传输。您可以使用 MQL5 内置的 `StructToCharArray` 和 `CharArrayToStruct` 等函数来高效地序列化您的数据结构。

---

## 🛠️ 安装与配置

安装过程非常简单，遵循以下步骤即可完成：

#### **第 1 步: 复制 MQL5 库文件**

将整个 `ZeroMQ` 文件夹（其中包含了 `ZeroMQ.mqh` 和 `Core` 子文件夹）复制到您的 MQL5 `Include` 目录下。

- **标准路径**:
  
  ```
  C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Include/
  ```

- **最终目录结构应如下所示**:
  
  ```
  MQL5/
  └── Include/
      └── ZeroMQ/              <- 复制这个文件夹进去
          ├── ZeroMQ.mqh       <- 主头文件
          └── Core/            <- 核心模块
              └── ... (多个 .mqh 文件)
  ```

#### **第 2 步: 复制依赖的 DLL 文件**

将 `libzmq.dll` 和 `libsodium.dll` 这两个预编译好的 DLL 文件复制到 MetaTrader 5 终端的 **`Libraries`** 目录下（**注意**：不是 `Include` 目录）。

> **注意**: 即使您不使用加密功能，`libsodium.dll` 也是必需的，因为 `libzmq.dll` 依赖于它。

- **标准路径**:
  
  ```
  C:/Users/<Your Username>/AppData/Roaming/MetaQuotes/Terminal/<Instance ID>/MQL5/Libraries/
  ```

- **最终目录结构**:
  
  ```
  MQL5/
  └── Libraries/
      ├── libzmq.dll
      └── libsodium.dll
  ```

#### **第 3 步: 启用 DLL 导入**

在您的 MetaTrader 5 终端中，进入 **“工具 (Tools) -> 选项 (Options) -> EA交易 (Expert Advisors)”**，并**勾选 “允许DLL导入 (Allow DLL imports)”**。

#### **第 4 步: 在代码中引用**

在您的 EA、脚本或指标的开头，仅需包含主头文件即可开始使用。这个路径现在与您的目录结构完全匹配。

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
```

---

## 💡 权威API指南与示例

### Part 1: 请求-应答 (REQ/REP)

这是最基础的客户端-服务器模式。客户端发送请求，服务器接收并回复。

#### **服务器 (`Rep_Server.mq5`)**

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

#### **客户端 (`Req_Client.mq5`)**

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
    // 为接收设置5秒超时
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

### Part 2: 发布-订阅 (PUB/SUB)

用于向多个订阅者广播数据。发布者不关心是否有订阅者，只管发送。

#### **发布者 - 广播行情 (`Publisher.mq5`)**

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
            // 使用 uchar[] 实现最高性能
            uchar tick_data[];
            StructToCharArray(tick, tick_data);

            // 主题是 "TICK.EURUSD", 消息体是 tick 数据的字节流
            publisher.send("TICK." + _Symbol, ZMQ_FLAG_SNDMORE);
            publisher.send(tick_data);
        }
        Sleep(1000);
    }
}
```

#### **订阅者 - 接收EURUSD行情 (`Subscriber.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket subscriber(context, ZMQ_SOCKET_SUB);
    subscriber.connect("tcp://localhost:5556");

    // 关键: 订阅以 "TICK.EURUSD" 开头的所有主题
    subscriber.subscribe("TICK.EURUSD");
    Print("Subscribed to 'TICK.EURUSD'. Waiting for data...");

    // ZMQ连接建立需要时间，在循环前短暂等待
    Sleep(100);

    MqlTick received_tick;
    string topic;
    uchar tick_data[];

    while(!IsStopped())
    {
        // 先接收主题
        if(subscriber.recv(topic, ZMQ_FLAG_NONE))
        {
            // 如果还有下一部分，则接收消息体
            if(subscriber.getReceiveMore(true))
            {
                subscriber.recv(tick_data);
                CharArrayToStruct(received_tick, tick_data, 0);
                PrintFormat("[%s] Ask: %.5f, Bid: %.5f, Volume: %d", 
                            topic, received_tick.ask, received_tick.bid, (int)received_tick.volume);
            }
        }
    }
}
```

### Part 3: 高性能 `uchar[]` 数据结构传输

这是推荐用于生产环境的高级模式，可实现零开销的数据传输。

#### **共享数据结构 (`SharedStructures.mqh`)**

建议创建一个共享头文件，以便发送方和接收方使用完全相同的数据结构。

```mql5
// In file: MQL5/Include/SharedStructures.mqh
struct StrategyParameters
{
    long     magic_number;
    double   lot_size;
    int      max_slippage_points;
    char     symbol[32]; // 使用固定长度的 char 数组以保证结构体可序列化
};
```

#### **发送方 (`Sender.mq5`)**

```mql5
#include <ZeroMQ/ZeroMQ.mqh>
#include <SharedStructures.mqh>

void OnStart()
{
    ZmqContext context;
    ZmqSocket pusher(context, ZMQ_SOCKET_PUSH);
    pusher.connect("tcp://localhost:5557");

    // 1. 填充数据结构
    StrategyParameters params;
    params.magic_number = 12345;
    params.lot_size = 0.02;
    params.max_slippage_points = 30;
    StringToCharArray("EURUSD", params.symbol);

    // 2. 序列化为字节数组
    uchar buffer[];
    StructToCharArray(params, buffer);

    // 3. 发送原始字节
    if(pusher.send(buffer))
    {
        Print("Sent strategy parameters successfully.");
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
    ZmqSocket puller(context, ZMQ_SOCKET_PULL);
    puller.bind("tcp://*:5557");
    Print("Receiver listening...");

    uchar buffer[];
    // 设置10秒超时
    puller.setReceiveTimeout(10000); 

    if(puller.recv(buffer))
    {
        // 1. 接收原始字节
        StrategyParameters params;

        // 2. 反序列化回数据结构
        if(CharArrayToStruct(params, buffer, 0))
        {
            // 3. 使用数据
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

## 🤝 贡献

本库由 **ding9736** 及 **AI 助手** 合作开发与维护。我们欢迎社区的贡献，无论是问题反馈还是代码提交 (Pull Request)。

- **MQL5 Profile**: [https://www.mql5.com/en/users/ding9736](https://www.mql5.com/en/users/ding9736)
- **GitHub Repository**: https://github.com/ding9736/MQL5-ZeroMQ
- 

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
