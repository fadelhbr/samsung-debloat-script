#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
    echo "This script requires administrative privileges."
    exec sudo "$0" "$@"
    exit $?
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[0;37m'
NC='\033[0m'

clear
echo
echo -e "${WHITE} ░█▀▄░█▀▀░█░█░█▀▀░█▀▄░▀█▀ ${NC}"
echo -e "${WHITE} ░█▀▄░█▀▀░▀▄▀░█▀▀░█▀▄░░█░ ${NC}"
echo -e "${WHITE} ░▀░▀░▀▀▀░░▀░░▀▀▀░▀░▀░░▀░ ${NC}"
echo -e "${WHITE} ░█▀▀░█▀▀░█▀▄░▀█▀░█▀█░▀█▀ ${NC}"
echo -e "${WHITE} ░▀▀█░█░░░█▀▄░░█░░█▀▀░░█░ ${NC}"
echo -e "${WHITE} ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░░░░▀░ ${NC}"
echo
echo -e "${WHITE} by github@fadelhbr${NC}"
echo

if ! command -v adb &> /dev/null; then
    echo -e "${RED}ERROR: ADB not found in PATH${NC}"
    echo "Please install Android SDK Platform Tools"
    exit 1
fi

if [ ! -f "list_app.txt" ]; then
    echo -e "${RED}ERROR: list_app.txt file not found${NC}"
    echo "This file should contain package names to reinstall, one per line"
    exit 1
fi

app_count=$(grep -v "^$" list_app.txt | grep -v "^#" | wc -l)
echo -e "Found ${WHITE}$app_count${NC} applications to restore in list_app.txt"

echo -e "${WHITE}Checking for connected devices...${NC}"
devices=($(adb devices | grep -v "List" | grep "device$" | cut -f1))

if [ ${#devices[@]} -eq 0 ]; then
    echo -e "${RED}No devices found. Please connect your device and enable USB debugging.${NC}"
    echo "Make sure to confirm any authorization prompts on your device."
    exit 1
fi

selected_device=""
if [ ${#devices[@]} -gt 1 ]; then
    echo -e "${WHITE}Multiple devices found. Please select one:${NC}"
    for i in "${!devices[@]}"; do
        echo "$((i+1)). ${devices[$i]}"
    done
    echo
    read -p "Enter device number (1-${#devices[@]}): " device_choice
    
    if [[ "$device_choice" =~ ^[0-9]+$ ]] && [ "$device_choice" -le "${#devices[@]}" ] && [ "$device_choice" -ge 1 ]; then
        selected_device=${devices[$((device_choice-1))]}
    else
        echo -e "${RED}Invalid selection${NC}"
        exit 1
    fi
else
    selected_device=${devices[0]}
fi

echo -e "${WHITE}Selected device: $selected_device${NC}"
echo
echo -e "${WHITE}=============================================================================${NC}"
echo -e "${WHITE}This script will try to restore $app_count previously debloated applications.${NC}"
echo -e "${WHITE}Note: Some system apps may not be restored successfully.${NC}"
echo -e "${WHITE}=============================================================================${NC}"
echo

read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${WHITE}Operation cancelled by user.${NC}"
    exit 0
fi

echo
echo -e "${WHITE}Starting restore process...${NC}"
echo

reinstall_app() {
    echo -e "Restoring ${YELLOW}$1${NC}..."
    if adb -s "$2" shell cmd package install-existing "$1" | grep -Ev "(Failure|doesn't exist)"; then
        echo -e "${GREEN}[SUCCESS]${NC} Package restored."
        return 0
    else
        echo -e "${RED}[FAILED]${NC} Could not restore package. It might be a non-system app."
        return 1
    fi
}

success_count=0
fail_count=0

while IFS= read -r package || [ -n "$package" ]; do
    if [[ ! -z "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
        reinstall_app "$package" "$selected_device"
        if [ $? -eq 0 ]; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo
    fi
done < "list_app.txt"

echo -e "${WHITE}Restore process completed!${NC}"
echo -e "${GREEN}Successfully restored: $success_count packages${NC}"
echo -e "${RED}Failed to restore: $fail_count packages${NC}"
echo
echo -e "${YELLOW}Note: You may need to reboot your device for all changes to take effect.${NC}"
echo