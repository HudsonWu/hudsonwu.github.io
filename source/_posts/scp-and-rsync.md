---
title: 使用scp或者rsync进行文件传输
date: 2020-03-05 04:42:23
categories:
- Linux
tags:
- commands
thumbnail: /gallery/filetransfer.jpg
---

rsync(remote sync), 一款非常灵活的网络同步工具，已经在目的地的内容不会进行传输，而且在连接中断的情况下，会重新发出相同的命令来快速恢复。在备份和增量传输方面是一个强大的工具。

scp(secure copy), 基于ssh协议，是一个转储拷贝，完全拷贝内容，适合小文件传输。

## 使用scp进行文件传输的例子

```
# -r, 复制目录下所有文件
# -p, 显示预估时间和传输速率
# -v, 提供调试信息
# -C, 运行过程中压缩文件，节省时间
scp -rpv /datafile username1@192.168.1.100:/home/username1
scp -Crp /datafile username1@192.168.1.100:/home/username1
```

## 使用rsync进行文件传输的例子

```
# -a, 归档模式，递归地复制文件及其文件权限、符号链接等
# -z, 传输过程中压缩文件数据
# -v, 提供调试信息
# -h, human-readable
# -e, 定义传输使用的协议

# 将目录复制过去
rsync -azvh /datafile username1@192.168.1.100:/home/username1

# 将目录里的内容复制过去
rsync -azvh --progress /datafile/ username1@192.168.1.100:/home/username1/dir1

# 指定ssh协议
rsync -azvhe 'ssh -p 300' /datafile username1@192.168.1.100:/home/username1/dir1

# 指定要复制的文件
rsync -azvh --include 'A*' --exclude '*' username1@192.168.1.100:/home/username1/dir1/ /dir2
```
