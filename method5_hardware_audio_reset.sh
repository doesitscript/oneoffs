#!/bin/bash

# Method 5: Hardware-Level Audio Reset
# Resets audio hardware drivers and system-level audio components

echo "🔧 Method 5: Hardware-Level Audio Reset"
echo "======================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current audio hardware status..."

# Check audio hardware
echo "📋 Audio hardware information:"
system_profiler SPAudioDataType | grep -A 10 "Input" | head -15

echo ""
echo "🔄 Resetting audio hardware drivers..."

# Method 5A: Reset audio hardware drivers
echo "   • Resetting audio hardware drivers..."
sudo kextunload /System/Library/Extensions/AppleHDA.kext 2>/dev/null && echo "     ✅ AppleHDA driver unloaded" || echo "     ℹ️  AppleHDA driver not loaded"

sudo kextunload /System/Library/Extensions/AppleHDAController.kext 2>/dev/null && echo "     ✅ AppleHDAController driver unloaded" || echo "     ℹ️  AppleHDAController driver not loaded"

sudo kextunload /System/Library/Extensions/IOAudioFamily.kext 2>/dev/null && echo "     ✅ IOAudioFamily driver unloaded" || echo "     ℹ️  IOAudioFamily driver not loaded"

sleep 2

sudo kextload /System/Library/Extensions/IOAudioFamily.kext 2>/dev/null && echo "     ✅ IOAudioFamily driver reloaded" || echo "     ⚠️  Could not reload IOAudioFamily driver"

sudo kextload /System/Library/Extensions/AppleHDAController.kext 2>/dev/null && echo "     ✅ AppleHDAController driver reloaded" || echo "     ⚠️  Could not reload AppleHDAController driver"

sudo kextload /System/Library/Extensions/AppleHDA.kext 2>/dev/null && echo "     ✅ AppleHDA driver reloaded" || echo "     ⚠️  Could not reload AppleHDA driver"

# Method 5B: Reset audio system preferences
echo ""
echo "   • Resetting audio system preferences..."
sudo rm -f /Library/Preferences/Audio/com.apple.audio.SystemSettings.plist 2>/dev/null && echo "     ✅ System audio preferences cleared" || echo "     ℹ️  No system audio preferences found"

sudo rm -f /Library/Preferences/Audio/com.apple.audio.AudioMIDISetup.plist 2>/dev/null && echo "     ✅ Audio MIDI system preferences cleared" || echo "     ℹ️  No Audio MIDI system preferences found"

# Method 5C: Reset audio HAL (Hardware Abstraction Layer)
echo ""
echo "   • Resetting audio HAL..."
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist 2>/dev/null && echo "     ✅ Core Audio daemon unloaded" || echo "     ℹ️  Core Audio daemon not loaded"

sleep 2

sudo launchctl load /System/Library/LaunchDaemons/com.apple.audio.coreaudiod.plist 2>/dev/null && echo "     ✅ Core Audio daemon reloaded" || echo "     ⚠️  Could not reload Core Audio daemon"

# Method 5D: Reset audio component registrar
echo ""
echo "   • Resetting audio component registrar..."
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.audio.AudioComponentRegistrar.plist 2>/dev/null && echo "     ✅ Audio Component Registrar unloaded" || echo "     ℹ️  Audio Component Registrar not loaded"

sleep 2

sudo launchctl load /System/Library/LaunchDaemons/com.apple.audio.AudioComponentRegistrar.plist 2>/dev/null && echo "     ✅ Audio Component Registrar reloaded" || echo "     ⚠️  Could not reload Audio Component Registrar"

# Method 5E: Clear audio caches and temporary files
echo ""
echo "   • Clearing audio caches and temporary files..."
sudo rm -rf /var/db/AudioComponentRegistrar 2>/dev/null && echo "     ✅ Audio Component Registrar cache cleared" || echo "     ℹ️  No Audio Component Registrar cache found"

