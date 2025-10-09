#!/bin/bash

# Cursor Management Script for macOS
# This script can either completely remove Cursor or update it to the latest version

echo "Cursor Management Script"
echo "======================="
echo ""

# Check current Cursor installation
check_cursor_status() {
    echo "🔍 Checking current Cursor installation..."
    
    if [ -d "/Applications/Cursor.app" ]; then
        echo "✅ Cursor.app found in Applications"
        
        # Get version info
        if command -v cursor &> /dev/null; then
            VERSION=$(cursor --version 2>/dev/null | head -1)
            echo "✅ Cursor CLI available - Version: $VERSION"
        else
            echo "⚠️  Cursor CLI not found in PATH"
        fi
        
        # Check if it's running
        if pgrep -f "Cursor" > /dev/null; then
            echo "⚠️  Cursor is currently running"
        else
            echo "✅ Cursor is not running"
        fi
        
        return 0
    else
        echo "❌ Cursor.app not found in Applications"
        return 1
    fi
}

# Function to completely remove Cursor
remove_cursor() {
    echo ""
    echo "🗑️  Completely removing Cursor..."
    
    # Check if Cursor is running
    if pgrep -f "Cursor" > /dev/null; then
        echo "⚠️  Cursor is running. Stopping it first..."
        pkill -f "Cursor"
        sleep 2
    fi
    
    # Remove the main application
    if [ -d "/Applications/Cursor.app" ]; then
        echo "   Removing /Applications/Cursor.app"
        sudo rm -rf "/Applications/Cursor.app"
    fi
    
    # Remove user data and preferences
    echo "   Removing user data and preferences..."
    
    # Application Support
    if [ -d "$HOME/Library/Application Support/Cursor" ]; then
        rm -rf "$HOME/Library/Application Support/Cursor"
        echo "   Removed Application Support data"
    fi
    
    # Preferences
    if [ -f "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist" ]; then
        rm -f "$HOME/Library/Preferences/com.todesktop.230313mzl4w4u92.plist"
        echo "   Removed preferences file"
    fi
    
    # Caches
    if [ -d "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92" ]; then
        rm -rf "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92"
        echo "   Removed cache files"
    fi
    
    # Saved Application State
    if [ -d "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState" ]; then
        rm -rf "$HOME/Library/Saved Application State/com.todesktop.230313mzl4w4u92.savedState"
        echo "   Removed saved application state"
    fi
    
    # Containers (if sandboxed)
    if [ -d "$HOME/Library/Containers/com.todesktop.230313mzl4w4u92" ]; then
        rm -rf "$HOME/Library/Containers/com.todesktop.230313mzl4w4u92"
        echo "   Removed container data"
    fi
    
    # Group Containers
    if [ -d "$HOME/Library/Group Containers/com.todesktop.230313mzl4w4u92" ]; then
        rm -rf "$HOME/Library/Group Containers/com.todesktop.230313mzl4w4u92"
        echo "   Removed group container data"
    fi
    
    # Remove CLI symlink if it exists
    if [ -L "/usr/local/bin/cursor" ]; then
        sudo rm -f "/usr/local/bin/cursor"
        echo "   Removed CLI symlink"
    fi
    
    echo "✅ Cursor removal completed"
}

# Function to download and install latest Cursor
install_cursor() {
    echo ""
    echo "📥 Downloading and installing latest Cursor..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download Cursor from the official source
    echo "   Downloading Cursor from official source..."
    
    # Try to download using curl
    if curl -L -o "Cursor.dmg" "https://downloader.cursor.sh/mac/arm64"; then
        echo "   ✅ Download completed"
        
        # Mount the DMG
        echo "   Mounting DMG..."
        hdiutil attach "Cursor.dmg" -nobrowse -quiet
        
        # Find the mounted volume
        MOUNT_POINT=$(hdiutil info | grep -A 1 "Cursor" | tail -1 | awk '{print $3}')
        
        if [ -n "$MOUNT_POINT" ] && [ -d "$MOUNT_POINT" ]; then
            echo "   Installing Cursor to Applications..."
            
            # Remove existing installation first
            if [ -d "/Applications/Cursor.app" ]; then
                sudo rm -rf "/Applications/Cursor.app"
            fi
            
            # Copy to Applications
            if cp -R "$MOUNT_POINT/Cursor.app" "/Applications/"; then
                echo "   ✅ Installation completed"
                
                # Set proper permissions
                sudo chown -R root:admin "/Applications/Cursor.app"
                sudo chmod -R 755 "/Applications/Cursor.app"
                
                # Create CLI symlink
                if [ ! -L "/usr/local/bin/cursor" ]; then
                    sudo ln -sf "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" "/usr/local/bin/cursor"
                    echo "   ✅ CLI symlink created"
                fi
                
                # Unmount the DMG
                hdiutil detach "$MOUNT_POINT" -quiet
                
                echo "✅ Cursor installation completed successfully!"
            else
                echo "❌ Failed to copy Cursor.app to Applications"
                hdiutil detach "$MOUNT_POINT" -quiet
                return 1
            fi
        else
            echo "❌ Failed to find mounted Cursor volume"
            return 1
        fi
    else
        echo "❌ Failed to download Cursor"
        echo "   Please download manually from: https://cursor.sh/"
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
    
    if [ -d "/Applications/Cursor.app" ]; then
        echo "✅ Cursor.app found in Applications"
        
        # Check if it's executable
        if [ -x "/Applications/Cursor.app/Contents/MacOS/Cursor" ]; then
            echo "✅ Cursor executable found and has proper permissions"
            
            # Get version info if possible
            if command -v cursor &> /dev/null; then
                VERSION=$(cursor --version 2>/dev/null | head -1)
                echo "✅ Cursor version: $VERSION"
            fi
            
            echo ""
            echo "🎉 Cursor has been successfully installed!"
            echo "   You can now launch it from Applications or use 'cursor' command."
            
        else
            echo "❌ Cursor executable not found or not executable"
            return 1
        fi
    else
        echo "❌ Cursor.app not found in Applications"
        return 1
    fi
}

# Main execution
main() {
    # Check current status
    check_cursor_status
    
    echo ""
    echo "What would you like to do?"
    echo "1. Completely remove Cursor"
    echo "2. Update/Reinstall Cursor to latest version"
    echo "3. Just check status (do nothing)"
    echo ""
    read -p "Enter your choice (1-3): " -n 1 -r
    echo ""
    
    case $REPLY in
        1)
            echo ""
            read -p "Are you sure you want to completely remove Cursor? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                remove_cursor
                echo ""
                echo "✅ Cursor has been completely removed from your system."
            else
                echo "Removal cancelled."
            fi
            ;;
        2)
            echo ""
            read -p "This will update/reinstall Cursor. Continue? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if install_cursor; then
                    verify_installation
                else
                    echo "❌ Installation failed. Please try downloading manually from:"
                    echo "   https://cursor.sh/"
                fi
            else
                echo "Installation cancelled."
            fi
            ;;
        3)
            echo "Status check completed."
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run main function
main
