---
title: 建站日志
date: 2023-06-01 15:57:51
aside: false
top_img: false
comments: false
---

{% timeline Timeline,orange %}

<!-- timeline 2023-05-18 -->
- 突然产生将很久以前半途而废的博客重新搭建起来的想法。
- 简单确认了站点架构，就用k8s了，就是折腾。
- 检查之前购买的云服务器的状况，发现即将到期，需租用新的。
<!-- endtimeline -->

<!-- timeline 2023-05-19 -->
- 租了两台位于新加坡的轻量服务器，一台2核4G做**master**，一台2核2G做slave。
- 开始手动搭建k8s集群，选择合适的组件，遇到n多问题。
<!-- endtimeline -->

<!-- timeline 2023-05-22 -->
- 终于将k8s搭建完成，目前只是一个空壳，但可以使用了。
<!-- endtimeline -->

<!-- timeline 2023-05-25 -->
- 在nameslio购买域名gsxxm.xyz。
- https得要啊，但是商业TLS证书可太贵了，找了下用letsencrypt+Certbot手动申请证书。
- 为了方便证书申请，注册clouldflare用其DNS解析，顺带做站点防护。
- 域名绑定了！证书也有了！
<!-- endtimeline -->

<!-- timeline 2023-05-26 -->
- 项目初始化并上传到github。
- 清理本地开发环境，配置一些效率工具。
- 登陆尘封已久的dockerhub账号，清理空间。
- 简单把Jenkins加入集群，CICD就靠它了。
<!-- endtimeline -->

<!-- timeline 2023-05-29 -->
- 调试Jenkins pipline。
- `hexo`->`github hook`->`jenkins`->`dockerhub`->`jenkins`->`kubernetes` CICD打通！
- 网站可以通过https://gsxxm.xyz访问了!
<!-- endtimeline -->

<!-- timeline 2023-06-01 -->
- 打算给站点换了个主题然后慢慢根据需求调整。
- 选了hexo-theme-anzhiyu，感谢作者，已star✨。
- 儿童节快乐～
<!-- endtimeline -->

<!-- timeline 2023-06-03 -->
- 配置CDN，还是用cloudflare，避免ba。
- 配置站点信息，移除一些不用的组件，剩下的后续再慢慢改吧。
<!-- endtimeline -->

<!-- timeline 2023-06-06 -->
- 增加feature: 相册集现在可以通过iframe播放流媒体了。
<!-- endtimeline -->

{% endtimeline %}
