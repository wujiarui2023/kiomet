# Kiomet Render 云托管部署指南

## 📋 准备工作

### 1. 上传代码到 GitHub
- 把整个 kiomet-main 项目上传到你的 GitHub 仓库
- 确保是**公开仓库**（Render 免费版只能部署公开项目）
- 已经帮你添加好的文件：
  - `Dockerfile` - 多阶段构建配置
  - `.dockerignore` - 优化构建速度
  - `rust-toolchain.toml` - 指定 Nightly Rust

---

## 🚀 部署步骤

### 第一步：注册 Render 账号
1. 访问 **https://render.com**
2. 点击 **"Get Started"**
3. 用 **GitHub 账号**登录（直接授权最方便）

### 第二步：创建 Web Service
1. 登录后，点击右上角 **"New +"** 按钮
2. 选择 **"Web Service"**
3. 在列表中找到你的 kiomet 仓库，点击 **"Connect"**

### 第三步：配置部署参数

| 配置项 | 填写内容 | 说明 |
|--------|----------|------|
| **Name** | `kiomet-game`（随便起） | 会成为你的子域名 |
| **Region** | `Singapore`（新加坡） | 选离你最近的 |
| **Branch** | `main` 或 `master` | 你的主分支名 |
| **Runtime** | **`Docker`** | ⚠️ 一定要选 Docker！ |
| **Dockerfile Path** | `./Dockerfile` | 默认就行 |
| **Docker Context** | `./` | 项目根目录 |

### 第四步：选择套餐
- 往下滑，选择 **"Free"** 套餐
- 免费套餐足够测试用

### 第五步：开始部署
- 点击最下面的 **"Create Web Service"**
- 等待构建和部署（第一次可能需要 **10-20 分钟**，因为要编译 Rust）

---

## ⚠️ 常见问题与解决方案

### 问题 1：端口不对 / 无法访问

**现象**：部署成功但打不开网页

**原因**：kodiak 框架默认用 8443 端口（HTTPS），但 Render 会分配随机端口

**解决方案**：
在 Render 后台添加环境变量：

1. 进入你的服务 → 点击 **"Environment"**
2. 添加环境变量：
   - **Key**: `PORT`
   - **Value**: `8443`（或者框架默认的端口）
3. 保存，等待重新部署

如果还是不行，试试这些端口：`8080`、`3000`、`8000`

---

### 问题 2：构建失败 / 编译错误

**现象**：构建过程中报错

**常见原因和解决**：

#### 原因 A：Git 子模块失败
项目里有 `engine` 子模块，可能不存在或私有。

**解决**：在 Dockerfile 开头添加（跳过子模块）：
```dockerfile
RUN git config --global submodule.recurse false
```

#### 原因 B：依赖下载失败
网络问题导致 cargo 依赖下载慢或失败。

**解决**：多试几次，或者换个构建时间

#### 原因 C：内存不足
Rust 编译很吃内存，免费套餐可能不够。

**解决**：
- 升级到付费套餐（Starter，$7/月）
- 或者换用 Railway（内存更大）

---

### 问题 3：部署后游戏连不上

**现象**：能打开网页，但进不了游戏

**原因**：前端和后端的 WebSocket 连接有问题

**解决**：
如果前端和后端分开部署，需要修改前端的服务器地址。

---

## 🎯 方案二：前后端分离部署（推荐）

你的 PHP 空间放前端，Render 放后端，这样更稳定。

### 后端部署（Render）
按上面的步骤部署，只跑后端服务。

### 前端部署（你的 PHP 空间）

#### 1. 编译前端
你需要在本地编译前端（或者用 GitHub Actions 自动编译）。

**本地编译方法**：
```bash
# 安装 Rust
# 安装 trunk
cargo install --locked trunk --version 0.17.5

# 进入 client 目录
cd client

# 编译前端
trunk build --release
```

#### 2. 修改前端连接地址
编译后，修改 `dist` 里的 JS 文件，把服务器地址改成你的 Render 地址。

或者在编译前修改源码里的服务器地址配置。

#### 3. 上传到 PHP 空间
把 `client/dist/` 目录里的所有文件上传到你的 PHP 空间。

---

## 🔧 备选方案

如果 Render 老是失败，试试这些平台：

### Railway（推荐备选）
- 网址：https://railway.app
- 每月免费额度 $5
- 内存更大，编译更容易成功
- 同样支持 Docker 部署

### Fly.io
- 网址：https://fly.io
- 免费额度够用
- 需要绑信用卡（验证用，不超支不扣费）

### Shuttle
- 网址：https://www.shuttle.dev
- 专门做 Rust 托管
- 但需要本地安装 CLI

---

## 📝 部署检查清单

- [ ] 代码已上传到 GitHub 公开仓库
- [ ] Dockerfile 在项目根目录
- [ ] rust-toolchain.toml 已添加
- [ ] Render 选了 Docker 运行时
- [ ] 端口配置正确
- [ ] 构建日志没有错误
- [ ] 能访问你的服务域名
- [ ] 游戏能正常进入和运行

---

## 💡 提示

1. **第一次构建很慢**：Rust 编译需要时间，耐心等
2. **免费套餐会休眠**：15 分钟没访问会休眠，下次访问需要等几十秒唤醒
3. **看构建日志**：Render 后台有实时日志，出错了先看日志
4. **有问题找我**：把报错截图或日志发给我，我帮你调

---

祝你部署成功！🎮
