---
title: Let's Encrypt免费SSL证书申请指北
categories: 笔记
tags:
  - 运维
ai:
  - 买不起商用证书怎么办，其实个人站点可以选择公益性质的证书机构，免费，够用，只需要稍微花点时间去配置。免费虽好，但需要大家的支持，有条件别忘了捐赠哦。
abbrlink: '6546'
date: 2023-06-07 19:47:08
---

### 基本信息

- 操作系统: CentOS8
- DNS服务商: Cloudflare
- 证书颁发机构: Let's Encrypt [官方网站](https://letsencrypt.org/)

### 配置流程

- 在服务器上安装官方推荐ACME客户端certbot

    ```bash
    # Adding EPEL to CentOS8 Stream
    dnf install epel-release
    dnf upgrade
    
    # install snapd
    yum install snapd
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
    
    # install core 需要退出重新登陆ssh
    snap install core
    snap refresh core
    
    # clean old certbot
    yum remove certbot
    # install certbot
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    ```

- 安装Cloudflare的DNS插件

    [Cloudflare插件](https://certbot-dns-cloudflare.readthedocs.io/en/stable/)

    ```bash
    # install DNS plugin
    snap set certbot trust-plugin-with-root=ok
    snap install certbot-dns-cloudflare
    ```
  
- 使用certbot申请证书

    ```bash
    # 在cloudflare申请DNS edit 权限的 API key
    touch ~/secrets/cloudflare.ini
    chmod 600 ~/secrets/cloudflare.ini
    echo 'dns_cloudflare_api_token = <API key>' > ~/secrets/cloudflare.ini
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/secrets/cloudflare.ini -d aaa.xxx
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/secrets/cloudflare.ini -d bbb.xxx
    certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/secrets/cloudflare.ini -d ccc.xxx
    ```
  
  成功后命令行输出如下

    ```bash
    Successfully received certificate.
    Certificate is saved at: /etc/letsencrypt/live/domain.xxx/fullchain.pem
    Key is saved at:         /etc/letsencrypt/live/domain.xxx/privkey.pem
    This certificate expires on 2023-08-19.
    These files will be updated when the certificate renews.
    Certbot has set up a scheduled task to automatically renew this certificate in the background.
    We were unable to subscribe you the EFF mailing list because your e-mail address appears to be invalid. You can try again later by visiting https://act.eff.org.
    
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    If you like Certbot, please consider supporting our work by:
    * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
      * Donating to EFF:                    https://eff.org/donate-le
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ```

- 查看证书列表

  ```bash
  certbot certificates
  ```

- 删除证书

  ```bash
  certbot delete --cert-name example.com
  ```

---
