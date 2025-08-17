# MQL5-ZeroMQ: 工业级高性能异步消息库


**MQL5-ZeroMQ** 是一个为MQL5环境深度优化的、工业级的ZeroMQ绑定库。它通过极薄的封装层直接调用原生`libzmq.dll`，为您的EA、指标和脚本带来了无与伦比的异步通信性能。

本项目的核心设计哲学是**性能至上、MQL5原生、极简依赖**。无论您是需要构建复杂的跨平台交易系统、在多个EA间进行低延迟IPC通信，还是仅仅想从外部Python脚本接收信号，本库都能提供最健壮、最高效的解决方案。

## 亮点特性 (Core Features)

*   **🚀 巅峰性能 (Peak Performance)**: 采用最直接的原生DLL绑定架构，消除了任何不必要的中间层（如C++/CLI），确保了最低的调用延迟和最高的吞吐量。核心的`ZmqMsg`对象经过优化，支持高频场景下的零内存分配消息接收。

*   **🔗 MQL5原生体验 (Native MQL5 Experience)**: 独家实现基于MQL5全局变量的**跨程序`ZmqContext`共享机制**。您无需任何配置，在同一终端下运行的所有EA/指标将自动共享同一个ZeroMQ上下文，这极大地节省了系统资源，并遵循了ZeroMQ的官方最佳实践。

*   **🧩 极简依赖 (Minimal Dependencies)**: **零编译需要**。您只需要`libzmq.dll`这一个文件，以及本项目的`.mqh`头文件。没有额外的包装器DLL，没有复杂的编译环境要求，实现了真正的“即插即用”。

*   **🛡️ 生产级健壮性 (Production-Grade Robustness)**:
    *   **完整功能集**: 全面支持REQ/REP, PUB/SUB, PUSH/PULL等核心模式，以及ROUTER/DEALER等高级模式。
    *   **企业级安全**: 内置CurveZMQ支持，仅需数行代码即可实现端到端加密通信。
    *   **完全兼容`#property strict`**: 代码经过反复迭代，已消除所有编译器警告，保证了最高的代码质量。
    *   **全面的套接字选项**: 几乎所有`zmq_setsockopt`选项都已通过简洁的API暴露，供您精细调优。

*   **📖 IDE内嵌式文档 (IDE-Embedded Documentation)**: 无需离开MetaEditor！主头文件`ZeroMQ.mqh`内含一份详尽的“开发手册”，全面覆盖了从快速上手、核心概念到高级用法和FAQ的所有内容。

## 快速上手 (Quick Start)

#### 第1步: 环境配置
1.  根据您的MetaTrader 5终端是32位还是64位，将对应的`libzmq.dll`文件复制到`MQL5\Libraries`目录下。
2.  在您的EA或指标代码的开头，确保开启DLL导入功能：
  
    #property script_show_inputs // 或 expert_show_inputs
    #property strict
    #import "libzmq.dll"
    #import
    `
3.  在EA的“属性”->“常用”设置中，勾选**“允许导入DLL”**。

#### 第2步: 包含头文件

#include <Lib/ZeroMQ/ZeroMQ.mqh>


#### 第3步: 编写代码 (Request/Reply 示例)

**客户端 (REQ - 发送请求):**

// MyReqClient.mq5
#include <Lib/ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
   ZmqContext context;
   ZmqSocket requester(context, ZMQ_SOCKET_REQ);
   if (!requester.connect("tcp://localhost:5555"))
   {
      Print("连接失败!");
      return;
   }
   
   string request = "Hello";
   Print("客户端发送: ", request);
   requester.send(request);
   
   ZmqMsg reply;
   // 重要: 设置2秒超时，防止EA被永久阻塞
   requester.setReceiveTimeout(2000); 
   if (requester.recv(reply))
   {
      Print("客户端收到: ", reply.getData());
   }
   else
   {
      Print("接收应答超时!");
   }
}


**服务端 (REP - 接收并应答):**

// MyRepServer.mq5
#include <Lib/ZeroMQ/ZeroMQ.mqh>

void OnStart()
{
   ZmqContext context;
   ZmqSocket replier(context, ZMQ_SOCKET_REP);
   if (!replier.bind("tcp://*:5555"))
   {
      Print("绑定失败!");
      return;
   }
   
   Print("服务端已启动，等待请求...");
   
   // 性能最佳实践: 在循环外部声明ZmqMsg对象以复用
   ZmqMsg request;
   
   while(!IsStopped())
   {
      // 使用非阻塞接收，避免在没有请求时卡住
      if (replier.recv(request, ZMQ_FLAG_DONTWAIT))
      {
         Print("服务端收到: ", request.getData());
         replier.send("World");
      }
      Sleep(10); // 非阻塞模式下必须加Sleep，防止CPU空转
   }
}


## 为何选择本库？(与`dingmaotu/mql-zmq`等项目的比较)

`dingmaotu/mql-zmq`是一个非常优秀的开源项目，但我们的库在设计哲学和实现上存在一些关键差异，使其在某些场景下更具优势：

1.  **架构优势 -> 极致性能**: 本库采用**直接调用**架构 (`MQL5 -> libzmq.dll`)，而`dingmaotu/mql-zmq`采用**C++/CLI包装器**架构 (`MQL5 -> Wrapper.dll -> libzmq.dll`)。对于追求最低延迟的金融应用，本库更“贴近金属”的架构提供了理论上的最高性能。
2.  **依赖优势 -> 极简部署**: 本库仅需`libzmq.dll`一个依赖。`dingmaotu/mql-zmq`则需要两个DLL文件，且其包装器DLL的任何修改都需要C++编译环境。本库对用户更友好。
3.  **MQL5原生优势 -> 智能资源管理**: 本库独有的**自动共享`ZmqContext`**功能，是专为MQL5平台多EA协作场景设计的深度优化，这是通用型包装器所不具备的。

## 文档

**最好的文档就在代码中！** 请直接在MetaEditor中打开`Lib/ZeroMQ/ZeroMQ.mqh`，其头部的注释块就是一份包罗万象的**开发手册**，涵盖了所有核心概念、API用法、高级功能和FAQ。

## API精粹 (API Highlights)

*   `ZmqContext`: ZeroMQ上下文的智能管理者，通常您只需要在程序开头`ZmqContext context;`即可。
*   `ZmqSocket`: ZeroMQ套接字，提供了`bind`, `connect`, `send`, `recv`, `poll`以及所有套接字选项的设置方法。
*   `ZmqMsg`: 高效的消息对象，在高频场景下应被重复使用。
*   `ZmqZ85Codec`: 用于Curve安全加密的密钥生成和编解码工具。

## 许可证 (License)

本项目采用 [MIT License](LICENSE)。

