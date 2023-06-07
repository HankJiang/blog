---
title: Git In Action
categories: 笔记
tags:
  - Git
ai:
  - 使用Git的过程中遇到的各种场景和问题，以及解决方案。
abbrlink: c223
date: 2023-06-07 18:33:00
---

### 1. 如何配置SSH以及初始化仓库？

- 为每个账号生成密钥对

  ```bash
  > cd ~/.ssh
  > ssh-keygen -t rsa -C "account1@youremail.com"
  > ssh-keygen -t rsa -C "account2@youremail.com"
  # 生成过程可以指定密钥对的文件名，用于区分用途。
  > ls
  id_rsa_account1 id_rsa_account1.pub id_rsa_account2 id_rsa_account2.pub
  ```

- 注册生成的密钥对

  ```bash
  > ssh-add -D # 可以先清空缓存
  > ssh-add ~/.ssh/id_rsa_account1
  > ssh-add ~/.ssh/id_rsa_account2
  ```

- 配置 ssh config

  ```bash
  > cd ~/.ssh
  > vim config # 如果之前没有配置过，手动创建，参考如下文件内容
  Host self
     HostName github.com
     IdentityFile ~/.ssh/id_rsa_account1

  Host company
     HostName xxx.com
     IdentityFile ~/.ssh/id_rsa_account2
  ```
  **config 文件配置项解释**

    | 字段         | 描述             | 示例                     |
    | ------------ | ---------------- | ------------------------ |
    | Host         | 任意别名         | self，company            |
    | HostName     | 仓库地址         | github.com， xx.xx.xx.xx |
    | IdentityFile | 本地私钥文件路径 | ~/.ssh/id_rsa            |
    | User         | 用户             | 默认 root                |
    | Port         | 端口             | 默认 22                  |

- 去 github 配置公钥

    - 登录 github 账号 -> Settings -> SSH and GPG keys -> New SSH key
    - 将本地 `~/.ssh/id_rsa_accountX.pub` 公钥内容粘贴进表单并提交

- 配置仓库

    ```bash
    # 新仓库
    > git clone git@{configed_host}:{remote_user}/{remote_project}.git your_local_project_dir
    # 已有仓库
    > cd local_project
    > git remote set-url origin git@{configed_host}:{remote_user}/{remote_project}.git
    ```

- 测试验证

    ```bash
    # 对本地项目做一些更改
    > git add .
    > git commit -m "your comments"
    > git push
    ```

