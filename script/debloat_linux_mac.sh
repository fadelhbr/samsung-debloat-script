#!/bin/bash

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
echo -e "${WHITE} ░█▀▄░█▀▀░█▀▄░█░░░█▀█░█▀█░▀█▀░█▀▀░█▀▄ ${NC}"
echo -e "${WHITE} ░█░█░█▀▀░█▀▄░█░░░█░█░█▀█░░█░░█▀▀░█▀▄ ${NC}"
echo -e "${WHITE} ░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░▀ ${NC}"
echo -e "${WHITE} ░█▀▀░█▀▀░█▀▄░▀█▀░█▀█░▀█▀             ${NC}"
echo -e "${WHITE} ░▀▀█░█░░░█▀▄░░█░░█▀▀░░█░             ${NC}"
echo -e "${WHITE} ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░░░░▀░             ${NC}"
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
    echo "This file should contain package names to debloat, one per line"
    exit 1
fi

app_count=$(grep -v "^$" list_app.txt | grep -v "^#" | wc -l)
echo -e "Found ${GREEN}$app_count${NC} applications to debloat in list_app.txt"

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
echo -e "${WHITE}==========================================================================${NC}"
echo -e "${WHITE}WARNING: This script will remove $app_count applications from your device.${NC}"
echo -e "${WHITE}This action cannot be easily undone and may affect device functionality.${NC}"
echo -e "${WHITE}The device will reboot automatically after completion.${NC}"
echo -e "${WHITE}==========================================================================${NC}"
echo

read -p "Do you want to continue? (y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${WHITE}Operation cancelled by user.${NC}"
    exit 0
fi

echo
echo -e "${WHITE}Starting debloat process...${NC}"
echo

uninstall_app() {
    echo -e "Removing ${WHITE}$1${NC}..."
    if adb -s "$2" shell pm uninstall -k --user 0 "$1" 2>/dev/null | grep -q "Success"; then
        echo -e "${GREEN}[SUCCESS]${NC} Package removed."
        return 0
    else
        echo -e "${RED}[FAILED]${NC} Could not remove package. It might be already removed or protected."
        return 1
    fi
}

success_count=0
fail_count=0

mapfile -t packages < list_app.txt

for package in "${packages[@]}"; do
    if [[ ! -z "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
        uninstall_app "$package" "$selected_device"
        if [ $? -eq 0 ]; then
            ((success_count++))
        else
            ((fail_count++))
        fi
        echo
    fi
done

echo -e "${WHITE}Debloat process completed!${NC}"
echo -e "${GREEN}Successfully removed: $success_count packages${NC}"
echo -e "${RED}Failed to remove: $fail_count packages${NC}"
echo

echo -e "${WHITE}Rebooting device...${NC}"
read -p "Do you want to reboot your device? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    adb -s "$selected_device" reboot
    echo -e "${GREEN}Reboot command sent to device.${NC}"
else
    echo -e "${YELLOW}Reboot skipped.${NC}"
fi
echo