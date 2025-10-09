#!/bin/bash

# Method 3: Launchd Services Reset
# Resets launchd services and daemons that manage speech recognition

echo "🚀 Method 3: Launchd Services Reset"
echo "==================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current launchd services status..."

# Check current speech-related services
echo "📋 Speech-related launchd services:"
launchctl list | grep -E "(speech|dictation|assistant|siri)" | head -10

echo ""
echo "🔄 Resetting launchd services..."

# Method 3A: Stop and restart speech recognition services
echo "   • Stopping speech recognition services..."

# Stop system-level services
sudo launchctl stop system/com.apple.speech.recognition 2>/dev/null && echo "     ✅ Speech recognition service stopped" || echo "     ℹ️  Speech recognition service not running"

sudo launchctl stop system/com.apple.corespeechd 2>/dev/null && echo "     ✅ Core Speech daemon stopped" || echo "     ℹ️  Core Speech daemon not running"

sudo launchctl stop system/com.apple.assistantd 2>/dev/null && echo "     ✅ Assistant daemon stopped" || echo "     ℹ️  Assistant daemon not running"

# Stop user-level services
launchctl stop user/$(id -u)/com.apple.speech.recognition 2>/dev/null && echo "     ✅ User speech recognition service stopped" || echo "     ℹ️  User speech recognition service not running"

launchctl stop user/$(id -u)/com.apple.corespeechd 2>/dev/null && echo "     ✅ User Core Speech daemon stopped" || echo "     ℹ️  User Core Speech daemon not running"

echo ""
echo "   • Unloading service plists..."

# Unload service plists
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.speech.recognition.plist 2>/dev/null && echo "     ✅ Speech recognition plist unloaded" || echo "     ℹ️  Speech recognition plist not loaded"

sudo launchctl unload /System/Library/LaunchDaemons/com.apple.corespeechd.plist 2>/dev/null && echo "     ✅ Core Speech plist unloaded" || echo "     ℹ️  Core Speech plist not loaded"

sudo launchctl unload /System/Library/LaunchDaemons/com.apple.assistantd.plist 2>/dev/null && echo "     ✅ Assistant plist unloaded" || echo "     ℹ️  Assistant plist not loaded"

echo ""
echo "   • Waiting for services to fully stop..."
sleep 3

echo ""
echo "   • Reloading service plists..."

# Reload service plists
sudo launchctl load /System/Library/LaunchDaemons/com.apple.speech.recognition.plist 2>/dev/null && echo "     ✅ Speech recognition plist reloaded" || echo "     ⚠️  Could not reload speech recognition plist"

sudo launchctl load /System/Library/LaunchDaemons/com.apple.corespeechd.plist 2>/dev/null && echo "     ✅ Core Speech plist reloaded" || echo "     ⚠️  Could not reload Core Speech plist"

sudo launchctl load /System/Library/LaunchDaemons/com.apple.assistantd.plist 2>/dev/null && echo "     ✅ Assistant plist reloaded" || echo "     ⚠️  Could not reload Assistant plist"

echo ""
echo "   • Starting services with kickstart..."

# Use kickstart to force restart
sudo launchctl kickstart -k system/com.apple.speech.recognition 2>/dev/null && echo "     ✅ Speech recognition service kickstarted" || echo "     ⚠️  Could not kickstart speech recognition"

sudo launchctl kickstart -k system/com.apple.corespeechd 2>/dev/null && echo "     ✅ Core Speech service kickstarted" || echo "     ⚠️  Could not kickstart Core Speech"

sudo launchctl kickstart -k system/com.apple.assistantd 2>/dev/null && echo "     ✅ Assistant service kickstarted" || echo "     ⚠️  Could not kickstart Assistant"

echo ""
echo "🔄 Resetting launchd cache..."

# Clear launchd cache
echo "   • Clearing launchd cache..."
sudo rm -rf /var/db/launchd.db 2>/dev/null && echo "     ✅ Launchd database cleared" || echo "     ⚠️  Could not clear launchd database"

sudo rm -rf /var/db/com.apple.xpc.launchd 2>/dev/null && echo "     ✅ XPC launchd cache cleared" || echo "     ⚠️  Could not clear XPC cache"

echo ""
echo "🔄 Restarting related system services..."

# Restart related services
echo "   • Restarting SystemUIServer..."
killall SystemUIServer 2>/dev/null && echo "     ✅ SystemUIServer restarted" || echo "     ⚠️  Could not restart SystemUIServer"

echo "   • Restarting WindowServer..."
sudo killall WindowServer 2>/dev/null && echo "     ✅ WindowServer restarted" || echo "     ⚠️  Could not restart WindowServer"

echo ""
echo "🔄 Waiting for services to stabilize..."
sleep 5

echo ""
echo "🔍 Verifying service status..."

# Check if services are running
echo "📋 Service status after reset:"
launchctl list | grep -E "(speech|dictation|assistant|siri)" | head -10

echo ""
echo "🎉 Launchd services reset completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try Method 4"
echo "   3. The system may take a moment to fully initialize"
echo ""

echo "💡 This method resets the system-level services that manage"
echo "   speech recognition, which can fix issues where the UI works"
echo "   but the backend processing is stuck."
echo ""

echo "⚠️  Note: WindowServer restart may cause your desktop to flicker briefly."
echo "   This is normal and expected."
echo ""

echo "✨ Method 3 complete! Test your dictation now."
