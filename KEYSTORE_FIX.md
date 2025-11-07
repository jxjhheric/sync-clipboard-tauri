# Android Keystore 兼容性修复

## 问题说明

在 Android APK 构建过程中，可能会遇到以下错误：
```
Failed to read key upload from store "/path/to/keystore.jks": Tag number over 30 is not supported
```

这个错误发生在以下情况：
1. Keystore 文件以 PKCS12 格式保存（Java 17+ 的默认格式）
2. Keystore 使用了较新的 ASN.1 BER 编码，其中包含 tag numbers over 30
3. Android 构建工具使用的 keytool 版本无法识别这种格式

## 解决方案

本修复实施了以下改进：

### 1. Keystore 生成改进

**文件**: `scripts/generate-keystore.sh`

更新了 keytool 生成命令，添加了 `-storetype JKS` 参数，确保生成的 keystore 使用 JKS 格式而不是默认的 PKCS12 格式：

```bash
keytool -genkeypair \
    -keystore "$KEYSTORE_NAME" \
    -storetype JKS \  # 新增此行
    -alias "$KEY_ALIAS" \
    # ... 其他参数
```

### 2. 工作流优化

**文件**: 
- `.github/workflows/build-apk.yml`
- `.github/workflows/auto-build.yml`
- `.github/workflows/release.yml`

在所有 GitHub Actions 工作流中，keystore 被解码后会立即进行格式转换，确保兼容性：

```bash
# 解码 Base64 keystore
echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > app/keystore.jks

# 转换为 JKS 格式（如果需要）
keytool -importkeystore \
  -srckeystore app/keystore.jks \
  -srcstoretype PKCS12 \
  -destkeystore "$TEMP_DIR/temp.jks" \
  -deststoretype JKS \
  # ... 其他参数
```

工作流会尝试：
1. 首先假设源 keystore 是 PKCS12 格式进行转换
2. 如果失败，则假设它已经是 JKS 格式
3. 如果都失败，继续使用原始 keystore（可能成功也可能失败）

### 3. 文档更新

**文件**: `docs/APK_BUILD_GUIDE.md`

更新了手动生成 keystore 的说明，包含了 `-storetype JKS` 参数。

## 使用建议

### 新项目

使用脚本生成 keystore：
```bash
./scripts/generate-keystore.sh
```

或手动生成时添加 `-storetype JKS`：
```bash
keytool -genkeypair \
    -keystore upload-keystore.jks \
    -storetype JKS \
    # ... 其他参数
```

### 现有项目

如果已有老的 PKCS12 格式 keystore，工作流会自动转换。无需额外操作。

## 技术细节

### 为什么 JKS 格式更兼容

- **JKS (Java KeyStore)**：传统的 Java keystore 格式，被广泛支持
- **PKCS12**：更现代的加密标准，但需要较新的工具支持

在 Android 构建工具中，JKS 格式的兼容性更好，避免了 tag numbers over 30 的问题。

### 工作流转换逻辑

转换步骤使用 `keytool -importkeystore` 命令：
- 源格式可以是 PKCS12 或 JKS（使用 `-srcstoretype` 指定）
- 目标格式统一为 JKS（使用 `-deststoretype JKS`）
- 使用 `-noprompt` 跳过交互式提示
- 错误重定向到 `/dev/null`，失败时不中断流程

## 验证修复

构建完成后，你可以验证 keystore 格式：

```bash
# 查看 keystore 信息
keytool -list -v -keystore keystore.jks -storepass your-password
```

如果输出显示 keystore 已成功读取且没有 tag numbers over 30 的错误，则修复生效。

## 相关参考

- [Java keytool 文档](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/keytool.html)
- [PKCS12 vs JKS](https://www.acunetix.com/blog/articles/keystore-formats-jks-vs-pkcs12/)
- [Android 签名文档](https://developer.android.com/studio/publish/app-signing)
