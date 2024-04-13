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

### 搭建NFS服务器(CentOS)

1. **在Master节点上安装NFS服务**：
    - 使用终端登录到Master节点。
    - 安装NFS服务：
      ```bash
      sudo yum install nfs-utils
      sudo systemctl enable nfs-server
      sudo systemctl start nfs-server
      ```

2. **配置NFS共享**：
    - 编辑NFS的导出文件`/etc/exports`，添加以下行：
      ```
      /disk-a *(rw,sync,no_root_squash,no_subtree_check)
      ```
      这里`/disk-a`是要共享的目录，`*`表示允许所有客户端访问，`rw`表示读写权限，`sync`表示同步写入磁盘，`no_root_squash`表示远程root用户具有root权限，`no_subtree_check`提高性能。
    - 应用配置更改：
      ```bash
      sudo exportfs -a
      sudo systemctl restart nfs-server
      ```

3. **开放相关端口**：
   NFS服务需要开放一些端口才能正常工作。NFS在Linux系统中通常使用以下端口：
   - **TCP/UDP 2049**: NFS本身的端口。
   - **TCP/UDP 111**: RPC绑定端口，用于客户端发现NFS服务的端口号。
   - **TCP/UDP 20048**: NFS mountd守护进程，用于挂载请求。
   - **TCP 1110** 和 **UDP 32767**: nlockmgr（NFS锁管理器）。
   可以使用相关防火墙命令开放端口，如果使用云服务，可以在服务器控制台进行配置。

4. **在所有节点上配置NFS客户端**：
    - 在所有slave节点上安装NFS客户端：
      ```bash
      sudo yum install nfs-utils
      ```
    - 测试挂载是否成功：
      ```bash
      sudo mkdir -p /mnt/disk-a
      sudo mount -t nfs <master-node-ip>:/disk-a /mnt/disk-a
      ```
      将`<master-node-ip>`替换为您的Master节点的IP地址。

5. **在Kubernetes中配置Persistent Volumes (PV) 和 Persistent Volume Claims (PVC)**：
    - 创建一个Persistent Volume (PV) 配置文件`nfs-pv.yaml`：
      ```yaml
      apiVersion: v1
      kind: PersistentVolume
      metadata:
        name: nfs-pv
      spec:
        capacity:
          storage: 100Gi
        accessModes:
          - ReadWriteMany
        nfs:
          path: /disk-a
          server: <master-node-ip>
        persistentVolumeReclaimPolicy: Retain
      ```
    - 创建一个Persistent Volume Claim (PVC) 配置文件`nfs-pvc.yaml`：
      ```yaml
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: nfs-pvc
      spec:
        accessModes:
          - ReadWriteMany
        resources:
          requests:
            storage: 100Gi
        volumeName: nfs-pv
      ```
    - 应用这些配置文件：
      ```bash
      kubectl apply -f nfs-pv.yaml
      kubectl apply -f nfs-pvc.yaml
      ```
