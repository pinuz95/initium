#!/bin/bash

# Development runner script for Initium CLI
# This script handles building and running the CLI with proper paths

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load environment variables
if [[ -f ".env" ]]; then
    export $(grep -v '^#' .env | xargs)
fi

# Function to find the binary efficiently
find_binary() {
    # First check if we have a cached path in environment variable that still exists
    if [[ -n "$DEV_BINARY_PATH" ]] && [[ -f "$DEV_BINARY_PATH" ]]; then
        echo "$DEV_BINARY_PATH"
        return 0
    fi
    
    # Look for Initium-specific DerivedData directory first
    local initium_derived_data=$(find /Users/$USER/Library/Developer/Xcode/DerivedData -maxdepth 1 -name "Initium-*" -type d 2>/dev/null | head -1)
    
    if [[ -n "$initium_derived_data" ]]; then
        local binary_path="$initium_derived_data/Build/Products/Debug/initium"
        if [[ -f "$binary_path" ]]; then
            # Update .env file with the found path
            update_env_binary_path "$binary_path"
            echo "$binary_path"
            return 0
        fi
    fi
    
    # Fallback to broader search (slower)
    local binary_path=$(find /Users/$USER/Library/Developer/Xcode/DerivedData -name "initium" -type f -path "*/Build/Products/Debug/initium" 2>/dev/null | head -1)
    if [[ -n "$binary_path" ]]; then
        # Update .env file with the found path
        update_env_binary_path "$binary_path"
        echo "$binary_path"
    fi
}

# Function to update DEV_BINARY_PATH in .env file
update_env_binary_path() {
    local new_path="$1"
    if [[ -f ".env" ]]; then
        # Update existing DEV_BINARY_PATH line or add it if missing
        if grep -q "^DEV_BINARY_PATH=" .env; then
            # Use a temporary file for safe in-place editing
            sed "s|^DEV_BINARY_PATH=.*|DEV_BINARY_PATH=$new_path|" .env > .env.tmp && mv .env.tmp .env
        else
            echo "DEV_BINARY_PATH=$new_path" >> .env
        fi
    else
        # Create .env file if it doesn't exist
        cat > .env << EOF
# Development binary path cache
# This variable stores the path to the built initium binary to avoid repeated searches
# Leave empty to search automatically
DEV_BINARY_PATH=$new_path
EOF
    fi
    # Update current environment
    export DEV_BINARY_PATH="$new_path"
}

# Function to build the CLI
build_cli() {
    echo -e "${BLUE}Building InitiumCLI...${NC}"
    tuist build InitiumCLI
    echo -e "${GREEN}Build completed!${NC}"
    # Clear cached path after build to force re-detection
    update_env_binary_path ""
    export DEV_BINARY_PATH=""
}

# Function to run the CLI
run_cli() {
    local binary_path=$(find_binary)
    
    if [[ -z "$binary_path" ]]; then
        echo -e "${RED}Binary not found. Building first...${NC}"
        build_cli
        binary_path=$(find_binary)
    fi
    
    if [[ -z "$binary_path" ]]; then
        echo -e "${RED}Failed to find binary even after building!${NC}"
        exit 1
    fi
    
    # Only show the running message in verbose mode
    if [[ "${VERBOSE:-}" == "1" ]]; then
        echo -e "${BLUE}Running: $binary_path $@${NC}"
    fi
    
    "$binary_path" "$@"
}

# Function to show usage
show_usage() {
    echo -e "${YELLOW}Initium Development Runner${NC}"
    echo ""
    echo "Usage: $0 [build|run|<command>]"
    echo ""
    echo "Development Commands:"
    echo "  build           - Build the CLI"
    echo "  run [args...]   - Run the CLI with arguments"
    echo "  <command>       - Run the CLI with the given command directly"
    echo ""
    echo "Available CLI Commands:"
    echo "  init            - Initialize Initium for first-time setup"
    echo "  status          - Show system status overview (default command)"
    echo "  info            - Display system and environment information"
    echo "  info --tools    - Show system tools and their versions"
    echo "  config          - Manage Initium configuration"
    echo "  config show     - Display current configuration"
    echo "  config set      - Set configuration values"
    echo "  config reset    - Reset configuration to defaults"
    echo "  version         - Display version information"
    echo ""
    echo "Options:"
    echo "  VERBOSE=1       - Show verbose output"
    echo ""
    echo "Examples:"
    echo "  $0 build                      # Build the CLI"
    echo "  $0 run --help                 # Show full CLI help"
    echo "  $0 init                       # Initialize Initium"
    echo "  $0 status                     # Check system status"
    echo "  $0 info --tools               # Show development tools"
    echo "  $0 config show                # Display configuration"
    echo "  VERBOSE=1 $0 info             # Verbose system info"
    echo ""
    echo "For detailed CLI help: $0 run --help"
}

# Main logic
case "${1:-}" in
    "build")
        build_cli
        ;;
    "run")
        shift
        run_cli "$@"
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    "")
        # No arguments - run default command
        run_cli
        ;;
    *)
        # Pass all arguments to CLI
        run_cli "$@"
        ;;
esac