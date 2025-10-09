#!/bin/bash

# Microphone and Dictation Status Checker
# Diagnoses microphone and speech recognition issues

echo "🎤 Microphone & Dictation Status Checker"
echo "========================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Checking microphone hardware..."

# Check audio input devices
echo "📱 Available audio input devices:"
system_profiler SPAudioDataType | grep -A 10 "Input" | grep -E "(Input|Built-in|External|USB)"

echo ""
echo "🔍 Checking speech recognition processes..."

# Check speech processes
echo "📋 Speech-related processes:"
if pgrep -f "corespeechd" > /dev/null; then
    echo "✅ corespeechd is running:"
    ps aux | grep corespeechd | grep -v grep
else
    echo "❌ corespeechd is NOT running"
fi

if pgrep -f "speechrecognitiond" > /dev/null; then
    echo "✅ speechrecognitiond is running:"
    ps aux | grep speechrecognitiond | grep -v grep
else
    echo "❌ speechrecognitiond is NOT running"
fi

echo ""
echo "🔍 Checking microphone permissions..."

# Check microphone permissions
echo "📋 Microphone permission files:"
if [ -f ~/Library/Preferences/com.apple.security.media.microphone.plist ]; then
    echo "✅ Microphone permissions file exists"
    echo "📄 Contents:"
    plutil -p ~/Library/Preferences/com.apple.security.media.microphone.plist 2>/dev/null || echo "   (Could not read permissions file)"
else
    echo "❌ No microphone permissions file found"
fi

echo ""
echo "🔍 Checking dictation settings..."

# Check if dictation is enabled
echo "📋 Dictation configuration:"
if [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]; then
    echo "✅ HIToolbox preferences found"
    # Check for dictation settings
    plutil -p ~/Library/Preferences/com.apple.HIToolbox.plist | grep -i dictation || echo "   No dictation settings found in HIToolbox"
else
    echo "❌ No HIToolbox preferences found"
fi

echo ""
echo "🔍 Checking system audio settings..."

# Check current audio input
echo "📋 Current audio input device:"
osascript -e "tell application \"System Events\" to get name of current audio input device" 2>/dev/null || echo "   Could not determine current input device"

echo ""
echo "🔍 Checking for conflicting services..."

# Check for Voice Control
echo "📋 Voice Control status:"
if [ -f ~/Library/Preferences/com.apple.speech.voicecontrol.plist ]; then
    echo "⚠️  Voice Control preferences found (may conflict with dictation)"
else
    echo "✅ No Voice Control preferences found"
fi

echo ""
echo "🔍 Testing microphone access..."

# Simple microphone test
echo "📋 Microphone access test:"
if command -v rec >/dev/null 2>&1; then
    echo "   Testing microphone for 2 seconds..."
    timeout 2s rec -t wav /tmp/mic_test.wav 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "   ✅ Microphone is accessible"
        # Check if file has content (not just silence)
        if [ -s /tmp/mic_test.wav ]; then
            echo "   ✅ Microphone is receiving audio"
        else
            echo "   ⚠️  Microphone accessible but no audio detected"
        fi
    else
        echo "   ❌ Microphone access failed"
    fi
    rm -f /tmp/mic_test.wav 2>/dev/null
else
    echo "   ℹ️  Install 'sox' to test microphone: brew install sox"
fi

echo ""
echo "🔍 Checking system logs for speech errors..."

# Check recent speech-related errors
echo "📋 Recent speech recognition errors (last 10):"
log show --predicate 'subsystem == "com.apple.speech"' --last 1h --style compact 2>/dev/null | tail -10 || echo "   No recent speech logs found"

echo ""
echo "📝 Summary and Recommendations:"
echo "================================"

# Provide recommendations based on findings
if ! pgrep -f "corespeechd" > /dev/null; then
    echo "❌ corespeechd is not running - this is likely the main issue"
    echo "   → Run: ./comprehensive_dictation_fix.sh"
fi

if [ ! -f ~/Library/Preferences/com.apple.security.media.microphone.plist ]; then
    echo "❌ No microphone permissions found"
    echo "   → Check: System Settings > Privacy & Security > Microphone"
fi

if [ -f ~/Library/Preferences/com.apple.speech.voicecontrol.plist ]; then
    echo "⚠️  Voice Control may be conflicting with dictation"
    echo "   → Disable: System Settings > Accessibility > Voice Control"
fi

echo ""
echo "💡 Quick fixes to try:"
echo "   1. Run comprehensive fix: ./comprehensive_dictation_fix.sh"
echo "   2. Check microphone permissions in System Settings"
echo "   3. Disable Voice Control if enabled"
echo "   4. Try dictation in TextEdit app"
echo ""

echo "✨ Diagnostic complete!"
