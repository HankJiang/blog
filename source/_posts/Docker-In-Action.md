---
title: Docker In Action
categories: 笔记
tags:
  - Docker
ai:
  - 使用Docker的过程中遇到的各种场景和问题，以及解决方案。
abbrlink: d499
date: 2023-06-07 21:01:44
---

### 1. 如何在CentOS环境安装docker？

```bash
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl start docker
# 验证是否安装成功
docker -v
```

### 2. 如何将本地镜像推送到dockerhub？

```bash
docker login -u <username> -p <token>
docker tag <local-image-id> <remote-username>/<reponame:version>
docker push <remote-username>/<reponame:version>
```
