---
title: mac环境postgresql安装以及常用命令
categories: 笔记
tags:
  - 数据库
ai:
  - mac环境postgresql使用笔记。
date: 2024-02-28 22:10:00
---

### 安装

查看版本列表
```bash
> brew search postgres
==> Formulae
check_postgres          postgresql@12           postgresql@15           qt-postgresql
postgresql@10           postgresql@13           postgresql@16          postgis
postgresql@11           postgresql@14           postgrest
```

选择一个版本进行安装
```bash
> brew install postgresql@16  
This formula has created a default database cluster with:
  initdb --locale=C -E UTF-8 /usr/local/var/postgresql@16
For more details, read:
  https://www.postgresql.org/docs/16/app-initdb.html

postgresql@16 is keg-only, which means it was not symlinked into /usr/local,
because this is an alternate version of another formula.

If you need to have postgresql@16 first in your PATH, run:
  echo 'export PATH="/usr/local/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc

For compilers to find postgresql@16 you may need to set:
  export LDFLAGS="-L/usr/local/opt/postgresql@16/lib"
  export CPPFLAGS="-I/usr/local/opt/postgresql@16/include"

For pkg-config to find postgresql@16 you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/postgresql@16/lib/pkgconfig"

To start postgresql@16 now and restart at login:
  brew services start postgresql@16
Or, if you don't want/need a background service you can just run:
  LC_ALL="C" /usr/local/opt/postgresql@16/bin/postgres -D /usr/local/var/postgresql@16
```

配置环境变量并启动
```bash
> echo 'export PATH="/usr/local/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
> brew services start postgresql@16
```

### 初始化用户和数据库

创建用户
```bash
> createuser -s postgres
```

进入命令行
```bash
> psql -U postgres
```

创建数据库
```bash
postgres=# create database hobby_dating;
CREATE DATABASE
```

查看数据库
```bash
postgres=# \l
                                                    List of databases
     Name     |  Owner   | Encoding | Locale Provider | Collate | Ctype | ICU Locale | ICU Rules |   Access privileges
--------------+----------+----------+-----------------+---------+-------+------------+-----------+-----------------------
 hobby_dating | postgres | UTF8     | libc            | C       | C     |            |           |
```

进入数据库
```bash
postgres=# \c hobby_dating
You are now connected to database "hobby_dating" as user "postgres".
```





