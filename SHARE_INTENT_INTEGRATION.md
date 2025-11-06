# Android Share Intent Integration

This document describes the implementation of Android Share Intent handling for sync-clipboard-tauri.

## Overview

The sync-clipboard-tauri application now supports receiving shared content from other Android applications. When a user selects "Share to sync-clipboard-tauri" from another app, the shared content (text, URLs, etc.) is automatically captured and uploaded to the configured sync-clipboard server.

## Implementation Details

### 1. Configuration

#### tauri.conf.json
- Added `share-target` plugin configuration
- Configured MIME types: `text/plain` and `text/uri-list`
- This enables Android intent filtering for these content types

#### capabilities/default.json
- Added `share-target:default` permission to allow the app to receive shared content

### 2. Backend (Rust)

#### src-tauri/src/lib.rs
- Added `SharedData` struct to represent shared content with optional text and files
- Implemented `handle_share_intent` Tauri command to process share intents
- The command validates that content is present and logs the received data

### 3. Frontend

#### src/services/share-service.ts
- Created service functions for managing share intent events
- `listenToShareIntent()`: Sets up event listener for incoming share intents
- `handleShareIntent()`: Invokes the Rust command to handle share data

#### src/router/router.ts
- Added `/share-target` route for handling shared content

#### src/views/share-target/share-target.vue
- New component dedicated to processing shared content
- Displays upload status with visual feedback (loading, success, error)
- Automatically uploads received text content to the sync-clipboard server
- Shows preview of shared content
- Exits after configurable delay (respects the `exitDelay` setting)
- Handles errors gracefully with appropriate error messages

#### src/main.ts
- Added `setupShareTargetListener()` function to listen for share target events
- Integrated listener into the app initialization flow
- Routes incoming share events to the `/share-target` page with encoded query parameters

### 4. Data Flow

```
User shares content from another app
        ↓
Android Intent captured by tauri-plugin-sharetarget
        ↓
Event emitted: 'tauri://share'
        ↓
main.ts: setupShareTargetListener() receives the event
        ↓
Router redirects to /share-target page with query params
        ↓
share-target.vue component mounts
        ↓
Loads server configuration
        ↓
Extracts shared content from query parameters
        ↓
Creates TextClipboardData object
        ↓
Sends PUT request to sync-clipboard server
        ↓
Shows success/error feedback
        ↓
Exits application after configurable delay
```

## Supported Content Types

### Current Support
- **Text**: Plain text content from notes, messages, etc.
- **URLs**: Web links shared from browsers or apps

### Planned Support
- **Files**: Direct file sharing (requires implementation of file upload API)

## Usage

### For Users
1. Open any Android application with shareable content (text, URL, etc.)
2. Tap "Share" or use the share intent
3. Select "sync-clipboard-tauri" from the available apps
4. The app will automatically upload the content to your configured server
5. The app will exit after completion

### For Developers

To customize the share intent behavior:

1. **Add new MIME types** in `tauri.conf.json`:
   ```json
   "share-target": {
     "mimeTypes": ["text/plain", "text/uri-list", "image/*"]
   }
   ```

2. **Handle additional content types** in `share-target.vue`:
   - Add logic to detect file types
   - Implement appropriate upload handlers

3. **Extend event handling** in `src/main.ts`:
   - Add custom routing logic based on content type
   - Handle batch uploads for multiple items

## Configuration

### Exit Delay
The application respects the `exitDelay` setting stored in localStorage:
- Default: 0 seconds (exit immediately)
- Configurable via the settings page
- Useful for verifying successful uploads before app closes

### Server Configuration
Share intent uploads use the same server configuration as the manual upload feature:
- URL, username, and password from `clipboard-sync-config.toml`
- Stored in `$APPDATA/clipboard-sync-config.toml`

## Error Handling

The implementation handles various error scenarios:

### No Content Shared
- Displays error message: "没有收到分享的内容"
- Returns to home page after 2 seconds

### No Server Configuration
- Displays error related to missing credentials
- Returns to home page after 2 seconds

### Network Errors
- HTTP errors are caught and displayed with status code
- Connection failures show generic error message
- User can retry by re-opening the share intent

### Unsupported Content Types
- File sharing displays: "暂不支持文件分享，请分享文本内容"
- Indicates future support for file types

## Security Considerations

1. **Authentication**: Uses Basic Auth headers (Base64 encoded credentials)
2. **HTTPS**: Should always use HTTPS for production servers
3. **Credentials**: Stored locally in app data directory
4. **Input Validation**: Validates that content is present and not empty

## Testing

### Manual Testing
1. Install the app on an Android device
2. Open a text editor or browser
3. Select text/URL and choose "Share"
4. Select sync-clipboard-tauri from share menu
5. Verify content appears on the server

### Debugging
- Check logcat output: `adb logcat | grep tauri`
- Enable VConsole in debug page for frontend logs
- Check sync-clipboard server logs for upload activity

## Troubleshooting

### App doesn't appear in share menu
- Ensure `tauri.conf.json` has `share-target` plugin configuration
- Verify capabilities include `share-target:default`
- Rebuild the APK and reinstall

### Shared content not uploading
- Verify server URL is correct and accessible
- Check credentials are saved in settings
- Ensure network connectivity
- Check server logs for authentication errors

### App exits before showing success
- Verify `exitDelay` is set appropriately (temporarily increase for testing)
- Check if there are network timeouts
- Review error messages in VConsole

## Future Enhancements

1. **File Upload Support**: Implement file transfer for shared documents
2. **Batch Processing**: Handle multiple shared items at once
3. **Rich Media**: Support image and document sharing
4. **Clipboard Integration**: Automatically sync with device clipboard
5. **User Feedback**: Add toast notifications for better UX
6. **Scheduled Retry**: Implement retry logic for failed uploads
