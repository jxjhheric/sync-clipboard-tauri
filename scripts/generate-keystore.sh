#!/bin/bash

# Android Keystore 生成脚本
# 用于生成 GitHub Actions 所需的 Android 签名文件

set -e

echo "🔐 Android Keystore 生成工具"
echo "=============================="
echo ""

# 默认配置
KEYSTORE_NAME="upload-keystore.jks"
KEY_ALIAS="upload"
KEYSTORE_PASSWORD=""
KEY_PASSWORD=""
VALIDITY=10000  # 10000天 = 约27年

# 获取用户输入
read -p "请输入 Keystore 文件名 (默认: $KEYSTORE_NAME): " input_keystore_name
[ -n "$input_keystore_name" ] && KEYSTORE_NAME="$input_keystore_name"

read -p "请输入密钥别名 (默认: $KEY_ALIAS): " input_key_alias
[ -n "$input_key_alias" ] && KEY_ALIAS="$input_key_alias"

read -s -p "请输入 Keystore 密码: " input_keystore_password
echo ""
[ -n "$input_keystore_password" ] && KEYSTORE_PASSWORD="$input_keystore_password"

if [ -z "$KEY_PASSWORD" ]; then
    read -s -p "请输入密钥密码 (默认与 Keystore 密码相同): " input_key_password
    echo ""
    [ -n "$input_key_password" ] && KEY_PASSWORD="$input_key_password" || KEY_PASSWORD="$KEYSTORE_PASSWORD"
else
    KEY_PASSWORD="$input_key_password"
fi

# 验证密码
if [ -z "$KEYSTORE_PASSWORD" ]; then
    echo "❌ 错误: Keystore 密码不能为空"
    exit 1
fi

echo ""
echo "📋 配置信息:"
echo "- Keystore 文件: $KEYSTORE_NAME"
echo "- 密钥别名: $KEY_ALIAS"
echo "- 有效期: $VALIDITY 天"
echo ""

# 生成 keystore
echo "🔨 正在生成 Keystore..."
keytool -genkeypair \
    -keystore "$KEYSTORE_NAME" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Sync Clipboard Tauri, OU=Development, O=Sync Clipboard, L=City, S=State, C=CN"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore 生成成功!"
    echo ""
    echo "📝 下一步操作:"
    echo ""
    echo "1. 📤 上传到 GitHub Secrets:"
    echo "   - 将 keystore 文件转换为 Base64:"
    echo "     base64 -w 0 $KEYSTORE_NAME"
    echo ""
    echo "   - 在 GitHub 仓库设置中添加以下 Secrets:"
    echo "     - ANDROID_KEYSTORE_BASE64: (粘贴上面的 Base64 输出)"
    echo "     - ANDROID_KEYSTORE_PASSWORD: $KEYSTORE_PASSWORD"
    echo ""
    echo "2. 🗂️  本地配置 (可选):"
    echo "   - 复制 keystore 到 src-tauri/gen/android/app/"
    echo "   - 创建 keystore.properties 文件:"
    echo ""
    cat << EOF
password=$KEYSTORE_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_NAME
EOF
    echo ""
    echo "3. 🧹 清理:"
    echo "   - 建议将 keystore 文件保存在安全的地方"
    echo "   - 不要将 keystore 提交到版本控制"
    echo ""
    echo "🔒 安全提醒:"
    echo "- 请妥善保管 keystore 文件和密码"
    echo "- 丢失 keystore 将无法更新已发布的应用"
    echo "- 建议使用密码管理器存储这些信息"
else
    echo "❌ Keystore 生成失败!"
    exit 1
fi