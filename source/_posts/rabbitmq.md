---
title: rabbitmq命令行工具
date: 2020-03-02 14:40:44
categories:
- Others
tags:
- idea
thumbnail: /gallery/whatisrabbitmq.jpg
---

rabbitmq是一个消息代理中间件，它接收并转发消息。与现实生活中信件的投递作比较而言，rabbitmq相当于扮演了邮箱、邮局以及快递员的角色。

+ Producing, 消息的发送方，发送消息的程序是一个producer
+ queue, rabbitmq中的“邮箱”
  + 尽管消息会在rabbitmq和你的应用程序上进行传输，但消息只能存储在queue中
  + 一个queue只受主机的内存和磁盘限制，它本质上是一个大的消息缓冲区
  + 许多Producer可以发送消息到一个队列，许多consumer可以从一个队列接收数据
+ Consuming, 消息的接收方，主要功能是等待接收消息的程序称为consumer

## 如何确保消息不丢失

### 消息确认 (Message acknowledgment)

为了确保消息不被丢失，rabbitmq提供了消息确认功能，consumer发送一个ack告诉rabbitmq消息已经被接收并且处理了，rabbitmq可以删除这条消息了。

如果一个consumer在没有发送ack的情况下下线了（channel被关闭、connection被关闭或TCP连接丢失），rabbitmq将把这条未被确认的消息认为没有被完全处理并重新加入队列，如果有另外的consumers同时在线，这条消息会被快速交付到其他consumer，这样来确保在有consumer下线的情况下，消息不被丢失。

配置消息确认：
```
def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)
    ...
    print(" [x] Done")
    ch.basic_ack(delivery_tag = method.delivery_tag) # 配置ack

channel.basic_consume(queue='hello', on_message_callback=callback)
```

关闭消息确认：
```
channel.basic_consume(queue='hello', auto_ack=True, on_message_callback=callback)
```

### 消息持久化 (Message durability)

当rabbitmq服务退出或崩溃了，在没有做任何持久化措施的情况下，队列和消息都将丢失。要确保消息不丢失，需要配置消息和队列的持久化。

首先配置队列的持久化：
```
# producer和consumer代码中都要有
channel.queue_declare(queue='task_queue', durable=True)
```
然后是消息的持久化配置：
```
channel.basic_publish(exchange='',
                      routing_key="task_queue",
                      body=message,
                      properties=pika.BasicProperties(
                          delivery_mode = 2,  //消息持久化
                      ))
```

## 消息调度

有多个消费端（consumer）worker时，默认情况下，rabbitmq将按顺序将每个消息发送给下一个使用者，平均每个消费端将得到相同数量的消息。（round-robin dispatching）

因为不同的消息处理时间不同，round-robin这种调度方法容易造成有的worker负载过重的情况，为了解决这个问题，可以使用`basic_qos`方法，配置同时分配给一个worker的消息数为1。也就是说，在worker处理并确认前一条消息之前，不要向其发送新消息。（Fair dispatch）

```
channel.basic_qos(prefetch_count=1)
```
