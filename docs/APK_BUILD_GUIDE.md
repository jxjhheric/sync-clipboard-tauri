# APK 构建指南

## 📱 概述

本指南详细说明如何使用 GitHub Actions 自动构建 Android APK 文件。

## 🚀 快速开始

### 1. 准备工作

确保你的项目已经配置了：
- ✅ Tauri 2.0 项目
- ✅ Android 开发环境
- ✅ GitHub 仓库

### 2. 配置签名密钥

#### 方法一：使用生成脚本（推荐）

```bash
# 运行 keystore 生成脚本
./scripts/generate-keystore.sh
```

#### 方法二：手动生成

```bash
# 生成 keystore
keytool -genkeypair \
    -keystore upload-keystore.jks \
    -alias upload \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass your-password \
    -keypass your-password \
    -dname "CN=Sync Clipboard Tauri, OU=Development, O=Sync Clipboard, L=City, S=State, C=CN"

# 转换为 Base64
base64 -w 0 upload-keystore.jks
```

### 3. 配置 GitHub Secrets

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加：

- `ANDROID_KEYSTORE_BASE64`: keystore 文件的 Base64 编码
- `ANDROID_KEYSTORE_PASSWORD`: keystore 密码

## 🔧 构建工作流

### 工作流文件

| 文件 | 用途 | 触发条件 |
|------|------|----------|
| `build-apk.yml` | 专用 APK 构建 | 手动触发 + 自动触发 |
| `auto-build.yml` | 自动构建 | 推送到 dev 分支 |
| `release.yml` | 发布流程 | 手动触发（main 分支） |

### 构建选项

#### 支持的架构

| 架构 | 目标 | 说明 |
|------|------|------|
| ARM64 | `aarch64-linux-android` | 现代设备，推荐 |
| ARM32 | `armv7-linux-androideabi` | 老旧设备 |
| x64 | `x86_64-linux-android` | 模拟器/平板 |
| x86 | `i686-linux-android` | 32位模拟器 |

#### 构建类型

| 类型 | 用途 | 签名 |
|------|------|------|
| Release | 生产发布 | 需要配置 keystore |
| Debug | 测试调试 | 默认签名 |

## 📋 使用方法

### 1. 手动构建

1. 进入 GitHub Actions 页面
2. 选择 "📱 构建 APK (Build APK)"
3. 点击 "Run workflow"
4. 选择构建参数
5. 等待构建完成
6. 下载 Artifacts 中的 APK

### 2. 自动构建

推送代码到以下分支会自动触发构建：
- `ci-github-actions-build-apk`
- `develop`
- `feature/*`

## 📦 构建产物

### 文件命名规则

```
sync-clipboard-tauri-{version}-{arch}-{type}-{timestamp}.apk
```

示例：
- `sync-clipboard-tauri-0.1.2-arm64-v8a-20241106-234500.apk`
- `sync-clipboard-tauri-0.1.2-armeabi-v7a-debug-20241106-234500.apk`

### 下载位置

构建完成后，APK 文件会作为 Artifact 上传：
- 保留期：30 天
- 位置：Actions 页面 > 对应运行 > Artifacts

## 🛠️ 本地构建

### 环境准备

```bash
# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add aarch64-linux-android

# 安装 Node.js 和 pnpm
npm install -g pnpm
pnpm install

# 安装 Android SDK 和 NDK
# 使用 Android Studio 或手动安装
```

### 构建命令

```bash
# Debug 版本
pnpm tauri android build --apk --target aarch64-linux-android --debug

# Release 版本
pnpm tauri android build --apk --target aarch64-linux-android
```

## 🔍 故障排除

### 常见问题

#### 1. 构建失败：NDK 错误

**症状**: 构建时提示 NDK 相关错误

**解决方案**:
```bash
# 检查 NDK 是否正确安装
echo $ANDROID_NDK_ROOT

# 重新安装 NDK
# 在 Android Studio 的 SDK Manager 中安装 NDK
```

#### 2. 签名错误

**症状**: Release 构建失败，提示签名相关错误

**解决方案**:
1. 检查 GitHub Secrets 配置
2. 验证 keystore 文件是否正确
3. 确认密码是否匹配

#### 3. 依赖问题

**症状**: 前端依赖安装失败

**解决方案**:
```bash
# 清理缓存
pnpm store prune
rm -rf node_modules
rm pnpm-lock.yaml
pnpm install
```

#### 4. 权限错误

**症状**: Actions 运行时权限不足

**解决方案**:
1. 检查仓库权限设置
2. 确保 Actions 已启用
3. 检查 Secrets 访问权限

### 调试技巧

#### 1. 查看详细日志

在 GitHub Actions 页面：
1. 点击失败的构建
2. 展开失败的步骤
3. 查看详细错误信息

#### 2. 本地复现

```bash
# 使用相同的构建命令
pnpm tauri android build --apk --target aarch64-linux-android

# 检查环境变量
echo $NDK_HOME
echo $ANDROID_HOME
```

#### 3. 清理构建缓存

```bash
# 清理 Rust 缓存
cargo clean

# 清理 Tauri 生成文件
rm -rf src-tauri/target

# 清理 Android 构建文件
rm -rf src-tauri/gen/android/app/build
```

## 📚 参考资源

- [Tauri Android 文档](https://tauri.app/v1/guides/building/android/)
- [Android NDK 指南](https://developer.android.com/ndk/guides)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

## 🆘 获取帮助

如果遇到问题：

1. 查看本指南的故障排除部分
2. 检查 GitHub Actions 的详细日志
3. 搜索相关的 GitHub Issues
4. 在项目仓库中创建 Issue

---

## 📝 更新日志

- 2024-11-06: 初始版本，支持多架构构建
- 添加了自动触发和手动触发选项
- 集成了构建摘要和产物管理