#!/bin/bash

# ChatGPT Reinstallation Script for macOS
# This script completely removes the existing ChatGPT installation and reinstalls it

echo "ChatGPT Reinstallation Script"
echo "============================="
echo ""

# Function to check if ChatGPT is running
check_chatgpt_running() {
    if pgrep -f "ChatGPT" > /dev/null; then
        echo "⚠️  ChatGPT is currently running. Please quit the application first."
        echo "   You can quit it from the menu bar or use: pkill -f ChatGPT"
        return 1
    fi
    return 0
}

# Function to remove ChatGPT completely
remove_chatgpt() {
    echo "🗑️  Removing existing ChatGPT installation..."
    
    # Remove the main application
    if [ -d "/Applications/ChatGPT.app" ]; then
        echo "   Removing /Applications/ChatGPT.app"
        sudo rm -rf "/Applications/ChatGPT.app"
    fi
    
    # Remove user data and preferences
    echo "   Removing user data and preferences..."
    
    # Application Support
    if [ -d "$HOME/Library/Application Support/ChatGPT" ]; then
        rm -rf "$HOME/Library/Application Support/ChatGPT"
        echo "   Removed Application Support data"
    fi
    
    # Preferences
    if [ -f "$HOME/Library/Preferences/com.openai.chatgpt.plist" ]; then
        rm -f "$HOME/Library/Preferences/com.openai.chatgpt.plist"
        echo "   Removed preferences file"
    fi
    
    # Caches
    if [ -d "$HOME/Library/Caches/com.openai.chatgpt" ]; then
        rm -rf "$HOME/Library/Caches/com.openai.chatgpt"
        echo "   Removed cache files"
    fi
    
    # Saved Application State
    if [ -d "$HOME/Library/Saved Application State/com.openai.chatgpt.savedState" ]; then
        rm -rf "$HOME/Library/Saved Application State/com.openai.chatgpt.savedState"
        echo "   Removed saved application state"
    fi
    
    # Containers (if sandboxed)
    if [ -d "$HOME/Library/Containers/com.openai.chatgpt" ]; then
        rm -rf "$HOME/Library/Containers/com.openai.chatgpt"
        echo "   Removed container data"
    fi
    
    # Group Containers
    if [ -d "$HOME/Library/Group Containers/com.openai.chatgpt" ]; then
        rm -rf "$HOME/Library/Group Containers/com.openai.chatgpt"
        echo "   Removed group container data"
    fi
    
    echo "✅ ChatGPT removal completed"
}

# Function to download and install ChatGPT
install_chatgpt() {
    echo ""
    echo "📥 Downloading and installing ChatGPT..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download ChatGPT from the official source
    echo "   Downloading ChatGPT from OpenAI..."
    
    # Try to download using curl
    if curl -L -o "ChatGPT.dmg" "https://download.openai.com/desktop/mac/ChatGPT.dmg"; then
        echo "   ✅ Download completed"
        
        # Mount the DMG
        echo "   Mounting DMG..."
        hdiutil attach "ChatGPT.dmg" -nobrowse -quiet
        
        # Find the mounted volume
        MOUNT_POINT=$(hdiutil info | grep -A 1 "ChatGPT" | tail -1 | awk '{print $3}')
        
        if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
            echo "   Installing ChatGPT to Applications..."
            
            # Copy to Applications
            if cp -R "$MOUNT_POINT/ChatGPT.app" "/Applications/"; then
                echo "   ✅ Installation completed"
                
                # Set proper permissions
                sudo chown -R root:admin "/Applications/ChatGPT.app"
                sudo chmod -R 755 "/Applications/ChatGPT.app"
                
                # Unmount the DMG
                hdiutil detach "$MOUNT_POINT" -quiet
                
                echo "✅ ChatGPT installation completed successfully!"
            else
                echo "❌ Failed to copy ChatGPT.app to Applications"
                hdiutil detach "$MOUNT_POINT" -quiet
                return 1
            fi
        else
            echo "❌ Failed to find mounted ChatGPT volume"
            return 1
        fi
    else
        echo "❌ Failed to download ChatGPT"
        echo "   Please download manually from: https://chat.openai.com/"
        return 1
    fi
    
    # Clean up
    cd /
    rm -rf "$TEMP_DIR"
}

# Function to verify installation
verify_installation() {
    echo ""
    echo "🔍 Verifying installation..."
    
    if [ -d "/Applications/ChatGPT.app" ]; then
        echo "✅ ChatGPT.app found in Applications"
        
        # Check if it's executable
        if [ -x "/Applications/ChatGPT.app/Contents/MacOS/ChatGPT" ]; then
            echo "✅ ChatGPT executable found and has proper permissions"
            
            # Get version info if possible
            VERSION=$(defaults read "/Applications/ChatGPT.app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
            if [ -n "$VERSION" ]; then
                echo "✅ ChatGPT version: $VERSION"
            fi
            
            echo ""
            echo "🎉 ChatGPT has been successfully reinstalled!"
            echo "   You can now launch it from Applications or Spotlight search."
            echo ""
            echo "💡 If you still experience issues:"
            echo "   1. Try restarting your Mac"
            echo "   2. Check your network connection"
            echo "   3. Ensure you're not behind a restrictive firewall/proxy"
            
        else
            echo "❌ ChatGPT executable not found or not executable"
            return 1
        fi
    else
        echo "❌ ChatGPT.app not found in Applications"
        return 1
    fi
}

# Main execution
main() {
    echo "This script will completely remove and reinstall ChatGPT on your Mac."
    echo "The 'netscope' issue you mentioned is likely related to network/certificate problems."
    echo ""
    read -p "Do you want to continue? (y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # Check if ChatGPT is running
    if ! check_chatgpt_running; then
        echo ""
        read -p "Please quit ChatGPT and press Enter to continue, or type 'q' to quit: " -r
        if [[ $REPLY =~ ^[Qq]$ ]]; then
            echo "Installation cancelled."
            exit 0
        fi
    fi
    
    # Remove existing installation
    remove_chatgpt
    
    # Install fresh copy
    if install_chatgpt; then
        # Verify installation
        verify_installation
    else
        echo "❌ Installation failed. Please try downloading manually from:"
        echo "   https://chat.openai.com/"
        exit 1
    fi
}

# Run main function
main
