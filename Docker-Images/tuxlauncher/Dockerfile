# ------------------------------------------------ #
# Docker Image for AstroTuxLauncher on Pterodactyl #
# ------------------------------------------------ #
FROM  ghcr.io/parkervcp/yolks:debian
LABEL author="Kringle" maintainer="imkringle@proton.me"
#Cred to https://github.com/Dalethium for helping cleanup
ENV   DEBIAN_FRONTEND noninteractive

# Install required packages / Wine
RUN dpkg --add-architecture i386 \
    && cd /tmp/ \
    && mkdir -pm755 /etc/apt/keyrings \
    && curl -sSL -o /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -sSL -o /etc/apt/sources.list.d/winehq-jammy.sources https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt update -y \
    && apt install -y --no-install-recommends numactl libntlm0 winbind xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0:i386 python3-pip jq \
    && apt install --install-recommends --fix-missing winehq-stable cabextract wine-binfmt -y
# Install RCON
RUN cd /tmp/ \
    && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
    && tar xvf rcon.tar.gz \
    && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

# Set environment variables
ENV USER=container \
    HOME=/home/container \
    WINEPREFIX=/home/container/.wine \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    AUTO_UPDATE=1

# Set working directory
WORKDIR /home/container

STOPSIGNAL SIGINT
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Set entrypoint
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
