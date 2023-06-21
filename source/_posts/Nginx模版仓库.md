---
title: Nginx模版仓库
categories: 笔记
tags:
  - 运维
  - Nginx
ai:
  - 个人使用的一些Nginx模版。
abbrlink: 7a8d
date: 2023-06-07 22:13:17
---

### 1. http + https 反向代理
```bash
server {
  listen 80;
  server_name <domain>;

  # Redirect all traffic to SSL
  rewrite ^ https://$server_name$request_uri? permanent;
}

server {
  listen 443;

  # enables SSLv3/TLSv1, but not SSLv2 which is weak and should no longer be used.
  proxy_ssl_protocols TLSv1.2 TLSv1.3;
  proxy_ssl_ciphers DEFAULT;

  server_name <domain>;

  ## Access and error logs.
  access_log /var/log/nginx/access.log;
  error_log  /var/log/nginx/error.log info;

  ## Keep alive timeout set to a greater value for SSL/TLS.
  keepalive_timeout 75 75;

  ## See the keepalive_timeout directive in nginx.conf.
  ## Server certificate and key.
  ssl on;
  ssl_certificate <path-to-ssl-cert>;
  ssl_certificate_key <path-to-ssl-key>;
  ssl_session_timeout  5m;
  ssl_prefer_server_ciphers on;

  ## Strict Transport Security header for enhanced security. See
  ## http://www.chromium.org/sts. I've set it to 2 hours; set it to
  ## whichever age you want.
  add_header Strict-Transport-Security "max-age=7200";
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;

  location / {
    proxy_pass http://<local-or-remote-addr>:<port>;
  }
}
```
