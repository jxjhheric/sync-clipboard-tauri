# Android Share Intent Integration - Quick Start

## For Users

### How to Use
1. **Open another app** (Notes, Email, Browser, etc.)
2. **Select content to share** (text, URL, etc.)
3. **Tap Share** and select **sync-clipboard-tauri**
4. **Content is automatically uploaded** to your server
5. **App closes** after completion

## For Developers

### What Was Added

**Backend (Rust)**
- New command: `handle_share_intent()` in `src-tauri/src/lib.rs`
- New struct: `SharedData` for type safety

**Frontend (Vue/TypeScript)**
- New service: `src/services/share-service.ts`
- New component: `src/views/share-target/share-target.vue`
- New route: `/share-target`
- Enhanced: `src/main.ts` with share listener

**Configuration**
- `tauri.conf.json`: Added share-target plugin
- `capabilities/default.json`: Added share-target permission

### Key Files

| File | Purpose |
|------|---------|
| `src/views/share-target/share-target.vue` | UI for processing shares |
| `src/services/share-service.ts` | Event handling service |
| `src/main.ts` | Share listener setup |
| `src-tauri/src/lib.rs` | Rust backend command |

### How It Works

```
User shares from app
    ↓
Intent captured by tauri-plugin-sharetarget
    ↓
Event emitted to setupShareTargetListener()
    ↓
Router navigates to /share-target with query params
    ↓
share-target.vue component processes and uploads
    ↓
App exits with feedback
```

### Building & Installing

```bash
# Build APK
npm run android-build

# Install on connected device
adb install -r src-tauri/gen/android/app/build/outputs/apk/universal/app-universal-release.apk
```

### Testing

1. Open any app with shareable content
2. Use Share menu
3. Select sync-clipboard-tauri
4. Verify upload on server

### Supported Content
- ✅ Plain text
- ✅ URLs
- 🔄 Files (coming soon)

### Error Handling
- Network errors → Show message + return home
- Missing config → Show message + return home
- No content → Show message + return home
- File share → Show "not supported" message

### Configuration
- Server URL, username, password in Settings
- Exit delay in Settings (0 = immediate exit)

### Logging

**Frontend**: Check VConsole on Debug page
```
Share intent received
Router navigating to /share-target
Upload started
Upload completed
```

**Backend**: Check logcat
```bash
adb logcat | grep tauri
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| App doesn't appear in share menu | Rebuild APK and reinstall |
| Content not uploading | Check network and server config |
| App crashes | Check logcat for errors |
| Wrong content uploaded | Check encoding/special chars |

### Architecture

- **Plugin**: `tauri-plugin-sharetarget` v0.1.6
- **Event Channel**: Tauri event system (`tauri://share`)
- **Data Transfer**: URL query parameters
- **Upload Mechanism**: HTTP PUT with Basic Auth
- **Server Integration**: Existing `useClipboardService()`

### Future Enhancements

1. File upload support
2. Batch uploads
3. Image sharing
4. Document sharing
5. Retry logic
6. Progress indication

### Related Documentation

- **Full Details**: `SHARE_INTENT_INTEGRATION.md`
- **Checklist**: `IMPLEMENTATION_CHECKLIST.md`
- **Summary**: `IMPLEMENTATION_SUMMARY.md`
- **Testing**: `TESTING_GUIDE.md`

### API Reference

#### Share Intent Listener
```typescript
await setupShareTargetListener()
// Listens for 'tauri://share' events
// Routes to /share-target?text=<content>
```

#### Handle Share Intent (Rust)
```rust
handle_share_intent(text: Option<String>, files: Vec<String>) -> Result<(), String>
```

#### Share Service Functions
```typescript
// Listen for share intents
await listenToShareIntent((content) => {
  console.log('Received:', content)
})

// Handle share intent (invoke Rust command)
await handleShareIntent(text, files)
```

### Best Practices

1. **Always configure server** before using share feature
2. **Use HTTPS** for production servers
3. **Test with various apps** during QA
4. **Monitor server logs** for issues
5. **Check network connectivity** before sharing

### Performance Tips

1. Keep exit delay short for good UX
2. Use compression for large servers
3. Cache server config to reduce lookups
4. Monitor memory usage on low-end devices

### Security Checklist

- [ ] Using HTTPS for server
- [ ] Credentials properly stored
- [ ] Basic Auth implemented
- [ ] Input validation in place
- [ ] Error messages don't leak sensitive info

### Common Patterns

**Check if share is available**
```typescript
if (navigator.share) {
  // Share API available
}
```

**Update share config**
```typescript
const { serverConfig, saveConfig } = useClipboardService()
serverConfig.value.url = "https://..."
await saveConfig()
```

**Display upload progress**
```typescript
// Currently shows loading animation
// Future: percentage-based progress
```

### Questions?

1. Check documentation files
2. Review error messages in logs
3. Test with debug console
4. Check existing code patterns

---

**Version**: 1.0  
**Status**: Production Ready  
**Last Updated**: 2024  
**Branch**: `feat/android-share-intent-integration`
