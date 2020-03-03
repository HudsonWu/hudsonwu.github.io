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

+ Producing, 消息的发送方，发送消息的程序是一个producer，后面使用生产者表示
+ queue, rabbitmq中的“邮箱”（mail box），后面使用队列表示
  + 尽管消息会在rabbitmq和你的应用程序上进行传输，但消息只能存储在queue中
  + 一个queue只受主机的内存和磁盘限制，它本质上是一个大的消息缓冲区
  + 许多Producer可以发送消息到一个队列，许多consumer可以从一个队列接收数据
+ Consuming, 消息的接收方，主要功能是等待接收消息的程序称为consumer，后面使用消费者表示

## exchange，交换器

rabbitmq消息传递模型（messaging model）的核心思想是，生产者（producer）从不直接向队列（queue）发送消息，实际上，生产者根本不知道消息是否会被传递到哪个队列中。相反，生产者只能向交换器（exchange）发送消息，交换器做的事情非常简单，一边接收来自生产者的消息，另一边将消息推送到队列中。交换器必须确切地知道如何处理接收到的消息，是添加到一个特定的队列？还是添加到多个队列？或者应该丢弃？这些规则由exchange type定义，可用的取值为：`direct`, `topic`, `headers`, `fanout`。

+ default, 消息直接发送到指定队列
+ fanout, 广播消息给所有与交换器绑定的队列
+ direct, 消息根据单个条件有选择地发送到与交换器绑定的队列
+ topic, 根据多个条件有选择地发送到与交换器绑定的队列

### The default exchange

default exchange使用空字符串表示，这个exchange是特殊的，它直接指定消息要发送到哪个队列，队列名在`routing_key`参数中指定：
```python
# 生产者代码中配置
channel.basic_publish(exchange='', routing_key='hello', body=message)
```

### The fanout exchange

fanout exchange非常简单，广播所有接收到的消息给所有与它绑定的队列。很适合用来实现日志系统，运行一个接收程序直接把日志打印到文件，同时运行另一个接收程序打印日志到屏幕。

生产者代码：
```python
# 创建一个fanout exchange, 命名为logs
channel.exchange_declare(exchange='logs', exchange_type='fanout')
# 发布消息到logs exchange
channel.basic_publish(exchange='logs', routing_key='', body=message)
```

消费者代码：
```python
# 创建一个fanout exchange, 命名为logs
channel.exchange_declare(exchange='logs', exchange_type='fanout')
# 创建一个新的、空的队列，队列名称由服务器自动生成
# 配置exclusive为True, 一旦消费端连接关闭，队列将被删除
result = channel.queue_declare(queue='', exclusive=True)
# 将队列绑定到exchange
channel.queue_bind(exchange='logs', queue=result.method.queue)
```

### The direct exchange

direct exchange相对于fanout exchange来说，不是广播消息到所有与它绑定的队列，而是按照消息类别（对消息进行过滤）发送到不同的队列。比如日志系统，根据日志的严重级别过滤消息，运行一个程序打印日志到文件并配置只接收error级别的日志，再运行另一个程序打印日志到屏幕并配置接收所有级别的日志。direct exchange和队列的绑定(bindings)函数要接收一个额外的参数`routing_key`，使用这个参数配置如何选择消息。

生产者代码：
```python
# 创建一个direct exchange, 命名为direct_logs
channel.exchange_declare(exchange='direct_logs', exchange_type='direct')
# 发布消息
channel.basic_publish(exchange='direct_logs', routing_key=severity, body=message)
```

消费者代码：
```python
channel.exchange_declare(exchange='direct_logs', exchange_type='direct')
result = channel.queue_declare(queue='', exclusive=True)

for severity in severities:
    channel.queue_bind(exchange='direct_logs',
                       queue=result.method.queue,
                       routing_key=severity)
```

### The topic exchange

direct exchange不能基于多个条件对消息进行过滤，但topic exchange可以。发送给topic exchange的消息配置的`routing_key`参数不能是任意值，必须是一个以`.`分隔的单词列表，比如：`stock.usd.nyse`，该参数值的大小不超过255字节。有两个特殊的取值:
  + `#`, 可代替0个或多个任意单词
  + `*`, 可代替单个任意单词

生产者代码：
```python
# 创建一个topic exchange, 命名为topic_logs
channel.exchange_declare(exchange='topic_logs', exchange_type='topic')
# 发布消息
channel.basic_publish(exchange='topic_logs', routing_key=routing_key, body=message)
```

消费者代码：
```python
channel.exchange_declare(exchange='topic_logs', exchange_type='topic')

result = channel.queue_declare(queue='', exclusive=True)

for binding_key in binding_keys:
    channel.queue_bind(exchange='topic_logs',
                       queue=result.method.queue,
                       routing_key=binding_key)
```

## 如何确保消息不丢失

### 消息确认 (Message acknowledgment)

为了确保消息不被丢失，rabbitmq提供了消息确认功能，consumer发送一个ack告诉rabbitmq消息已经被接收并且处理了，rabbitmq可以删除这条消息了。

如果一个consumer在没有发送ack的情况下下线了（channel被关闭、connection被关闭或TCP连接丢失），rabbitmq将把这条未被确认的消息认为没有被完全处理并重新加入队列，如果有另外的consumers同时在线，这条消息会被快速交付到其他consumer，这样来确保在有consumer下线的情况下，消息不被丢失。

在消费者代码中配置消息确认：
```python
def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)
    ...
    print(" [x] Done")
    ch.basic_ack(delivery_tag = method.delivery_tag) # 配置ack

channel.basic_consume(queue='hello', on_message_callback=callback)
```

在消费者代码中配置关闭消息确认：
```python
channel.basic_consume(queue='hello', auto_ack=True, on_message_callback=callback)
```

### 消息持久化 (Message durability)

当rabbitmq服务退出或崩溃了，在没有做任何持久化措施的情况下，队列和消息都将丢失。要确保消息不丢失，需要配置消息和队列的持久化。

首先配置队列的持久化，生产者和消费者代码都要有队列的声明：
```python
channel.queue_declare(queue='task_queue', durable=True)
```
然后是生产者代码中消息的持久化配置：
```python
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

```python
# 消费者代码中配置
channel.basic_qos(prefetch_count=1)
```
