#!/bin/bash

# macOS Dictation Restart Script
# This script restarts the corespeechd process to fix voice-to-text issues
# without requiring a full system restart

echo "🎤 macOS Dictation Restart Tool"
echo "================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Checking current dictation processes..."

# Check if corespeechd is running
if pgrep -f "corespeechd" > /dev/null; then
    echo "✅ corespeechd process found and running"
    echo "📋 Process details:"
    ps aux | grep corespeechd | grep -v grep
    echo ""
else
    echo "⚠️  corespeechd process not found (may be normal if dictation is disabled)"
    echo ""
fi

echo "🔄 Restarting dictation services..."

# Kill the corespeechd process (it will automatically restart)
echo "   • Terminating corespeechd process..."
if killall corespeechd 2>/dev/null; then
    echo "   ✅ corespeechd process terminated successfully"
else
    echo "   ⚠️  corespeechd process was not running or already terminated"
fi

# Wait a moment for the process to restart
echo "   • Waiting for process to restart..."
sleep 2

# Check if the process restarted
if pgrep -f "corespeechd" > /dev/null; then
    echo "   ✅ corespeechd process has restarted successfully"
    echo ""
    echo "🎉 Dictation services have been restarted!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Try using your voice-to-text shortcut (Control x2)"
    echo "   2. If it still doesn't work, try the additional troubleshooting steps below"
    echo ""
else
    echo "   ⚠️  corespeechd process has not restarted automatically"
    echo "   This might indicate a deeper issue with dictation services"
    echo ""
fi

echo "🔧 Additional troubleshooting options:"
echo "   • Disable and re-enable dictation in System Settings > Keyboard > Dictation"
echo "   • Check microphone permissions in System Settings > Privacy & Security > Microphone"
echo "   • Restart the Speech Recognition service: sudo launchctl kickstart -k system/com.apple.speech.recognition"
echo ""

echo "💡 Tip: You can run this script anytime dictation stops working!"
echo "   Just execute: ./restart_dictation.sh"
echo ""

# Optional: Try to restart speech recognition service as well
read -p "🤔 Would you like to also restart the Speech Recognition service? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Restarting Speech Recognition service..."
    if sudo launchctl kickstart -k system/com.apple.speech.recognition 2>/dev/null; then
        echo "✅ Speech Recognition service restarted"
    else
        echo "⚠️  Could not restart Speech Recognition service (may require admin privileges)"
    fi
fi

echo ""
echo "✨ Script completed! Try your voice-to-text now."
