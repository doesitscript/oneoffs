#!/bin/bash

# Quick No-Sudo Dictation Fix
# Simple one-liner approach without admin privileges

echo "🎤 Quick No-Sudo Dictation Fix"
echo "=============================="
echo ""

echo "🔄 Restarting dictation services..."
killall corespeechd 2>/dev/null && echo "✅ corespeechd terminated" || echo "ℹ️  corespeechd not running"
killall speechrecognitiond 2>/dev/null && echo "✅ speechrecognitiond terminated" || echo "ℹ️  speechrecognitiond not running"

echo "🔄 Clearing caches..."
rm -rf ~/Library/Caches/com.apple.speech* 2>/dev/null && echo "✅ Speech caches cleared" || echo "ℹ️  No speech caches found"
rm -rf ~/Library/Caches/com.apple.corespeech* 2>/dev/null && echo "✅ Core Speech caches cleared" || echo "ℹ️  No Core Speech caches found"

echo "🔄 Resetting preferences..."
rm -f ~/Library/Preferences/com.apple.assistant.plist 2>/dev/null && echo "✅ Dictation preferences cleared" || echo "ℹ️  No dictation preferences found"

echo "🔄 Restarting UI services..."
killall SystemUIServer 2>/dev/null && echo "✅ SystemUIServer restarted" || echo "⚠️  Could not restart SystemUIServer"

echo "🔄 Re-enabling dictation..."
defaults write com.apple.HIToolbox AppleDictationEnabled -bool true 2>/dev/null && echo "✅ Dictation re-enabled" || echo "⚠️  Could not re-enable dictation"

echo ""
echo "⏳ Waiting for services to restart..."
sleep 2

echo ""
echo "✅ Quick fix completed! Try your voice-to-text now (Control x2)"
echo ""
echo "💡 If it still doesn't work, run the full version: ./no_sudo_dictation_fix.sh"
