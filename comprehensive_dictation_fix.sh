#!/bin/bash

# Comprehensive macOS Dictation Fix
# Addresses issues where mic icon appears but voice processing fails

echo "🎤 Comprehensive macOS Dictation Fix"
echo "===================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Diagnosing dictation issues..."

# Check current processes
echo "📋 Current speech-related processes:"
ps aux | grep -E "(corespeechd|speech|dictation)" | grep -v grep
echo ""

# Step 1: Kill all speech-related processes
echo "🔄 Step 1: Restarting speech recognition processes..."

echo "   • Terminating corespeechd..."
killall corespeechd 2>/dev/null && echo "     ✅ corespeechd terminated" || echo "     ⚠️  corespeechd not running"

echo "   • Terminating speech recognition daemon..."
killall speechrecognitiond 2>/dev/null && echo "     ✅ speechrecognitiond terminated" || echo "     ⚠️  speechrecognitiond not running"

echo "   • Terminating any remaining speech processes..."
pkill -f "speech" 2>/dev/null && echo "     ✅ Additional speech processes terminated" || echo "     ℹ️  No additional speech processes found"

# Step 2: Restart system services
echo ""
echo "🔄 Step 2: Restarting system speech services..."

echo "   • Restarting Speech Recognition service..."
sudo launchctl kickstart -k system/com.apple.speech.recognition 2>/dev/null && echo "     ✅ Speech Recognition service restarted" || echo "     ⚠️  Could not restart Speech Recognition service"

echo "   • Restarting Core Speech service..."
sudo launchctl kickstart -k system/com.apple.corespeechd 2>/dev/null && echo "     ✅ Core Speech service restarted" || echo "     ⚠️  Could not restart Core Speech service"

# Step 3: Clear speech caches and preferences
echo ""
echo "🔄 Step 3: Clearing speech caches and preferences..."

echo "   • Clearing speech recognition cache..."
rm -rf ~/Library/Caches/com.apple.speech.recognition* 2>/dev/null && echo "     ✅ Speech recognition cache cleared" || echo "     ℹ️  No speech cache found"

echo "   • Clearing Core Speech cache..."
rm -rf ~/Library/Caches/com.apple.corespeech* 2>/dev/null && echo "     ✅ Core Speech cache cleared" || echo "     ℹ️  No Core Speech cache found"

echo "   • Clearing dictation preferences..."
if [ -f ~/Library/Preferences/com.apple.assistant.plist ]; then
    rm ~/Library/Preferences/com.apple.assistant.plist && echo "     ✅ Dictation preferences cleared" || echo "     ⚠️  Could not clear preferences"
else
    echo "     ℹ️  No dictation preferences found"
fi

# Step 4: Check microphone and audio
echo ""
echo "🔄 Step 4: Checking audio system..."

echo "   • Current audio input devices:"
system_profiler SPAudioDataType | grep -A 5 "Input" | head -10

echo ""
echo "   • Checking microphone permissions..."
# This will show if microphone access is granted
if [ -f ~/Library/Preferences/com.apple.security.media.microphone.plist ]; then
    echo "     ℹ️  Microphone permissions file exists"
else
    echo "     ⚠️  No microphone permissions file found"
fi

# Step 5: Wait and verify
echo ""
echo "🔄 Step 5: Waiting for services to restart..."
sleep 3

echo "   • Checking if corespeechd restarted..."
if pgrep -f "corespeechd" > /dev/null; then
    echo "     ✅ corespeechd is running"
    ps aux | grep corespeechd | grep -v grep
else
    echo "     ⚠️  corespeechd has not restarted"
fi

# Step 6: Additional recommendations
echo ""
echo "🔧 Additional troubleshooting steps:"
echo ""
echo "   1. Check microphone selection:"
echo "      System Settings > Sound > Input"
echo ""
echo "   2. Verify microphone permissions:"
echo "      System Settings > Privacy & Security > Microphone"
echo "      Make sure 'Terminal' and other apps have microphone access"
echo ""
echo "   3. Disable Voice Control if enabled:"
echo "      System Settings > Accessibility > Voice Control"
echo ""
echo "   4. Try dictation in a different app (like TextEdit)"
echo ""
echo "   5. If still not working, try Safe Mode:"
echo "      Restart and hold Shift key during boot"
echo ""

echo "🎉 Comprehensive fix completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2) now"
echo "   2. If it still doesn't work, check the additional steps above"
echo "   3. You may need to re-grant microphone permissions"
echo ""

# Optional: Test microphone
read -p "🤔 Would you like to test microphone input? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎤 Testing microphone..."
    echo "   • Recording 3 seconds of audio..."
    if command -v rec >/dev/null 2>&1; then
        timeout 3s rec -t wav /tmp/mic_test.wav 2>/dev/null && echo "   ✅ Microphone test completed" || echo "   ⚠️  Microphone test failed"
        rm -f /tmp/mic_test.wav 2>/dev/null
    else
        echo "   ℹ️  Install 'sox' package to test microphone: brew install sox"
    fi
fi

echo ""
echo "✨ All done! Try your dictation now."
