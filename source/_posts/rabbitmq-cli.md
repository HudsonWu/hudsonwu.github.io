---
title: rabbitmq命令行工具
date: 2020-03-02 14:19:44
categories:
- Others
tags:
- commands
thumbnail: /gallery/rabbitmq.png
---

+ rabbitmqctl, 用于服务管理以及一般操作任务
+ rabbitmq-diagnostics, 用于诊断和健康检查
+ rabbitmq-plugins, 用于插件管理
+ rabbitmq-queues, 用于队列上的维护任务，特别是quorum queues
+ rabbitmqadmin, 用于HTTP API的操作任务

## 常用命令

```
# 查看有多少队列以及每个队列中的消息数(messages)
rabbitmqctl list_queues
# 自定义显示队列
rabbitmqctl list_queues name messages_ready messages_unacknowledged

# 列出exchanges
rabbitmqctl list_exchanges
# 列出现有的exchange和队列的绑定(bindings)
rabbitmqctl list_bindings
```

### 用户管理

```
# 列出用户
rabbitmqctl list_users
# 新建用户
rabbitmqctl add_user username passwd
# 删除用户
rabbitmqctl delete_user username
# 修改密码
rabbitmqctl change_password username newpasswd
# 设置用户角色(tag可以为administrator, monitoring, management)
rabbitmqctl set_user_tags username tagname1 tagname2
```

## rabbitmqctl

rabbitmqctl是rabbitmq附带的原生cli工具，支持很多操作，主要是管理性质的，包括：
  + 停止节点
  + 访问节点状态、有效配置以及健康检查
  + 虚拟主机管理
  + 用户和权限管理
  + 策略管理
  + queues、connections、channels、exchanges、consumers查看
  + 集群成员管理

## Further reading

+ [官方文档](https://www.rabbitmq.com/cli.html)
