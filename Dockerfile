# ======= 缓存 =======
FROM node:13 as builder

WORKDIR /app
COPY package.json .
RUN npm install hexo-renderer-pug hexo-renderer-stylus --save
RUN npm install

# ======= 构建 =======
FROM node:13

ENV HEXO_SsERVER_PORT=4000
ENV GIT_USER="HankJiang"
ENV GIT_EMAIL="jianghan.ah@foxmail.com"

# 安装依赖
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN \
 apt-get update && \
 apt-get install git -y && \
 npm install -g hexo-cli

WORKDIR /app
COPY --from=builder /app/ /app/
COPY . .
CMD ['npm', 'start']

# 暴露端
EXPOSE ${HEXO_SERVER_PORT}

# 运行指令
CMD hexo server -p ${HEXO_SERVER_PORT}
