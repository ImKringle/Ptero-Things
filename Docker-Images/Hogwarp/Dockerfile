FROM        docker.io/tiltedphoques/hogwarp as hogwarp
FROM        ghcr.io/ptero-eggs/steamcmd:debian

LABEL       author="Kringle" maintainer="imkringle@proton.me"
ENV         DEBIAN_FRONTEND noninteractive
ENV         USER=container \
                    HOME=/home/container

USER        root

# Install .NET 8
RUN         apt-get update \
                && apt-get install -y wget apt-transport-https software-properties-common \
                && wget https://packages.microsoft.com/config/debian/11/prod.list \
                && mv prod.list /etc/apt/sources.list.d/microsoft-prod.list \
                && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
                && apt-get update \
                && apt-get install -y dotnet-sdk-8.0

COPY        --from=hogwarp /app /app
USER        container
WORKDIR     /home/container
STOPSIGNAL  SIGINT
COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD        ["/entrypoint.sh"]
