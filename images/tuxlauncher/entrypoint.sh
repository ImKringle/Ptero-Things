#!/bin/bash
cd /home/container
# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Information output
echo -e "${RED} ---------------------------------------------------------- ${NC}"
echo -e "${GREEN}Running on Debian ${GREEN} $(cat /etc/debian_version)${NC}"
echo -e "${GREEN}Kernel Version: ${GREEN} $(uname -r)${NC}"
echo -e "${GREEN}Current timezone: ${GREEN} $(cat /etc/timezone)${NC}"
echo -e "${GREEN}Current Wine Version:${GREEN} $(wine --version)${NC}"
echo -e "${RED} ---------------------------------------------------------- ${NC}"

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Check if AUTO_UPDATE is not set or set to 1 to update TuxServer
if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    # Update the Server
    git config pull.rebase false
    git pull

    # Check if requirements.txt exists
    if [[ -f "/home/container/requirements.txt" ]]; then
        # Install/upate requirements
        pip install -U --prefix .local -r /home/container/requirements.txt
    else
        # Display error if requirements.txt does not exist
        echo -e "${RED}No requirements.txt found. Installation failed.${NC}"
    fi
else
    echo -e "${GREEN}Not updating game server as AUTO_UPDATE was Disabled. Starting Server!${NC}"
fi


mkdir -p $WINEPREFIX

echo -e "${YELLOW}Installation process has begun, you may see some errors in console."

#Installs Astroneer if not done already
if [ ! -f /home/container/AstroneerServer/AstroServer.exe ]; then
    echo -e "${GREEN}Installing the game using TuxLauncher. This may take a moment!${NC}"
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
echo -e "${GREEN}[STARTUP]:${NC} Starting server with the following startup command:"
eval ${MODIFIED_STARTUP}

#If an error occurs, throw exception
if [ $? -ne 0 ]; then
    echo -e "\n${RED}PTDL_CONTAINER_ERR: There was an error while attempting to run the start command.${NC}\n"
    exit 1
fi
