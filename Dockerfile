# ======= 缓存 =======
FROM node as builder

WORKDIR /app
COPY package.json .
RUN npm install

# ======= 构建 =======
FROM node

ENV HEXO_SsERVER_PORT=4000

# 安装依赖
RUN npm cache clear --force && \
    npm install -g hexo-cli

WORKDIR /app
COPY --from=builder /app/ /app/
COPY . .

# 暴露端
EXPOSE ${HEXO_SERVER_PORT}

# 运行指令
CMD hexo server -p ${HEXO_SERVER_PORT}
