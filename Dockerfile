# 用 Rust Nightly 镜像
FROM rustlang/rust:nightly AS builder

# 安装 trunk（编译前端用）
RUN cargo install --locked trunk --version 0.17.5

# 添加 WebAssembly 目标
RUN rustup target add wasm32-unknown-unknown

# 设置工作目录
WORKDIR /app

# 先复制 Cargo.toml 缓存依赖
COPY Cargo.toml Cargo.lock ./
COPY client/Cargo.toml client/Cargo.toml
COPY server/Cargo.toml server/Cargo.toml
COPY common/Cargo.toml common/Cargo.toml
COPY macros/Cargo.toml macros/Cargo.toml

# 创建空的 src 目录来缓存依赖
RUN mkdir -p client/src server/src common/src macros/src \
    && echo "fn main() {}" > client/src/main.rs \
    && echo "fn main() {}" > server/src/main.rs \
    && echo "" > common/src/lib.rs \
    && echo "" > macros/src/lib.rs

# 缓存依赖构建
RUN cargo build --release -p server || true

# 复制全部源码
COPY . .

# 编译前端
RUN cd client && trunk build --release

# 编译服务端
RUN cargo build --release -p server

# 运行阶段
FROM debian:bookworm-slim

# 安装必要的运行时库
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# 复制编译好的服务端
COPY --from=builder /app/target/release/server /usr/local/bin/server

# 暴露端口（kodiak 默认端口，根据实际情况调整）
EXPOSE 8080

# 启动命令
CMD ["server"]
