# GitHub Actions 工作流说明

## 📱 APK 构建工作流 (`build-apk.yml`)

这个工作流专门用于构建 Android APK 文件，支持多种触发方式和构建选项。

### 🚀 使用方法

#### 1. 手动触发（推荐）

1. 进入 GitHub 仓库的 **Actions** 页面
2. 选择 **📱 构建 APK (Build APK)** 工作流
3. 点击 **Run workflow**
4. 选择构建参数：
   - **构建目标**: 选择要构建的 CPU 架构
     - `aarch64-linux-android` (ARM64, 推荐)
     - `armv7-linux-androideabi` (ARM32)
     - `x86_64-linux-android` (x64)
     - `i686-linux-android` (x86)
   - **发布类型**: 选择构建类型
     - `release` (正式版, 默认)
     - `debug` (调试版)

#### 2. 自动触发

工作流会在以下情况自动触发：

- **推送代码**到以下分支：
  - `ci-github-actions-build-apk`
  - `develop`
  - `feature/*`

- **创建 Pull Request**到以下分支：
  - `main`
  - `develop`

### 📋 构建产物

构建完成后，APK 文件会作为 **Artifact** 上传，文件名格式：

```
sync-clipboard-tauri-{version}-{arch}-{type}-{timestamp}.apk
```

例如：
- `sync-clipboard-tauri-0.1.2-arm64-v8a-20241106-234500.apk`
- `sync-clipboard-tauri-0.1.2-armeabi-v7a-debug-20241106-234500.apk`

### 🔧 配置要求

为了构建 **Release** 版本的 APK，需要在仓库设置中配置以下 Secrets：

- `ANDROID_KEYSTORE_BASE64`: Base64 编码的 Android Keystore 文件
- `ANDROID_KEYSTORE_PASSWORD`: Keystore 密码

如果没有配置这些 Secrets，工作流仍然会运行，但只能构建 Debug 版本。

### 🏗️ 多架构构建

选择 `all` 作为构建目标时，会同时构建所有支持的架构：
- ARM64 (arm64-v8a)
- ARM32 (armeabi-v7a) 
- x64 (x86_64)
- x86 (i686)

### 📊 构建信息

每个构建都会生成详细的构建摘要，包含：
- 版本信息
- 架构信息
- 构建类型
- 分支和提交信息
- 下载链接

---

## 🛠️ 其他工作流

### 自动构建 (`auto-build.yml`)

- **触发**: 推送到 `dev` 分支或 PR 到 `dev`
- **功能**: 自动构建 APK 并上传到 alpha release
- **目标**: 仅 ARM64 架构

### 发布流程 (`release.yml`)

- **触发**: 手动触发（仅在 `main` 分支）
- **功能**: 完整的发布流程，包括版本校验、构建、创建 Release
- **目标**: 仅 ARM64 架构

---

## 🚨 注意事项

1. **构建时间**: APK 构建可能需要 10-20 分钟
2. **Artifact 保留**: 构建产物保留 30 天
3. **并发限制**: 同时运行的构建任务数量有限制
4. **权限要求**: 需要仓库的写入权限才能手动触发工作流

## 🐛 故障排除

### 常见问题

1. **构建失败**: 检查代码是否有语法错误
2. **NDK 错误**: 确保 NDK 版本兼容性
3. **Keystore 错误**: 检查 Secrets 配置是否正确
4. **依赖问题**: 检查 `pnpm-lock.yaml` 是否最新

### 查看日志

1. 进入 Actions 页面
2. 点击对应的构建任务
3. 查看各个步骤的详细日志
4. 重点关注构建步骤的错误信息