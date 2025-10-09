#!/bin/bash

# Method 2: System Preferences Reset
# Resets system preferences and plist files that control dictation

echo "⚙️  Method 2: System Preferences Reset"
echo "======================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current system preferences status..."

# Check for existing preference files
echo "📋 Dictation-related preference files:"
find ~/Library/Preferences -name "*speech*" -o -name "*dictation*" -o -name "*assistant*" -o -name "*siri*" 2>/dev/null | head -10

echo ""
echo "🔄 Resetting system preferences..."

# Method 2A: Reset HIToolbox (Human Interface Toolbox) preferences
echo "   • Resetting HIToolbox preferences..."
if [ -f ~/Library/Preferences/com.apple.HIToolbox.plist ]; then
    cp ~/Library/Preferences/com.apple.HIToolbox.plist ~/Library/Preferences/com.apple.HIToolbox.plist.backup 2>/dev/null
    echo "     ✅ HIToolbox preferences backed up"
    
    # Remove dictation-related keys
    defaults delete com.apple.HIToolbox AppleDictationAutoEnable 2>/dev/null && echo "     ✅ Dictation auto-enable setting removed" || echo "     ℹ️  No auto-enable setting found"
    defaults delete com.apple.HIToolbox AppleDictationEnabled 2>/dev/null && echo "     ✅ Dictation enabled setting removed" || echo "     ℹ️  No enabled setting found"
    defaults delete com.apple.HIToolbox AppleDictationLanguage 2>/dev/null && echo "     ✅ Dictation language setting removed" || echo "     ℹ️  No language setting found"
else
    echo "     ℹ️  No HIToolbox preferences found"
fi

# Method 2B: Reset speech recognition preferences
echo "   • Resetting speech recognition preferences..."
rm -f ~/Library/Preferences/com.apple.speech.recognition.AppleSpeechRecognition.prefs 2>/dev/null && echo "     ✅ Speech recognition preferences cleared" || echo "     ℹ️  No speech recognition preferences found"

rm -f ~/Library/Preferences/com.apple.speech.recognition.prefs 2>/dev/null && echo "     ✅ Speech recognition prefs cleared" || echo "     ℹ️  No speech recognition prefs found"

# Method 2C: Reset assistant/Siri preferences
echo "   • Resetting assistant preferences..."
rm -f ~/Library/Preferences/com.apple.assistant.plist 2>/dev/null && echo "     ✅ Assistant preferences cleared" || echo "     ℹ️  No assistant preferences found"

rm -f ~/Library/Preferences/com.apple.assistant.support.plist 2>/dev/null && echo "     ✅ Assistant support preferences cleared" || echo "     ℹ️  No assistant support preferences found"

# Method 2D: Reset Core Speech preferences
echo "   • Resetting Core Speech preferences..."
rm -f ~/Library/Preferences/com.apple.corespeech.plist 2>/dev/null && echo "     ✅ Core Speech preferences cleared" || echo "     ℹ️  No Core Speech preferences found"

rm -f ~/Library/Preferences/com.apple.corespeechd.plist 2>/dev/null && echo "     ✅ Core Speech daemon preferences cleared" || echo "     ℹ️  No Core Speech daemon preferences found"

# Method 2E: Reset input method preferences
echo "   • Resetting input method preferences..."
rm -f ~/Library/Preferences/com.apple.inputmethod.SpellChecker.plist 2>/dev/null && echo "     ✅ Input method preferences cleared" || echo "     ℹ️  No input method preferences found"

# Method 2F: Reset accessibility preferences
echo "   • Resetting accessibility preferences..."
rm -f ~/Library/Preferences/com.apple.universalaccess.plist 2>/dev/null && echo "     ✅ Universal access preferences cleared" || echo "     ℹ️  No universal access preferences found"

# Method 2G: Reset system-wide dictation settings
echo "   • Resetting system-wide dictation settings..."
sudo defaults delete /Library/Preferences/com.apple.speech.recognition.AppleSpeechRecognition.prefs 2>/dev/null && echo "     ✅ System-wide speech recognition preferences cleared" || echo "     ℹ️  No system-wide speech preferences found"

echo ""
echo "🔄 Resetting user defaults..."

# Reset user defaults for dictation
echo "   • Resetting user defaults..."
defaults delete com.apple.speech.recognition.AppleSpeechRecognition 2>/dev/null && echo "     ✅ User speech recognition defaults cleared" || echo "     ℹ️  No user speech defaults found"

defaults delete com.apple.dictation 2>/dev/null && echo "     ✅ User dictation defaults cleared" || echo "     ℹ️  No user dictation defaults found"

defaults delete com.apple.assistant 2>/dev/null && echo "     ✅ User assistant defaults cleared" || echo "     ℹ️  No user assistant defaults found"

echo ""
echo "🔄 Clearing preference caches..."

# Clear preference caches
echo "   • Clearing preference caches..."
rm -rf ~/Library/Caches/com.apple.preference* 2>/dev/null && echo "     ✅ Preference caches cleared" || echo "     ℹ️  No preference caches found"

rm -rf ~/Library/Caches/com.apple.speech* 2>/dev/null && echo "     ✅ Speech caches cleared" || echo "     ℹ️  No speech caches found"

echo ""
echo "🔄 Restarting preference-related services..."

# Restart services that use preferences
echo "   • Restarting SystemUIServer..."
killall SystemUIServer 2>/dev/null && echo "     ✅ SystemUIServer restarted" || echo "     ⚠️  Could not restart SystemUIServer"

echo "   • Restarting Dock..."
killall Dock 2>/dev/null && echo "     ✅ Dock restarted" || echo "     ⚠️  Could not restart Dock"

echo ""
echo "🔄 Re-enabling dictation with clean preferences..."

# Re-enable dictation with clean settings
echo "   • Re-enabling dictation..."
defaults write com.apple.HIToolbox AppleDictationEnabled -bool true 2>/dev/null && echo "     ✅ Dictation re-enabled" || echo "     ⚠️  Could not re-enable dictation"

defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool true 2>/dev/null && echo "     ✅ Dictation auto-enable set" || echo "     ⚠️  Could not set auto-enable"

echo ""
echo "🎉 System preferences reset completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try Method 3"
echo "   3. You may need to re-configure dictation in System Settings"
echo ""

echo "💡 This method clears all corrupted preference files that can cause"
echo "   the mic icon to appear but prevent voice processing."
echo ""

echo "⚠️  Note: You may need to re-grant microphone permissions after this reset."
echo "   Go to: System Settings > Privacy & Security > Microphone"
echo ""

echo "✨ Method 2 complete! Test your dictation now."
