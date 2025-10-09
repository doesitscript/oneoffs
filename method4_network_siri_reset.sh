#!/bin/bash

# Method 4: Network and Siri Connectivity Reset
# Resets network connectivity and Siri-related services for dictation

echo "🌐 Method 4: Network and Siri Connectivity Reset"
echo "==============================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "🔍 Current network and Siri status..."

# Check network connectivity
echo "📋 Network connectivity:"
ping -c 1 apple.com >/dev/null 2>&1 && echo "✅ Internet connectivity: OK" || echo "❌ Internet connectivity: FAILED"

# Check Siri services
echo "📋 Siri-related processes:"
ps aux | grep -E "(siri|assistant)" | grep -v grep | head -5

echo ""
echo "🔄 Resetting network and Siri services..."

# Method 4A: Reset network configuration
echo "   • Resetting network configuration..."
sudo dscacheutil -flushcache 2>/dev/null && echo "     ✅ DNS cache flushed" || echo "     ⚠️  Could not flush DNS cache"

sudo killall -HUP mDNSResponder 2>/dev/null && echo "     ✅ mDNSResponder restarted" || echo "     ⚠️  Could not restart mDNSResponder"

# Method 4B: Reset Siri and Assistant services
echo "   • Resetting Siri and Assistant services..."
killall assistantd 2>/dev/null && echo "     ✅ Assistant daemon terminated" || echo "     ℹ️  Assistant daemon not running"

killall siri 2>/dev/null && echo "     ✅ Siri process terminated" || echo "     ℹ️  Siri process not running"

killall Siriknowledged 2>/dev/null && echo "     ✅ Siri Knowledge daemon terminated" || echo "     ℹ️  Siri Knowledge daemon not running"

# Method 4C: Clear Siri and Assistant caches
echo "   • Clearing Siri and Assistant caches..."
rm -rf ~/Library/Caches/com.apple.assistant* 2>/dev/null && echo "     ✅ Assistant caches cleared" || echo "     ℹ️  No Assistant caches found"

rm -rf ~/Library/Caches/com.apple.siri* 2>/dev/null && echo "     ✅ Siri caches cleared" || echo "     ℹ️  No Siri caches found"

rm -rf ~/Library/Caches/com.apple.Siriknowledged* 2>/dev/null && echo "     ✅ Siri Knowledge caches cleared" || echo "     ℹ️  No Siri Knowledge caches found"

# Method 4D: Reset Siri preferences
echo "   • Resetting Siri preferences..."
rm -f ~/Library/Preferences/com.apple.assistant.plist 2>/dev/null && echo "     ✅ Assistant preferences cleared" || echo "     ℹ️  No Assistant preferences found"

rm -f ~/Library/Preferences/com.apple.siri.plist 2>/dev/null && echo "     ✅ Siri preferences cleared" || echo "     ℹ️  No Siri preferences found"

rm -f ~/Library/Preferences/com.apple.Siriknowledged.plist 2>/dev/null && echo "     ✅ Siri Knowledge preferences cleared" || echo "     ℹ️  No Siri Knowledge preferences found"

# Method 4E: Reset network-related speech services
echo "   • Resetting network-related speech services..."
sudo launchctl stop system/com.apple.assistantd 2>/dev/null && echo "     ✅ Assistant daemon stopped" || echo "     ℹ️  Assistant daemon not running"

sudo launchctl stop system/com.apple.Siriknowledged 2>/dev/null && echo "     ✅ Siri Knowledge daemon stopped" || echo "     ℹ️  Siri Knowledge daemon not running"

sleep 2

sudo launchctl start system/com.apple.assistantd 2>/dev/null && echo "     ✅ Assistant daemon started" || echo "     ⚠️  Could not start Assistant daemon"

sudo launchctl start system/com.apple.Siriknowledged 2>/dev/null && echo "     ✅ Siri Knowledge daemon started" || echo "     ⚠️  Could not start Siri Knowledge daemon"

# Method 4F: Reset speech recognition network settings
echo "   • Resetting speech recognition network settings..."
defaults delete com.apple.speech.recognition.AppleSpeechRecognition 2>/dev/null && echo "     ✅ Speech recognition network settings cleared" || echo "     ℹ️  No speech recognition network settings found"

# Method 4G: Test network connectivity to Apple services
echo ""
echo "🔄 Testing connectivity to Apple services..."

echo "   • Testing connectivity to Apple's speech services..."
ping -c 1 speech.apple.com >/dev/null 2>&1 && echo "     ✅ Apple speech services: Reachable" || echo "     ⚠️  Apple speech services: Not reachable"

ping -c 1 siri.apple.com >/dev/null 2>&1 && echo "     ✅ Apple Siri services: Reachable" || echo "     ⚠️  Apple Siri services: Not reachable"

# Method 4H: Reset network timeouts and connections
echo ""
echo "   • Resetting network connections..."
sudo pfctl -f /etc/pf.conf 2>/dev/null && echo "     ✅ Packet filter reset" || echo "     ℹ️  No packet filter to reset"

# Method 4I: Restart network-related services
echo ""
echo "   • Restarting network-related services..."
sudo launchctl kickstart -k system/com.apple.networkd 2>/dev/null && echo "     ✅ Network daemon restarted" || echo "     ⚠️  Could not restart network daemon"

echo ""
echo "🔄 Waiting for services to stabilize..."
sleep 3

echo ""
echo "🔍 Verifying service status..."

# Check if services restarted
echo "📋 Service status after reset:"
ps aux | grep -E "(assistant|siri)" | grep -v grep | head -5

echo ""
echo "🎉 Network and Siri connectivity reset completed!"
echo ""
echo "📝 Next steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, try Method 5"
echo "   3. Check your internet connection if issues persist"
echo ""

echo "💡 This method resets network connectivity and Siri services,"
echo "   which are often used for cloud-based speech processing."
echo ""

echo "⚠️  Note: If you're using offline dictation, this method may not"
echo "   be necessary, but it won't hurt to run it."
echo ""

echo "✨ Method 4 complete! Test your dictation now."
