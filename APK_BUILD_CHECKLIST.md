# APK 构建设置清单

## ✅ 必需设置

### 1. GitHub Secrets 配置

在 GitHub 仓库的 Settings > Secrets and variables > Actions 中添加：

- [ ] `ANDROID_KEYSTORE_BASE64`: keystore 文件的 Base64 编码
- [ ] `ANDROID_KEYSTORE_PASSWORD`: keystore 密码

> 💡 **提示**: 使用 `./scripts/generate-keystore.sh` 脚本生成 keystore

### 2. 代码仓库检查

确认以下文件存在且配置正确：

- [ ] `.github/workflows/build-apk.yml` - APK 构建工作流
- [ ] `src-tauri/tauri.conf.json` - Tauri 配置文件
- [ ] `package.json` - 项目依赖配置
- [ ] `src-tauri/gen/android/` - Android 生成目录

### 3. 项目配置验证

确认以下配置项：

- [ ] Tauri 版本为 2.x
- [ ] Android 目标平台已配置
- [ ] 前端构建命令正确 (`pnpm build`)
- [ ] 依赖版本兼容

## 🧪 测试步骤

### 1. 环境测试

```bash
# 本地测试
pnpm install
pnpm build
pnpm check
```

### 2. Actions 测试

1. [ ] 推送代码到 `ci-github-actions-build-apk` 分支
2. [ ] 检查 "🧪 测试构建" 工作流是否成功
3. [ ] 检查 "📱 构建 APK" 工作流是否成功

### 3. 手动触发测试

1. [ ] 进入 Actions 页面
2. [ ] 选择 "📱 构建 APK (Build APK)"
3. [ ] 点击 "Run workflow"
4. [ ] 选择构建参数：
   - 目标: `aarch64-linux-android`
   - 类型: `release`
5. [ ] 等待构建完成
6. [ ] 下载并测试 APK

## 📱 构建验证

### 1. APK 检查

构建完成后验证：

- [ ] APK 文件大小合理（通常 10-50MB）
- [ ] 文件名包含版本信息
- [ ] 可以正常安装到 Android 设备

### 2. 功能测试

在 Android 设备上测试：

- [ ] 应用可以正常启动
- [ ] UI 界面显示正常
- [ ] 剪贴板功能正常
- [ ] 文件上传/下载功能正常
- [ ] 分享意图功能正常

## 🔧 故障排除

### 常见问题检查清单

- [ ] 检查 GitHub Secrets 配置是否正确
- [ ] 检查 NDK 版本兼容性
- [ ] 检查 Rust 目标架构是否正确
- [ ] 检查 Android SDK 配置
- [ ] 查看 Actions 日志中的错误信息

### 调试步骤

1. [ ] 查看 Actions 详细日志
2. [ ] 本地复现构建过程
3. [ ] 检查依赖版本冲突
4. [ ] 清理构建缓存重试

## 📚 相关文档

- [APK 构建指南](docs/APK_BUILD_GUIDE.md)
- [GitHub Actions 工作流说明](.github/workflows/README.md)
- [项目 README](README.md)

## 🆘 获取帮助

如果遇到问题：

1. [ ] 查看本文档的故障排除部分
2. [ ] 检查 GitHub Actions 日志
3. [ ] 搜索项目 Issues
4. [ ] 创建新的 Issue 并提供详细信息

---

## ✨ 完成标记

当所有项目都完成后，你可以：

- [ ] 删除这个 checklist 文件
- [ ] 提交所有更改到主分支
- [ ] 创建第一个正式的 APK Release

祝你构建顺利！🎉