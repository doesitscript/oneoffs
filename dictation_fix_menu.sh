#!/bin/bash

# Dictation Fix Menu
# Interactive menu to choose which method to run

echo "🎤 macOS Dictation Fix Menu"
echo "==========================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script is designed for macOS only."
    exit 1
fi

while true; do
    echo "Choose a method to fix your dictation issue:"
    echo ""
    echo "1. 🎵 Audio System Reset (Core Audio, audio drivers)"
    echo "2. ⚙️  System Preferences Reset (plist files, preferences)"
    echo "3. 🚀 Launchd Services Reset (system services, daemons)"
    echo "4. 🌐 Network & Siri Reset (connectivity, cloud services)"
    echo "5. 🔧 Hardware Audio Reset (audio hardware drivers)"
    echo "6. 🎯 Run All Methods (comprehensive fix)"
    echo "7. 🔍 Check Microphone Status (diagnostic)"
    echo "8. ❌ Exit"
    echo ""
    
    read -p "Enter your choice (1-8): " choice
    
    case $choice in
        1)
            echo ""
            echo "🎵 Running Method 1: Audio System Reset..."
            echo "=========================================="
            ./method1_audio_system_reset.sh
            ;;
        2)
            echo ""
            echo "⚙️  Running Method 2: System Preferences Reset..."
            echo "================================================"
            ./method2_system_preferences_reset.sh
            ;;
        3)
            echo ""
            echo "🚀 Running Method 3: Launchd Services Reset..."
            echo "============================================="
            ./method3_launchd_services_reset.sh
            ;;
        4)
            echo ""
            echo "🌐 Running Method 4: Network & Siri Reset..."
            echo "==========================================="
            ./method4_network_siri_reset.sh
            ;;
        5)
            echo ""
            echo "🔧 Running Method 5: Hardware Audio Reset..."
            echo "==========================================="
            ./method5_hardware_audio_reset.sh
            ;;
        6)
            echo ""
            echo "🎯 Running All Methods (Comprehensive Fix)..."
            echo "============================================="
            ./run_all_dictation_methods.sh
            ;;
        7)
            echo ""
            echo "🔍 Running Microphone Status Check..."
            echo "===================================="
            ./check_microphone_status.sh
            ;;
        8)
            echo ""
            echo "👋 Goodbye!"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid choice. Please enter a number between 1-8."
            echo ""
            ;;
    esac
    
    echo ""
    echo "⏸️  Press Enter to continue..."
    read -r
    echo ""
done
