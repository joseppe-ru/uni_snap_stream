FROM debian:stable-slim

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata gpg wget \
  && mkdir -p /etc/apt/keyrings \
  && wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy.gpg \
  && wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/bullseye.list \
  && apt-get update \
  # Install mopidy core
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-pip \
    mopidy \
    mopidy-spotify \
    mopidy-soundcloud \
    mopidy-mpd \
    mopidy-local \
    # Healtcheck tools
    curl \
  # Install mopidy "pip-extensions"
  && python3 -m pip install \
    # Mopidy web client extensions
    Mopidy-Iris \
    Mopidy-Moped \
    # Mopidy music source extensions
    Mopidy-GMusic \
    Mopidy-Pandora \
    Mopidy-RadioNet \
    Mopidy-TuneIn \
    Mopidy-YouTube \
    youtube-dl \
    pyopenssl \
    # Avoid "externally-managed-environment" error and allow parallel installation using apt+pip
    --break-system-packages 
RUN echo "HALLO============="
RUN python3 -m pip cache purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache \
  # Prepare runtime paths
  && mkdir -p /config \
  && chown -R mopidy:audio /config


# Switch to user mopidy with group audio.
USER mopidy:audio

# Create configuration
VOLUME ["/config"]
RUN cp /etc/mopidy/mopidy.conf /config/mopidy.conf

# Expose Ports
EXPOSE 6600 6680 5555/udp

# Run start script
ENTRYPOINT ["/usr/bin/mopidy"]
CMD ["--config", "/config/mopidy.conf"]

HEALTHCHECK --interval=5s --timeout=2s --retries=20 \
    CMD curl --connect-timeout 5 --silent --show-error --fail http://localhost:6680/ || exit 1
