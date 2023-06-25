FROM alpine:latest AS td_build

ARG OPENTTD_VERSION="jgrpp-0.54.2"
ARG OPENGFX_VERSION="7.1"

RUN mkdir -p /config 

# Install build dependencies
RUN apk --no-cache add \
    unzip \
    wget \
    git \
    libc-dev \
    make \
    cmake \
    patch \
    xz-dev \
    pkgconfig \
    zlib \
    libpng \
    lzo \
    musl-dev gcc nlohmann-json libcurl sdl2 libpng libgcc libtool linux-headers g++ curl

# Build OpenTTD itself
RUN mkdir -p /tmp/build
COPY --from=openttd . /tmp/src
WORKDIR /tmp/build

# RUN git clone https://github.com/JGRennison/OpenTTD-patches.git . \
#     && git fetch --tags \
#     && git checkout ${OPENTTD_VERSION}

ARG TARGETPLATFORM
ARG TARGETARCH
RUN cd /tmp/build && \
    cmake \
    -DOPTION_DEDICATED=ON \
    -DOPTION_INSTALL_FHS=OFF \
    -DCMAKE_BUILD_TYPE=release \
    -DGLOBAL_DIR=/app \
    -DPERSONAL_DIR=/ \
    -DCMAKE_BINARY_DIR=bin \
    -DCMAKE_INSTALL_PREFIX=/app \
    ../src 

ARG NPROC=$(nproc)
RUN echo Num Processors: ${NPROC}
RUN make CMAKE_BUILD_TYPE=release -j${NPROC} && \
    make install

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