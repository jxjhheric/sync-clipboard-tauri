<template>
  <div class="container mx-auto p-6 flex items-center justify-center min-h-screen">
    <div class="text-center space-y-4">
      <div class="text-lg" :class="{
        'text-gray-600': shareStatus === 'processing',
        'text-green-600': shareStatus === 'success',
        'text-red-600': shareStatus === 'error'
      }">
        {{ statusMessage }}
      </div>

      <!-- 处理中的加载动画 -->
      <div v-if="shareStatus === 'processing'"
           class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto">
      </div>

      <!-- 成功图标 -->
      <div v-else-if="shareStatus === 'success'"
           class="text-green-500 text-4xl">
        ✅
      </div>

      <!-- 错误图标 -->
      <div v-else-if="shareStatus === 'error'"
           class="text-red-500 text-4xl">
        ❌
      </div>

      <!-- 显示分享内容预览 -->
      <div v-if="sharedText" class="mt-4 p-4 bg-gray-100 rounded">
        <p class="text-sm text-gray-600 mb-2">分享的内容:</p>
        <p class="text-sm text-gray-800 break-words">{{ sharedText.substring(0, 100) }}{{ sharedText.length > 100 ? '...' : '' }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { showToast } from '@bling-yshs/tauri-plugin-toast'
import { fetch } from '@tauri-apps/plugin-http'
import { exit, isForeground } from 'tauri-plugin-quicktile-api'
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { createTextClipboardData, type TextClipboardData } from '@/entities/clipboard-data'
import { useClipboardService } from '@/services/clipboard-service'
import { getExitDelay } from '@/utils/settings'

const router = useRouter()

const { serverConfig, fullFileUrl, loadConfig } = useClipboardService()

const shareStatus = ref<'processing' | 'success' | 'error'>('processing')
const statusMessage = ref('正在处理分享的内容...')
const sharedText = ref<string>('')
const sharedFiles = ref<string[]>([])

async function uploadSharedContent(content: string) {
  try {
    while (!(await isForeground())) {
      console.log('App 不在前台，延迟 200ms 重试')
      await new Promise((resolve) => setTimeout(resolve, 200))
    }
    console.log('App 在前台，开始上传分享内容')

    if (!content || content.trim() === '') {
      throw new Error('没有可用的分享内容')
    }

    sharedText.value = content
    console.log(`分享的内容为: ${content}`)

    const clipboardData: TextClipboardData = createTextClipboardData(content)
    const jsonStr = JSON.stringify(clipboardData)

    const credentials = btoa(`${serverConfig.value.username}:${serverConfig.value.password}`)

    const response = await fetch(fullFileUrl.value, {
      method: 'PUT',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/json',
      },
      body: jsonStr,
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    console.log('分享内容上传成功')
    return true
  } catch (err: any) {
    console.error('上传失败:', err.message || '未知错误')
    throw err
  }
}

onMounted(async () => {
  console.log('分享目标页面已挂载，开始处理分享内容...')

  try {
    await loadConfig()

    const queryParams = new URLSearchParams(window.location.search)
    const sharedTextContent = queryParams.get('text')
    const sharedFilesParam = queryParams.get('files')

    if (!sharedTextContent && !sharedFilesParam) {
      throw new Error('没有收到分享的内容')
    }

    console.log('开始上传分享内容...')

    if (sharedTextContent) {
      await uploadSharedContent(decodeURIComponent(sharedTextContent))
    } else if (sharedFilesParam) {
      try {
        const files = JSON.parse(decodeURIComponent(sharedFilesParam))
        sharedFiles.value = files
        console.log('接收到分享的文件:', files)
        statusMessage.value = '暂不支持文件分享，请分享文本内容'
        shareStatus.value = 'error'
        throw new Error('暂不支持文件分享，请分享文本内容')
      } catch (e) {
        throw new Error('无法解析分享的文件信息')
      }
    }

    await showToast('分享内容已上传成功！🎉', 'long')

    shareStatus.value = 'success'
    statusMessage.value = '分享内容已上传成功！🎉'
    console.log('分享内容上传成功！')

    const delaySeconds = getExitDelay()
    if (delaySeconds === 0) {
      await exit()
    } else {
      setTimeout(async () => {
        await exit()
      }, delaySeconds * 1000)
    }
  } catch (error) {
    console.error('处理分享流程失败:', error)
    await showToast(`处理分享流程失败: ${error}`, 'long')
    shareStatus.value = 'error'
    statusMessage.value = '处理分享失败，请重试'

    setTimeout(async () => {
      await router.push('/home')
    }, 2000)
  }
})
</script>

<style scoped>
.container {
  max-width: 1200px;
}
</style>
