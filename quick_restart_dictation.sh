#!/bin/bash

# Quick macOS Dictation Restart
# Simple one-liner to restart voice-to-text without full reboot

echo "🔄 Restarting dictation..."
killall corespeechd
sleep 1
echo "✅ Done! Try your voice-to-text now (Control x2)"
