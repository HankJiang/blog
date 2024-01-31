---
title: 搭建NFS服务器
categories: 笔记
tags:
  - 运维
ai:
  - 为了解决k8s集群节点间共享文件（pv）问题，于是决定在一台机器上搭建NFS服务。
date: 2024-01-30 22:32:06
---

### 需求背景与架构
最近想要在集群内搭建一个jupyterhub，在使用官方helm部署的时候遇到问题，由于本博客所在集群是自建的，之前
没有持久化挂载的需求，因此集群内并没有创建默认的StorageClass。

部署时发现pod未能启动成功：
```bash
> k get pods
   NAME                              READY   STATUS    RESTARTS   AGE
   hub-75796fd77c-68z57              0/1     Pending   0          4h4m
   proxy-5b89d9c486-rdrkb            1/1     Running   0          4h4m
```

从event可以看出，是由于没有持久化卷导致的：
```bash
> k describe pod hub-75796fd77c-68z57
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  11m (x47 over 4h1m)  default-scheduler  0/2 nodes are available: pod has 
    unbound immediate PersistentVolumeClaims. preemption: 0/2 nodes are available: 2 No preemption 
    victims found for incoming pod..

> k get sc
No resources found
```
于是接下来要做的是为集群或者说jupyterhub创建一个持久化的挂载点，用于存储各种用户数据。

接下来说一下架构。本博客以及其他自建工具都位于k8s自建集群中，该集群由一个master节点和一个slave节点共同构成，为了发挥k8s自身的调度作用，
所有pod均未绑定pod，基于通用性和安全性的原则，此pv需要满足以下需求

 - 数据安全，即使服务器到期回收了，集群删除了，之前产生的数据还在，不受系统环境的影响。
 - 数据访问，为了最大化利用资源，该pv在物理上可以被集群内所有节点访问（每个节点挂载一个就太浪费了，而且不方便管理）。

基于以上需求，挂载点就不能位于系统盘，需要独立的挂载盘，并且在该挂载盘所挂载的服务器上搭建NFS服务。

基本思路确定，接下来开始搭建！

### 搭建NFS服务器

trigger3