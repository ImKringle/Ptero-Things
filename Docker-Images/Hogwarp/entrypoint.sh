#!/bin/bash

sleep 1

cd $HOME

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED} ---------------------------------------------------------- ${NC}"
echo -e "${GREEN}Running on Debian ${GREEN} $(cat /etc/debian_version)${NC}"
echo -e "${GREEN}Kernel Version: ${GREEN} $(uname -r)${NC}"
echo -e "${GREEN}Current Time Zone: ${GREEN} $(cat /etc/timezone)${NC}"
echo -e "${RED} ---------------------------------------------------------- ${NC}"

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Copy Server data from the /app dir
cp -rf "/app/"* "$HOME"
chmod +x $HOME/Server.Loader

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Start the Server
echo -e "${GREEN}[STARTUP]:${NC} Starting server with the following startup command: ${MODIFIED_STARTUP}"
eval "${MODIFIED_STARTUP}"