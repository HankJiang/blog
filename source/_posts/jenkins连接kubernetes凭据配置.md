---
title: jenkins连接kubernetes凭据配置
categories: 笔记
tags:
  - 运维
  - Jenkins
  - Kubernetes
ai:
  - 使用jenkins做kubernetes的持续集成可能会遇到的一个问题。
abbrlink: acc8
date: 2023-06-07 21:41:45
---

### 安装证书工具

安装cfssl，此工具生成证书非常方便， pem证书与crt证书，编码一致可直接使用。

```bash
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
```

### 准备证书签名请求

```bash
vim admin-csr.json
```

内容如下

```bash
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "ShangHai",
      "L": "XS",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
```

证书请求中的`O`指定该证书的Group为`system:masters`
而RBAC预定义的ClusterRoleBinding将Group`system:masters`与ClusterRole`cluster-admin`绑定，这就赋予了该证书具有所有集群权限。

### 创建证书和私钥

```bash
cfssl gencert -ca=/etc/kubernetes/pki/ca.crt -ca-key=/etc/kubernetes/pki/ca.key --profile=kubernetes admin-csr.json | cfssljson -bare admin
```

会生成以下3个文件：

```bash
admin.csr
admin-key.pem
admin.pem
```

### 生成pkc格式证书

可以通过openssl来转换成pkc格式

```bash
openssl pkcs12 -export -out ./jenkins-admin.pfx -inkey ./admin-key.pem -in ./admin.pem -passout pass:<secret>
```

最后将证书文件`jenkins-admin.pfx`上传到jenkins，填入设置的`secret`后jenkins会展示解析的部分证书信息，表明凭据已经配置成功。

