#!/bin/bash

# Method 1: Audio System Reset
# Resets Core Audio and audio system components

echo "🎵 Method 1: Audio System Reset"
echo "==============================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current audio system status..."

# Check Core Audio processes
echo "📋 Core Audio processes:"
ps aux | grep -E "(coreaudiod|AudioComponentRegistrar)" | grep -v grep

echo ""
echo "🔄 Resetting Core Audio system..."

# Method 1A: Kill and restart Core Audio daemon
echo "   • Restarting Core Audio daemon..."
sudo killall coreaudiod 2>/dev/null && echo "     ✅ coreaudiod terminated" || echo "     ⚠️  coreaudiod not running"

# Wait for it to restart
sleep 2

# Method 1B: Reset audio system preferences
echo "   • Clearing audio system preferences..."
rm -f ~/Library/Preferences/com.apple.audio.AudioMIDISetup.plist 2>/dev/null && echo "     ✅ Audio MIDI preferences cleared" || echo "     ℹ️  No Audio MIDI preferences found"

rm -f ~/Library/Preferences/com.apple.audio.SystemSettings.plist 2>/dev/null && echo "     ✅ Audio system preferences cleared" || echo "     ℹ️  No audio system preferences found"

# Method 1C: Reset audio component cache
echo "   • Clearing audio component cache..."
rm -rf ~/Library/Caches/com.apple.audio.AudioComponentRegistrar* 2>/dev/null && echo "     ✅ Audio component cache cleared" || echo "     ℹ️  No audio component cache found"

# Method 1D: Reset audio HAL (Hardware Abstraction Layer)
echo "   • Resetting audio HAL..."
sudo launchctl kickstart -k system/com.apple.audio.coreaudiod 2>/dev/null && echo "     ✅ Audio HAL restarted" || echo "     ⚠️  Could not restart audio HAL"

# Method 1E: Reset audio routing
echo "   • Resetting audio routing..."
sudo launchctl kickstart -k system/com.apple.audio.AudioComponentRegistrar 2>/dev/null && echo "     ✅ Audio routing restarted" || echo "     ⚠️  Could not restart audio routing"

echo ""
echo "🔄 Resetting microphone-specific settings..."

# Reset microphone preferences
echo "   • Clearing microphone preferences..."
rm -f ~/Library/Preferences/com.apple.audio.SystemSettings.plist 2>/dev/null && echo "     ✅ Microphone preferences cleared" || echo "     ℹ️  No microphone preferences found"

# Reset audio input settings
echo "   • Resetting audio input settings..."
defaults delete com.apple.audio.SystemSettings 2>/dev/null && echo "     ✅ Audio input settings reset" || echo "     ℹ️  No audio input settings to reset"

echo ""
echo "🔄 Testing audio system..."

# Check if Core Audio restarted
if pgrep -f "coreaudiod" > /dev/null; then
    echo "   ✅ Core Audio daemon is running"
else
    echo "   ⚠️  Core Audio daemon may not have restarted properly"
fi

# Test audio input
echo "   • Testing audio input..."
osascript -e "tell application \"System Events\" to get name of current audio input device" 2>/dev/null && echo "     ✅ Audio input device detected" || echo "     ⚠️  Could not detect audio input device"

echo ""
echo "🎉 Audio system reset completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try Method 2"
echo "   3. Check System Settings > Sound > Input to verify microphone"
echo ""

echo "💡 This method resets the entire audio system, which often fixes"
echo "   microphone processing issues that simple speech service restarts can't."
echo ""

echo "✨ Method 1 complete! Test your dictation now."