sudo rm -rf /var/db/CoreAudio 2>/dev/null && echo "     ✅ Core Audio cache cleared" || echo "     ℹ️  No Core Audio cache found"

rm -rf ~/Library/Caches/com.apple.audio.AudioComponentRegistrar* 2>/dev/null && echo "     ✅ User audio component cache cleared" || echo "     ℹ️  No user audio component cache found"

# Method 5F: Reset audio device permissions
echo ""
echo "   • Resetting audio device permissions..."
sudo rm -f /Library/Preferences/com.apple.security.media.microphone.plist 2>/dev/null && echo "     ✅ System microphone permissions cleared" || echo "     ℹ️  No system microphone permissions found"

rm -f ~/Library/Preferences/com.apple.security.media.microphone.plist 2>/dev/null && echo "     ✅ User microphone permissions cleared" || echo "     ℹ️  No user microphone permissions found"

# Method 5G: Reset audio routing and device selection
echo ""
echo "   • Resetting audio routing..."
defaults delete com.apple.audio.SystemSettings 2>/dev/null && echo "     ✅ Audio system settings reset" || echo "     ℹ️  No audio system settings to reset"

defaults delete com.apple.audio.AudioMIDISetup 2>/dev/null && echo "     ✅ Audio MIDI setup reset" || echo "     ℹ️  No Audio MIDI setup to reset"

# Method 5H: Force audio hardware detection
echo ""
echo "   • Forcing audio hardware detection..."
sudo kextcache -system-prelinked-kernel 2>/dev/null && echo "     ✅ Kernel extension cache rebuilt" || echo "     ⚠️  Could not rebuild kernel extension cache"

sudo kextcache -system-caches 2>/dev/null && echo "     ✅ System caches rebuilt" || echo "     ⚠️  Could not rebuild system caches"

# Method 5I: Restart audio services
echo ""
echo "   • Restarting audio services..."
sudo launchctl kickstart -k system/com.apple.audio.coreaudiod 2>/dev/null && echo "     ✅ Core Audio daemon kickstarted" || echo "     ⚠️  Could not kickstart Core Audio daemon"

sudo launchctl kickstart -k system/com.apple.audio.AudioComponentRegistrar 2>/dev/null && echo "     ✅ Audio Component Registrar kickstarted" || echo "     ⚠️  Could not kickstart Audio Component Registrar"

echo ""
echo "🔄 Waiting for hardware to initialize..."
sleep 5

echo ""
echo "🔍 Verifying audio hardware status..."

# Check if audio hardware is detected
echo "📋 Audio hardware after reset:"
system_profiler SPAudioDataType | grep -A 5 "Input" | head -10

# Check if Core Audio is running
if pgrep -f "coreaudiod" > /dev/null; then
    echo "✅ Core Audio daemon is running"
else
    echo "❌ Core Audio daemon is not running"
fi

# Test audio input device
echo ""
echo "🎤 Testing audio input device..."
osascript -e "tell application \"System Events\" to get name of current audio input device" 2>/dev/null && echo "✅ Audio input device detected" || echo "❌ Could not detect audio input device"

echo ""
echo "🎉 Hardware-level audio reset completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try the manual steps below"
echo "   3. You may need to re-grant microphone permissions"
echo ""

echo "💡 This method resets audio hardware drivers and system-level"
echo "   audio components, which can fix deep hardware-related issues."
echo ""

echo "⚠️  Important notes:"
echo "   • You may need to re-grant microphone permissions"
echo "   • Go to: System Settings > Privacy & Security > Microphone"
echo "   • Make sure Terminal and other apps have microphone access"
echo ""

echo "🔧 If this method doesn't work, try these manual steps:"
echo "   1. Restart your Mac (this resets all hardware drivers)"
echo "   2. Check System Settings > Sound > Input"
echo "   3. Try a different microphone if available"
echo "   4. Reset NVRAM: Restart and hold Option+Command+P+R for 20 seconds"
echo ""

echo "✨ Method 5 complete! Test your dictation now."
