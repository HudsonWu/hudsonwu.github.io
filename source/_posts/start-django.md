---
title: 开始使用django
date: 2020-03-06 01:28:17
categories:
- Code
tags:
- python
thumbnail: /gallery/django.png
---

一个django项目可以有多个application，一个application可以有多个model，一个model会映射到后端数据库的一张表中。这篇文章会介绍如何如何创建django项目、如何删除所有数据库表以及如何完全删除application。

## 安装和创建项目

```
# 查看django是否已经安装
python3 -m pip show django

# 安装指定版本的django
python3 -m pip install django==3.0

# 创建项目
# 项目创建成功后在settings.py文件正确配置
django-admin startproject mysite

# 创建app
# 创建好后在项目settings.py文件的INSTALLED_APPS中添加app
cd mysite && python3 manage.py startapp app1
```

## models

```
# 检查是否有model更新
python3 manage.py makemigrations
python3 manage.py makemigrations app1  # 查看指定app

# 根据model更新数据库表
python3 manage.py migrate
python3 manage.py migrate app1  # 生成指定app的数据库表

# 创建admin页面的super user
python3 manage.py createsuperuser

# 启动web服务
# 默认服务器页面http://127.0.0.1:8000/
# 默认服务器admin页面http://127.0.0.1:8000/admin
python3 manage.py runserver
python3 manage.py runserver 0:8088  # 自定义网卡和端口
```

## 调试

```
# 查看django版本
python3 -m django --version

# 执行python命令
python3 -c 'import channels; print(channels.__version__)'

# 打开django shell
python3 manage.py shell
```

## 从项目中移除app1

1. 删除数据库中app1对应的表
2. 删除settings.py文件`INSTALLED_APPS`中的添加的app1
3. `python3 manage.py makemigrations`
4. `python3 manage.py migrate app1`
5. 删除app1文件夹

# django项目管理命令

```
# 清空数据库中所有表的数据
python3 manage.py flush
# 直接清空，不输出提示
python3 manage.py flush --noinput

# 从fixture中导入数据到数据库
python3 manage.py loaddata yourapp/fixtures/xxx.json
```
