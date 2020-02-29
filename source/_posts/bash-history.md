---
title: bash历史执行命令的各种骚操作
date: 2020-02-29 07:18:44
categories:
- Linux
tags:
- commands
thumbnail: /gallery/penguins-01.png
---

在bash命令行中，会记录历史执行的命令，使用history命令可以查看，在bash环境中，对历史命令的操作非常强大，熟悉这些用法后可以非常高效地在bash命令行中工作。

对历史命令的操作分为三个层次，第一个是获取到历史命令，用到的命令（字符）称为`Event designators`；第二个是获取到命令中的特定字符，用到的命令称为`Word designators`；第三个是对字符进行操作，用到的命令称为`Modifiers`。

首先使用history命令查看历史执行命令：
```sh
$ history
1 tar czvf etc.tar.gz /etc/
2 cp /etc/passwd /backup
3 ps -ef | grep docker
4 systemctl restart sshd
5 /usr/local/apache2/bin/apachectl restart
6 ls -F
7 whoami
```

## Event designators

使用`!n`命令通过命令编号获取历史执行过的命令：
```sh
$ !!
whoami
user01
$ !-1
whoami
user01
$ !4
systemctl restart sshd
$ !-2
ls -F
1.txt  2.txt  helloworld.txt  start.sh*  test01/  test02/
```

使用`!string`（以指定字符串开头的命令）和`!?string`（包含指定字符串的命令）获取历史执行过的命令：
```sh
$ !ps
ps -ef | grep docker
$ !?apache
/usr/local/apache2/bin/apachectl restart
```

使用`^str1^str2^`从前一条命令中取代字符：
```sh
$ ls /etc/cron.daily/logrotate
$ ^ls^cat^
cat /etc/cron.daily/logrotate
```

## Word Designators

Word Designators在你想要输入一个新的命令但使用之前执行的命令用过的参数时非常有用。

```sh
$ cp /etc/passwd /backup
$ ls -l !cp:^  # 使用^获取第一个参数
ls -l /etc/passwd

$ cp /etc/passwd /backup
$ ls -l !cp:$  # 使用$获取最后一个参数
ls -l /backup

$ tar czvf /backup/home-dir-backup.tar.gz /home
$ ls -l !tar:2  # 获取指定位置的参数
ls -l /backup/home-dir-backup.tar.gz

$ cp /etc/passwd /backup
$ ls -l !cp:*  # 使用*获取所有参数
ls -l /etc/passwd /backup

$ tar cvf home-dir.tar john jason ramesh rita
$ ls -l !tar:3-5  # 获取指定范围内的参数
ls -l john jason ramesh
```

+ `!!:*`, 从前一个命令中获取所有参数
+ `!!:2*`, 从前一个命令中获取从第二个参数开始后的所有参数
+ `!!:2-$`, 和上一个命令相同
+ `!!:2-`, 从第二个参数开始后到倒数第二个参数，即不包括最后一个参数

使用`!%`获取最近搜索到的命令中匹配到的字符：
```sh
$ /usr/local/apache2/bin/apachectl restart
$ !?apache
/usr/local/apache2/bin/apachectl restart
$ !% stop  # !%获取前一个!?命令字符串匹配到的整个词
/usr/local/apache2/bin/apachectl stop
```

## Modifers

```sh
$ ls -l /very/long/path/name/file-name.txt
$ ls -l !!:$:h  # :h的功能是删除路径中最后的位置
ls -l /very/long/path/name

$ ls -l /very/long/path/name/file-name.txt
$ ls -l !!:$:t  # :t的功能是保留路径最后的位置
ls -l file-name.txt

$ ls -l /very/long/path/name/file-name.txt
$ ls -l !!:$:r  # :r的功能是移除文件的后缀
ls -l /very/long/path/name/file-name
```

使用`:s`像sed一样对字符进行替换：
```sh
$ ls 1.txt 2.txt 1.txt
$ !!:s/1.txt/3.txt/  # 替换第一个匹配的字符串
ls 3.txt 2.txt 1.txt

$ cp /etc/password /backup/password.bak
$ !!:gs/password/passwd/  # 全局替换
cp /etc/passwd /backup/passwd.bak
```

使用`&`快速重复上一个替换：
```sh
$ tar cvf password.tar /etc/password
$ !!:g&
```

使用`:p`不执行，只打印命令：
```sh
$ tar cvf home-dir.tar john jason ramesh rita
$ tar cvfz new-file.tar !tar:3-:p
tar cvfz new-file.tar john jason ramesh
```
