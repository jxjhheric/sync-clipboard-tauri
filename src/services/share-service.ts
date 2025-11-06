import { invoke } from '@tauri-apps/api/core'
import { listen } from '@tauri-apps/api/event'

export interface SharedContent {
  text?: string
  files?: string[]
}

export async function listenToShareIntent(
  callback: (content: SharedContent) => void,
): Promise<() => void> {
  try {
    const unlisten = await listen<SharedContent>('share-target://share', (event) => {
      console.log('Share intent received:', event.payload)
      callback(event.payload)
    })
    return unlisten
  } catch (error) {
    console.error('Failed to listen to share intent:', error)
    throw error
  }
}

export async function handleShareIntent(
  text?: string,
  files?: string[],
): Promise<void> {
  try {
    const response = await invoke<void>('handle_share_intent', {
      text: text || null,
      files: files || [],
    })
    console.log('Share intent handled:', response)
  } catch (error) {
    console.error('Failed to handle share intent:', error)
    throw error
  }
}
