#!/bin/bash

# Master Script: Run All Dictation Fix Methods
# Runs all 5 methods in sequence for comprehensive fix

echo "🎤 Master Dictation Fix - All Methods"
echo "====================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

echo "This script will run all 5 dictation fix methods in sequence."
echo "Each method targets a different aspect of the speech recognition system."
echo ""

read -p "🤔 Do you want to run all methods? This may take several minutes. (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled by user."
    exit 0
fi

echo ""
echo "🚀 Starting comprehensive dictation fix..."
echo ""

# Method 1: Audio System Reset
echo "=========================================="
echo "🎵 Running Method 1: Audio System Reset"
echo "=========================================="
./method1_audio_system_reset.sh
echo ""
echo "⏸️  Pausing between methods..."
sleep 3

# Method 2: System Preferences Reset
echo "=========================================="
echo "⚙️  Running Method 2: System Preferences Reset"
echo "=========================================="
./method2_system_preferences_reset.sh
echo ""
echo "⏸️  Pausing between methods..."
sleep 3

# Method 3: Launchd Services Reset
echo "=========================================="
echo "🚀 Running Method 3: Launchd Services Reset"
echo "=========================================="
./method3_launchd_services_reset.sh
echo ""
echo "⏸️  Pausing between methods..."
sleep 3

# Method 4: Network and Siri Reset
echo "=========================================="
echo "🌐 Running Method 4: Network and Siri Reset"
echo "=========================================="
./method4_network_siri_reset.sh
echo ""
echo "⏸️  Pausing between methods..."
sleep 3

# Method 5: Hardware Audio Reset
echo "=========================================="
echo "🔧 Running Method 5: Hardware Audio Reset"
echo "=========================================="
./method5_hardware_audio_reset.sh

echo ""
echo "🎉 All methods completed!"
echo ""
echo "📝 Final steps:"
echo "   1. Try your voice-to-text shortcut (Control x2)"
echo "   2. If it still doesn't work, check microphone permissions"
echo "   3. Go to: System Settings > Privacy & Security > Microphone"
echo "   4. Make sure Terminal and other apps have microphone access"
echo ""

echo "💡 If dictation still doesn't work after all methods:"
echo "   • Try restarting your Mac (this resets all hardware drivers)"
echo "   • Check System Settings > Sound > Input"
echo "   • Try a different microphone if available"
echo "   • Reset NVRAM: Restart and hold Option+Command+P+R for 20 seconds"
echo ""

echo "✨ Comprehensive fix complete! Test your dictation now."
