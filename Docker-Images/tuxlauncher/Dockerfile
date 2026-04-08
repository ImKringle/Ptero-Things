# ------------------------------------------------ #
# Docker Image for AstroTuxLauncher on Pterodactyl #
# ------------------------------------------------ #
FROM    ubuntu:24.04
LABEL   author="Kringle" maintainer="imkringle@proton.me"
ENV     DEBIAN_FRONTEND=noninteractive

# Install required packages / Wine
RUN     dpkg --add-architecture i386 \
                && apt update -y \
                && apt install -y --no-install-recommends \
                        curl ca-certificates gnupg software-properties-common \
                        libc6:i386 libstdc++6:i386 libgcc-s1:i386 \
                        libncurses6:i386 libtinfo6:i386 libglib2.0-0:i386 \
                        libsdl2-2.0-0:i386 winbind xauth numactl jq tzdata tini libgnutls30 gnutls-bin \
                && mkdir -pm755 /etc/apt/keyrings \
                && curl -sSL https://dl.winehq.org/wine-builds/winehq.key \
                        | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key \
                && curl -sSL -o /etc/apt/sources.list.d/winehq-noble.sources \
                        https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
                && apt update -y \
                && apt install -y --install-recommends winehq-stable cabextract wine-binfmt \
                && apt clean \
                && useradd -m -s /bin/bash container

# Set environment variables
ENV     USER=container \
                HOME=/home/container \
                WINEPREFIX=/home/container/.wine \
                WINEDLLOVERRIDES="mscoree,mshtml=" \
                AUTO_UPDATE=1

# Set working directory
WORKDIR /home/container
STOPSIGNAL SIGINT
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER container

# Set entrypoint
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
