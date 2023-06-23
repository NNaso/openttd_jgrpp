FROM alpine:latest AS td_build

ARG OPENTTD_VERSION="jgrpp-0.54.2"
ARG OPENGFX_VERSION="7.1"

RUN mkdir -p /config \
    && mkdir /tmp/src

# Install build dependencies
RUN apk --no-cache add \
    unzip \
    wget \
    git \
    g++ \
    make \
    cmake \
    patch \
    xz-dev \
    pkgconfig \
    bash

# Build OpenTTD itself
WORKDIR /tmp/src

RUN git clone https://github.com/JGRennison/OpenTTD-patches.git . \
    && git fetch --tags \
    && git checkout ${OPENTTD_VERSION}

# Perform the build with the build script (1.11 switches to cmake, so use a script for decision making)
ADD builder.sh /usr/local/bin/builder
RUN chmod +x /usr/local/bin/builder && builder && rm /usr/local/bin/builder

# Add the latest graphics files
## Install OpenGFX
RUN mkdir -p /app/data/baseset/ \
    && cd /app/data/baseset/ \
    && wget -q https://cdn.openttd.org/opengfx-releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}-all.zip \
    && unzip opengfx-${OPENGFX_VERSION}-all.zip \
    && tar -xf opengfx-${OPENGFX_VERSION}.tar \
    && rm -rf opengfx-*.tar opengfx-*.zip


FROM alpine:latest
ARG OPENTTD_VERSION="jgrpp-0.54.2"
RUN mkdir -p /usr/games/openttd/ \
    && apk --no-cache add tini xz libstdc++ libgcc zlib

COPY --from=td_build /app /usr/games/openttd
COPY --chown=1000:1000 --chmod=+x openttd.sh /openttd.sh
RUN chmod +x /openttd.sh

ENV PUID=1000
ENV PGID=1000

EXPOSE 3979/tcp 3979/udp

ENTRYPOINT ["tini", "-vv", "--", "/openttd.sh"]