#!/bin/bash
cd /home/container
# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Define log file path and send stder and sdout to logfile - Only used if DEBUG is enabled in the admin panel / egg
if [ "${DEBUG}" == "1" ]; then
    echo -e "${RED}Debug logging is enabled! Check ./Astrotux.log for errors on startup..${NC}"
    LOG_FILE="/home/container/AstroTux.log"
    log_message() {
        echo "$(date +'%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
        }
    exec > >(tee -a "$LOG_FILE")
    exec 2>&1
    log_message "Game Logging Started."
fi

echo -e "${RED} ---------------------------------------------------------- ${NC}"
echo -e "${GREEN}Running on Debian ${GREEN} $(cat /etc/debian_version)${NC}"
echo -e "${GREEN}Kernel Version: ${GREEN} $(uname -r)${NC}"
echo -e "${GREEN}Current Time Zone: ${GREEN} $(cat /etc/timezone)${NC}"
echo -e "${GREEN}Current Wine Version:${GREEN} $(wine --version)${NC}"
echo -e "${GREEN}Current Python Version:${GREEN} $(python3 --version)${NC}"
echo -e "${RED} ---------------------------------------------------------- ${NC}"

echo -e "${YELLOW}If you get a module missing error please ensure your egg is up to date.${NC}"

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Check if requirements.txt exists and create a VENV to read modules
if [[ -f "/home/container/requirements.txt" ]]; then
    # Create a virtual environment in /home/container
    python3 -m venv /home/container --system-site-packages
    # Activate the virtual environment
    source /home/container/bin/activate
    pip install -U -r /home/container/requirements.txt
else
    # Display error if requirements.txt does not exist
    echo -e "\t${RED}No requirements.txt found. Installation failed.${NC}"
fi

# Check if AUTO_UPDATE is not set or set to 1 to update TuxServer
if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    git config pull.rebase false
    git pull
else
    echo -e "${GREEN}Not updating game server as AUTO_UPDATE was Disabled. Starting Server!${NC}"
fi


mkdir -p $WINEPREFIX

#Installs Astroneer if not done already
if [ ! -f /home/container/AstroneerServer/AstroServer.exe ]; then
    echo -e "${GREEN}Installing the game using TuxLauncher. This may take a moment!${NC}"
    echo -e "${YELLOW}Installation process has begun, you may see some errors in console.${NC}"
    echo -e "${YELLOW}Enabling Debug Logging for Download Progress. This is disabled once finished..${NC}"
    #Enables DebugLogging to show Download Progress via -l
    python3 AstroTuxLauncher.py -l install
else
    echo "${GREEN}Astroneer already installed! Skipping install process"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Start the Server
echo -e "${GREEN}[STARTUP]:${NC} Starting server with the following startup command: ${MODIFIED_STARTUP}"
eval "${MODIFIED_STARTUP}"
