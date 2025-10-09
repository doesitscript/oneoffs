#!/bin/bash

# No-Sudo Dictation Fix
# User-level commands only - no admin privileges required

echo "🎤 No-Sudo Dictation Fix"
echo "========================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current dictation status..."

# Check current processes
echo "📋 Speech-related processes:"
ps aux | grep -E "(corespeechd|speechrecognitiond)" | grep -v grep

echo ""
echo "🔄 Step 1: Restarting speech processes (user-level)..."

# Kill speech processes (user-level)
echo "   • Terminating corespeechd..."
killall corespeechd 2>/dev/null && echo "     ✅ corespeechd terminated" || echo "     ℹ️  corespeechd not running"

echo "   • Terminating speechrecognitiond..."
killall speechrecognitiond 2>/dev/null && echo "     ✅ speechrecognitiond terminated" || echo "     ℹ️  speechrecognitiond not running"

echo "   • Terminating any other speech processes..."
pkill -f "speech" 2>/dev/null && echo "     ✅ Additional speech processes terminated" || echo "     ℹ️  No additional speech processes found"

echo ""
echo "🔄 Step 2: Clearing user-level caches and preferences..."

# Clear user-level caches
echo "   • Clearing speech recognition cache..."
rm -rf ~/Library/Caches/com.apple.speech.recognition* 2>/dev/null && echo "     ✅ Speech recognition cache cleared" || echo "     ℹ️  No speech cache found"

echo "   • Clearing Core Speech cache..."
rm -rf ~/Library/Caches/com.apple.corespeech* 2>/dev/null && echo "     ✅ Core Speech cache cleared" || echo "     ℹ️  No Core Speech cache found"

echo "   • Clearing assistant cache..."
rm -rf ~/Library/Caches/com.apple.assistant* 2>/dev/null && echo "     ✅ Assistant cache cleared" || echo "     ℹ️  No assistant cache found"

echo "   • Clearing Siri cache..."
rm -rf ~/Library/Caches/com.apple.siri* 2>/dev/null && echo "     ✅ Siri cache cleared" || echo "     ℹ️  No Siri cache found"

echo ""
echo "🔄 Step 3: Resetting user preferences..."

# Reset user preferences
echo "   • Clearing dictation preferences..."
rm -f ~/Library/Preferences/com.apple.assistant.plist 2>/dev/null && echo "     ✅ Dictation preferences cleared" || echo "     ℹ️  No dictation preferences found"

echo "   • Clearing speech recognition preferences..."
rm -f ~/Library/Preferences/com.apple.speech.recognition.AppleSpeechRecognition.prefs 2>/dev/null && echo "     ✅ Speech recognition preferences cleared" || echo "     ℹ️  No speech recognition preferences found"

echo "   • Clearing HIToolbox preferences..."
if [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]; then
    cp ~/Library/Preferences/com.apple.HIToolbox.plist ~/Library/Preferences/com.apple.HIToolbox.plist.backup 2>/dev/null
    echo "     ✅ HIToolbox preferences backed up"
    
    # Remove dictation-related keys
    defaults delete com.apple.HIToolbox AppleDictationAutoEnable 2>/dev/null && echo "     ✅ Dictation auto-enable setting removed" || echo "     ℹ️  No auto-enable setting found"
    defaults delete com.apple.HIToolbox AppleDictationEnabled 2>/dev/null && echo "     ✅ Dictation enabled setting removed" || echo "     ℹ️  No enabled setting found"
else
    echo "     ℹ️  No HIToolbox preferences found"
fi

echo ""
echo "🔄 Step 4: Restarting user-level services..."

# Restart user-level services
echo "   • Restarting SystemUIServer..."
killall SystemUIServer 2>/dev/null && echo "     ✅ SystemUIServer restarted" || echo "     ⚠️  Could not restart SystemUIServer"

echo "   • Restarting Dock..."
killall Dock 2>/dev/null && echo "     ✅ Dock restarted" || echo "     ⚠️  Could not restart Dock"

echo ""
echo "🔄 Step 5: Re-enabling dictation with clean settings..."

# Re-enable dictation
echo "   • Re-enabling dictation..."
defaults write com.apple.HIToolbox AppleDictationEnabled -bool true 2>/dev/null && echo "     ✅ Dictation re-enabled" || echo "     ⚠️  Could not re-enable dictation"

defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool true 2>/dev/null && echo "     ✅ Dictation auto-enable set" || echo "     ⚠️  Could not set auto-enable"

echo ""
echo "🔄 Step 6: Waiting for services to restart..."
sleep 3

echo ""
echo "🔍 Verifying service status..."

# Check if services restarted
if pgrep -f "corespeechd" > /dev/null; then
    echo "✅ corespeechd is running"
    ps aux | grep corespeechd | grep -v grep
else
    echo "⚠️  corespeechd has not restarted automatically"
fi

echo ""
echo "🎉 No-sudo dictation fix completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try the additional steps below"
echo ""

echo "🔧 Additional troubleshooting (no sudo required):"
echo "   • Check microphone permissions: System Settings > Privacy & Security > Microphone"
echo "   • Verify microphone selection: System Settings > Sound > Input"
echo "   • Disable Voice Control: System Settings > Accessibility > Voice Control"
echo "   • Try dictation in a different app (like TextEdit)"
echo ""

echo "💡 This method uses only user-level commands and should fix most"
echo "   dictation issues without requiring admin privileges."
echo ""

echo "✨ Test your dictation now!"
