# Android Share Intent Integration - Testing Guide

## Pre-requisites

- Android device with sync-clipboard-tauri installed
- Configured server URL, username, and password
- Network connectivity to the sync-clipboard server
- Access to various Android apps that support sharing (Gmail, Notes, Browser, etc.)

## Build Instructions

### Build for Android
```bash
cd /home/engine/project
npm run android-build
```

This will create an APK file in the `src-tauri/gen/android/app/build/outputs/apk/` directory.

### Install on Device
```bash
adb install -r src-tauri/gen/android/app/build/outputs/apk/universal/app-universal-release.apk
```

Or use Android Studio to build and run directly.

## Manual Testing Scenarios

### Test 1: Share Plain Text
1. Open Notes app on Android device
2. Type some text (e.g., "Hello from Notes")
3. Tap Menu → Share (or use Share button)
4. Select "sync-clipboard-tauri" from the share menu
5. App should open and show loading animation
6. Verify status message: "分享内容已上传成功！🎉"
7. Verify success checkmark emoji displayed
8. Verify text appears on sync-clipboard server
9. App should exit automatically after configured delay

### Test 2: Share URL from Browser
1. Open Chrome or other browser
2. Long press on any URL or use browser's share feature
3. Select "sync-clipboard-tauri" from share menu
4. Verify URL is captured and uploaded
5. Check server for the shared URL

### Test 3: Share from Gmail
1. Open Gmail app
2. Create a new email or reply with text
3. Select text and use Share option
4. Select "sync-clipboard-tauri"
5. Verify text is uploaded to server

### Test 4: Share from Other Apps
1. Test with:
   - Telegram/WhatsApp (share text)
   - Twitter/X (share posts)
   - Reddit (share comments)
   - Any other text-sharing app
2. Verify behavior is consistent

## Error Handling Tests

### Test 5: No Server Configuration
1. Unset or clear the server configuration
2. Try to share any content
3. Expected: Error message displayed
4. Expected: App returns to home page
5. Note: Check logcat for specific error details

### Test 6: Server Unavailable
1. Configure a server URL that's unreachable
2. Share content
3. Expected: Network error message
4. Expected: App returns to home page after 2 seconds

### Test 7: Empty Content
1. (Manual) Trigger share with empty content if possible
2. Expected: "没有收到分享的内容" error
3. Expected: Return to home page

### Test 8: Special Characters
1. Share text with:
   - Chinese characters: "你好世界"
   - Emoji: "😀😃😄"
   - Symbols: "!@#$%^&*()"
   - Mixed: "Hello 世界 🌍"
2. Verify all characters are correctly uploaded and displayed

### Test 9: Very Long Text
1. Share a large block of text (1000+ characters)
2. Verify upload completes successfully
3. Check server for complete content

### Test 10: Exit Delay Testing
1. Go to Settings → Exit Delay
2. Set delay to 5 seconds
3. Share content and observe exit delay
4. Verify app waits 5 seconds before exiting
5. Change delay to 0 and verify immediate exit

## Behavioral Tests

### Test 11: Multiple Rapid Shares
1. Share content in quick succession
2. Verify no race conditions
3. Verify each upload is processed correctly

### Test 12: Background App
1. Share content while app is not in focus
2. Verify app comes to foreground
3. Verify upload completes

### Test 13: App Already Running
1. Keep app running on home page
2. Share content from another app
3. Verify app navigates to /share-target
4. Verify upload completes

## Debugging

### Enable VConsole Logs
1. Navigate to Debug page in settings
2. Enable VConsole
3. Share content
4. Check console logs for:
   - Share event received
   - Router navigation
   - Server request details
   - Response status

### Check Logcat Output
```bash
adb logcat | grep -i "share\|tauri"
```

Look for:
- Share intent events
- Server requests
- Upload responses
- Any error messages

### Check Network Traffic
1. Use Charles or similar proxy
2. Monitor HTTP requests to server
3. Verify:
   - Correct endpoint called
   - Auth headers present
   - JSON payload correct

## Performance Tests

### Test 14: Upload Performance
1. Measure upload time for different content sizes:
   - 100 characters: should be < 1s
   - 1000 characters: should be < 1s
   - 10000 characters: should be < 2s
2. Note any delays or timeouts

### Test 15: Memory Usage
1. Use Android profiler to monitor:
   - Memory usage before share
   - Peak memory during upload
   - Memory after exit
2. Verify no memory leaks

## UI/UX Tests

### Test 16: Visual Feedback
1. Verify loading animation displays
2. Verify success checkmark displays
3. Verify error X displays
4. Verify all status messages are clear

### Test 17: Content Preview
1. Verify preview shows first 100 characters
2. Verify "..." added for longer content
3. Verify preview is readable

### Test 18: Toast Notifications
1. Verify toast appears on success
2. Verify toast appears on error
3. Verify toast message is appropriate
4. Verify toast duration is reasonable

## Regression Tests

### Test 19: Existing Features Still Work
1. Manual upload (Ctrl+V) still works
2. Download clipboard still works
3. Deep links still work
4. Settings page still works
5. No disruption to app functionality

## Test Report Template

```
Test Case: [Name]
Date: [Date]
Device: [Device Model/OS Version]
App Version: [Version]

Prerequisites:
- [ ] Server configured
- [ ] Device connected
- [ ] App installed

Steps:
1. [Step 1]
2. [Step 2]

Expected Result:
[Expected outcome]

Actual Result:
[What actually happened]

Pass/Fail: [PASS/FAIL]

Notes:
[Any additional observations]

Logs:
[Relevant console or logcat output]
```

## Known Limitations

1. **File Sharing**: Not yet supported (shows error message)
2. **URL Length**: Very long URLs may hit browser limits (rare)
3. **Batch Uploads**: Only single item at a time
4. **Rich Media**: Images and documents not supported

## Success Criteria

All tests pass when:
- ✅ Text and URLs can be shared
- ✅ Content is uploaded to server
- ✅ User receives appropriate feedback
- ✅ Errors are handled gracefully
- ✅ No existing features are disrupted
- ✅ App exits cleanly after upload
- ✅ All special characters work
- ✅ Performance is acceptable

## Troubleshooting

### App doesn't appear in share menu
- Rebuild and reinstall APK
- Check tauri.conf.json configuration
- Verify capabilities include share-target:default
- Restart device

### Content not uploading
- Verify server is accessible
- Check network connectivity
- Verify credentials in settings
- Check server logs

### App crashes on share
- Check logcat for stack trace
- Verify all dependencies installed
- Try reinstalling app
- Check for memory issues

### Wrong content appears on server
- Verify UTF-8 encoding
- Check special characters handling
- Verify JSON serialization
- Check server processing

## Support

For issues or questions:
1. Check the SHARE_INTENT_INTEGRATION.md documentation
2. Review error messages in VConsole
3. Check logcat output
4. Examine server logs
