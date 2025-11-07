# Android Keystore Tag Number Over 30 Fix

## 问题

在构建 Android APK 时出现以下错误：
```
Failed to read key upload from store "/path/to/keystore.jks": Tag number over 30 is not supported
```

这是由于 keystore 文件使用了不兼容的格式导致的。

## 根本原因

1. **Keystore 格式**：使用了 PKCS12 格式或包含 tag numbers over 30 的 ASN.1 BER 编码
2. **工具不兼容**：Android 构建工具中的 keytool 版本无法处理这种现代格式
3. **Java 版本**：Java 17+ 默认使用 PKCS12 格式而不是传统的 JKS 格式

## 解决方案

本修复通过以下方式解决了这个问题：

### 1. 生成时指定格式
在 `scripts/generate-keystore.sh` 中添加 `-storetype JKS` 参数，确保新生成的 keystore 使用 JKS 格式：

```bash
keytool -genkeypair \
    -keystore "$KEYSTORE_NAME" \
    -storetype JKS \  # 确保使用 JKS 格式
    # ... 其他参数
```

### 2. 构建时格式转换
在所有 GitHub Actions 工作流（build-apk.yml, auto-build.yml, release.yml）中，添加了 keystore 格式转换步骤：

```bash
# 解码 Base64 keystore
echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > app/keystore.jks

# 转换为 JKS 格式（如果需要）
keytool -importkeystore \
  -srckeystore app/keystore.jks \
  -srcstoretype PKCS12 \
  -srcstorepass "$ANDROID_KEYSTORE_PASSWORD" \
  -destkeystore "$TEMP_DIR/temp.jks" \
  -deststoretype JKS \
  -deststorepass "$ANDROID_KEYSTORE_PASSWORD" \
  -noprompt
```

## 修改文件列表

- ✅ `scripts/generate-keystore.sh` - 添加 `-storetype JKS` 参数
- ✅ `.github/workflows/build-apk.yml` - 添加 keystore 格式转换逻辑（2 个地方）
- ✅ `.github/workflows/auto-build.yml` - 添加 keystore 格式转换逻辑
- ✅ `.github/workflows/release.yml` - 添加 keystore 格式转换逻辑
- ✅ `docs/APK_BUILD_GUIDE.md` - 更新手动生成指令

## 使用方法

### 新 Keystore

使用更新后的脚本生成：
```bash
./scripts/generate-keystore.sh
```

### 现有 Keystore

无需任何操作。GitHub Actions 工作流会自动尝试转换现有 keystore 为兼容格式。

## 工作流转换逻辑

转换步骤的设计很健壮：

1. **首次尝试**：假设源 keystore 是 PKCS12 格式进行转换
2. **备选方案**：如果失败，尝试假设源是 JKS 格式进行转换
3. **容错处理**：所有失败都被捕获，不会中断工作流
4. **验证**：检查转换后的文件是否存在，只有成功时才使用

## 技术细节

### JKS vs PKCS12

| 格式 | 优点 | 缺点 |
|------|------|------|
| **JKS** | 传统、广泛支持、兼容性好 | 较古老，标准化不够 |
| **PKCS12** | 现代、标准化、跨平台兼容 | 较新版本有兼容性问题 |

在 Android 构建工具中，JKS 格式的兼容性更好。

### Tag Numbers Over 30

这是 ASN.1 BER 编码中的概念。较新的 PKCS12 格式可能使用 tag numbers over 30，但某些较旧的解析器不支持。通过转换为 JKS 格式，避免了这个问题。

## 验证修复

如要验证 keystore 格式和兼容性：

```bash
# 列出 keystore 内容
keytool -list -v -keystore keystore.jks -storepass your-password

# 查看存储类型
keytool -list -keystore keystore.jks -storepass your-password
```

## 相关文档

详细说明请参阅：
- `KEYSTORE_FIX.md` - 修复说明文档
- `docs/APK_BUILD_GUIDE.md` - APK 构建指南

## 发生了什么

如果你已经有一个无法工作的 keystore，工作流会自动转换它。如果转换失败，workflow 仍会继续，但 APK 构建可能会失败并显示原始错误信息。

## 推荐做法

1. **使用新脚本生成**：使用 `./scripts/generate-keystore.sh` 生成新的 keystore
2. **定期更新 Secrets**：确保 GitHub Secrets 中的 keystore 是最新的
3. **本地备份**：妥善保管 keystore 文件，因为丢失它将无法更新已发布的应用
