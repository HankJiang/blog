---
title: 使用kubeadm搭建集群
categories: 笔记
tags:
  - Kubernetes
ai:
  - 一次使用kubeadm搭建集群的经历。
abbrlink: '8e70'
date: 2023-06-07 21:14:36
---
  
### 前置准备

 - 准备两台服务器，一台做**master**，一台做**slave**，每台机器内存要大于2G。
 - 在命令行通过ufw等防火墙工具开放相关端口，如果使用的是云服务则应去控制台页面进行设置。
 - 确保每台机器已经安装了容器运行时，如docker。

### 1. 安装 kubeadm、kubelet 和 kubectl

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```

### 2. 配置docker的cgroup

编辑`/etc/docker/daemon.json` 增加以下内容

```bash
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

接着执行

```bash
mv /etc/containerd/config.toml /root/config.toml.bak
systemctl restart docker
systemctl restart containerd
```

### 3. 初始化control-plane

```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 #限定Pod网络IP范围
```

成功后控制台输出如下，按照提示执行命令生成kubeconfig

```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

	  export KUBECONFIG=/etc/kubernetes/admin.conf
	
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join xx.x.x.xx:6443 --token xxxxxx.xxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxx
```

### 4. 安装pod网络组件

参考 https://github.com/cni-genie/CNI-Genie/blob/master/docs/GettingStarted.md

```bash
$ curl --insecure -sfL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml | kubectl apply -f -
```

### 5. 控制节点隔离

默认情况下，出于安全原因，集群不会在控制平面节点上调度Pod，如果希望Pod可以在master上调度的话需做下面操作。

```bash
# 查询当前taint,然后移除
kubectl describe node <nodename> | grep Taints
# Taints: node-role.kubernetes.io/control-plane:NoSchedule 
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### 6. 检查确认当前cluster节点状态

```bash
kubectl cluster-info
# Kubernetes control plane is running at https://10.0.0.12:6443
# CoreDNS is running at https://10.0.0.12:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

#To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

kubectl get nodes
#NAME                  STATUS   ROLES           AGE   VERSION
#vm-0-12-opencloudos   Ready    control-plane   41m   v1.27.2
```

至此master节点就完成了

### 7. 加入slave节点

登陆slave机器，执行上述1，2步骤，并配置config文件

```bash
mkdir ~/.kube
vim ~/.kube/config
# 拷贝master的config文件到slave节点
```

然后复制并执行执行master初始化生成的加入命令

```bash
kubeadm join xx.x.x.xx:6443 --token xxxxxx.xxxxxxxx --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxx
```

token默认24h的有效期，如果token失效，执行以下命令重新生成

```bash
kubeadm token create --print-join-command
```

---

### TIPS:

- 遇到 `[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1` 可执行以下指令

    ```bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```

- 遇到`[WARNING FileExisting-tc]: tc not found in system path`

    ```bash
    yum provides tc
    yum install iproute-tc
    ```
- 遇到`Unable to connect to the server: x509: certificate is valid for 10.96.0.1, 172.26.2.101, not <public-ip-address>`

    ```bash
    rm /etc/kubernetes/pki/apiserver.*
    kubeadm init phase certs apiserver --apiserver-cert-extra-sans=<public_ip>
    ```


## 参考资料
[kubernetes官方文档](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/)
[凤凰架构](http://icyfenix.cn/appendix/deployment-env-setup/setup-kubernetes/setup-kubeadm.html)
