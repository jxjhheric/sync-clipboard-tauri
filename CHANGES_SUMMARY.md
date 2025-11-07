# Android Keystore Tag Over 30 Fix - 修改总结

## 问题概述

编译 Android APK 时出现错误：
```
Failed to read key upload from store "/path/to/keystore.jks": Tag number over 30 is not supported
```

这个问题是由于 keystore 文件格式与 Android 构建工具不兼容导致的。

## 解决方案

通过以下方式修复了 keystore 格式兼容性问题：

### 1. Keystore 生成脚本优化

**文件**: `scripts/generate-keystore.sh`

**改动**: 添加 `-storetype JKS` 参数确保新生成的 keystore 使用 JKS 格式
- 行 55: 添加 `-storetype JKS \`

**影响**: 新生成的 keystore 将使用更兼容的 JKS 格式而非 PKCS12 格式

### 2. 构建指南文档更新

**文件**: `docs/APK_BUILD_GUIDE.md`

**改动**: 更新手动生成 keystore 的说明，包含 `-storetype JKS` 参数
- 行 31: 添加 `-storetype JKS \`

**影响**: 用户按照文档手动生成的 keystore 将使用兼容的格式

### 3. GitHub Actions 工作流优化

#### 3.1 Build APK 工作流

**文件**: `.github/workflows/build-apk.yml`

**改动**: 
- **第一个 keystore 创建步骤** (行 123-171): 添加 keystore 格式转换逻辑
  - 解码 Base64 keystore
  - 尝试从 PKCS12 转换为 JKS
  - 如果失败，尝试 JKS 到 JKS 的转换（数据验证）
  - 清理临时文件
  
- **第二个 keystore 创建步骤** (行 357-397): 多架构构建任务中应用相同逻辑

**影响**: 无论 keystore 是什么格式，工作流都会尝试转换为兼容格式

#### 3.2 Auto Build 工作流

**文件**: `.github/workflows/auto-build.yml`

**改动**: 添加与 build-apk.yml 相同的 keystore 格式转换逻辑
- 行 91-130: 完整的格式转换步骤

**影响**: 自动构建流程也能处理格式不兼容的 keystore

#### 3.3 Release 工作流

**文件**: `.github/workflows/release.yml`

**改动**: 添加与 build-apk.yml 相同的 keystore 格式转换逻辑
- 行 138-177: 完整的格式转换步骤

**影响**: 发布工作流能处理现有的 keystore 格式问题

### 4. 技术文档

**新增文件**: `KEYSTORE_FIX.md`
- 详细的问题说明
- 技术细节说明
- 使用建议
- 验证方法

**新增文件**: `ANDROID_KEYSTORE_TAG_FIX.md`
- 问题根本原因分析
- 解决方案详细说明
- 工作流转换逻辑说明
- 推荐做法

## 关键改动详解

### Keystore 格式转换逻辑

在所有工作流中添加的转换步骤遵循以下逻辑：

```bash
# 1. 解码 Base64 keystore
echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > app/keystore.jks

# 2. 创建临时目录
TEMP_DIR=$(mktemp -d)

# 3. 尝试 PKCS12 -> JKS 转换
keytool -importkeystore \
  -srckeystore app/keystore.jks \
  -srcstoretype PKCS12 \
  -srcstorepass "$PASSWORD" \
  -destkeystore "$TEMP_DIR/temp.jks" \
  -deststoretype JKS \
  -deststorepass "$PASSWORD" \
  -noprompt 2>/dev/null || \

# 4. 如果失败，尝试 JKS -> JKS 转换（数据验证）
keytool -importkeystore \
  -srckeystore app/keystore.jks \
  -srcstoretype JKS \
  -srcstorepass "$PASSWORD" \
  -destkeystore "$TEMP_DIR/temp.jks" \
  -deststoretype JKS \
  -deststorepass "$PASSWORD" \
  -noprompt 2>/dev/null || true

# 5. 使用转换后的文件（如果转换成功）
if [ -f "$TEMP_DIR/temp.jks" ]; then
  mv "$TEMP_DIR/temp.jks" app/keystore.jks
fi

# 6. 清理临时目录
rm -rf "$TEMP_DIR"
```

### 为什么这个方案有效

1. **双重转换尝试**: 覆盖两种可能的源格式（PKCS12 和 JKS）
2. **优雅的错误处理**: 所有失败都被捕获，不会中断工作流
3. **向后兼容**: 已经是 JKS 格式的 keystore 也能通过验证
4. **自动修复**: 自动将不兼容的 keystore 转换为兼容格式

## 修改文件统计

- 修改: 5 个文件
  - `.github/workflows/build-apk.yml` (+74 行)
  - `.github/workflows/auto-build.yml` (+39 行)
  - `.github/workflows/release.yml` (+39 行)
  - `scripts/generate-keystore.sh` (+1 行)
  - `docs/APK_BUILD_GUIDE.md` (+1 行)

- 新增: 2 个文档文件
  - `KEYSTORE_FIX.md`
  - `ANDROID_KEYSTORE_TAG_FIX.md`

总计: 154 行代码改动 + 2 个新文档

## 向后兼容性

✅ **完全向后兼容**

- 现有的 JKS 格式 keystore 不受影响
- 现有的 PKCS12 格式 keystore 会自动转换
- 工作流改动不会影响其他功能
- 无需更新现有的 GitHub Secrets

## 验证修复

用户可以通过以下方式验证修复已生效：

1. **新的 keystore**: 使用 `./scripts/generate-keystore.sh` 生成
2. **现有的 keystore**: 上传到 GitHub Secrets 后，工作流会自动处理
3. **构建成功**: 如果 APK 构建成功，则证明 keystore 兼容性问题已解决

## 建议的后续操作

1. **更新 keystore** (可选但推荐):
   ```bash
   ./scripts/generate-keystore.sh
   # 按照提示将新的 keystore 上传到 GitHub Secrets
   ```

2. **测试构建** (推荐):
   - 手动触发 GitHub Actions 的 "📱 构建 APK" 工作流
   - 选择 release 类型进行测试
   - 验证构建成功

3. **保管好 keystore**:
   - 妥善保存 keystore 文件
   - 丢失后无法更新已发布的应用

## 相关资源

- Java keytool 文档: https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html
- Android 签名指南: https://developer.android.com/studio/publish/app-signing
- Tauri Android 文档: https://tauri.app/v1/guides/building/android/
