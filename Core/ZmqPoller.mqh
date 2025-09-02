//+------------------------------------------------------------------+
//|   Core/ZmqPoller.mqh                                             |
//+------------------------------------------------------------------+
#ifndef MQL_ZMQ_POLLER_MQH
#define MQL_ZMQ_POLLER_MQH
#property strict

#include "ZmqSocket.mqh"
#include "StaticGateway.mqh"

class ZmqPoller
{
private:
    PollItem  m_items[];       // Internal array of PollItem structs for the C-style API
    ZmqSocket* m_sockets[];    // Parallel array to map sockets to PollItems
    int       m_count;         // Current number of registered sockets

    int findSocketIndex(ZmqSocket &socket) const
    {
        for(int i = 0; i < m_count; i++)
        {
            if(m_sockets[i] == &socket)
            {
                return i;
            }
        }
        return -1;
    }

public:
    ZmqPoller() : m_count(0)
    {
       ArrayFree(m_items);
       ArrayFree(m_sockets);
    }
    
    ~ZmqPoller()
    {
       ArrayFree(m_items);
       ArrayFree(m_sockets);
    }

    // 
    bool add(ZmqSocket &socket, const short events_to_monitor)
    {
        if(!socket.isValid() || findSocketIndex(socket) != -1)
        {
            ZMQ_LOG_ERROR("ZmqPoller::add <- FAILED. Socket is invalid or already registered.");
            return false;
        }
        
        m_count++;
        ArrayResize(m_items, m_count);
        ArrayResize(m_sockets, m_count);
        
        socket.fillPollItem(m_items[m_count - 1], events_to_monitor);
        m_sockets[m_count - 1] = &socket;
        
        return true;
    }

    // 
    bool remove(ZmqSocket &socket)
    {
        int index = findSocketIndex(socket);
        if(index == -1)
        {
            ZMQ_LOG_ERROR("ZmqPoller::remove <- FAILED. Socket not found.");
            return false;
        }

        for(int i = index; i < m_count - 1; i++)
        {
            m_items[i] = m_items[i + 1];
            m_sockets[i] = m_sockets[i + 1];
        }

        m_count--;
        ArrayResize(m_items, m_count);
        ArrayResize(m_sockets, m_count);
        return true;
    }
    
    //
    int poll(const int timeout_ms)
    {
       if(m_count == 0) return 0;
       return Zmq::poll(m_items, timeout_ms);
    }

    //
    bool isReady(ZmqSocket &socket) const
    {
       int index = findSocketIndex(socket);
       if(index == -1) return false;
       
       return (m_items[index].revents != 0);
    }
    
    bool isReadable(ZmqSocket &socket) const
    {
       int index = findSocketIndex(socket);
       if(index == -1) return false;
       return m_items[index].hasInput();
    }
    
    bool isWritable(ZmqSocket &socket) const
    {
       int index = findSocketIndex(socket);
       if(index == -1) return false;
       return m_items[index].hasOutput();
    }
};

#endif // MQL_ZMQ_POLLER