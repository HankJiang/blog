FROM node:13

MAINTAINER JiangHan <jianghan.ah@foxmail.com>

# 默认服务端口
ENV HEXO_SERVER_PORT=4000
# Git账号
ENV GIT_USER="HankJiang"
ENV GIT_EMAIL="jianghan.ah@foxmail.com"

# 安装依赖
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN \
 apt-get update && \
 apt-get install git -y && \
 npm install -g hexo-cli

# 设置工作目录
WORKDIR /app
COPY . .

RUN npm install --force

# 暴露端口号
EXPOSE ${HEXO_SERVER_PORT}

# 运行指令
CMD hexo server -p ${HEXO_SERVER_PORT}
