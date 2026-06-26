# Kiomet 游戏 Docker 部署文件
# 多阶段构建：前端 + 后端

# ==================== 阶段 1：构建前端 ====================
FROM rust:nightly AS client-builder

WORKDIR /app

# 安装 trunk（WebAssembly 打包工具）
RUN cargo install --locked trunk --version 0.17.5

# 复制项目文件
COPY . .

# 编译前端（release 模式）
WORKDIR /app/client
RUN trunk build --release

# ==================== 阶段 2：构建后端 ====================
FROM rust:nightly AS server-builder

WORKDIR /app

# 复制整个项目
COPY . .

# 从前一阶段复制编译好的前端文件
COPY --from=client-builder /app/client/dist ./client/dist

# 编译后端（release 模式）
WORKDIR /app/server
RUN cargo build --release

# ==================== 阶段 3：运行时镜像 ====================
FROM debian:bookworm-slim

# 安装必要的运行时依赖
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 从构建阶段复制编译好的后端二进制
COPY --from=server-builder /app/server/target/release/server .

# 暴露端口（Render 会自动通过 PORT 环境变量分配）
EXPOSE 8080

# 启动命令
CMD ["./server"]
