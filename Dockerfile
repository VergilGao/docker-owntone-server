############## build stage ##############
FROM alpine:3.15 as buildstage

ARG OWNTONE_SOURCE_VERSION
ENV OWNTONE_SOURCE_VERSION=${OWNTONE_SOURCE_VERSION:-3c48a07acbf7f3887d759a4f2d3be39ec0ed5ea5}

RUN apk add --update --no-cache \
    alsa-lib-dev \
    autoconf \
    automake \
    avahi-dev \
    bash \
    confuse-dev \
    curl \
    curl-dev \
    ffmpeg-dev \
    flex \
    flac-dev \
    g++ \
    gcc \
    gettext-dev \
    gnutls-dev \
    gperf \
    json-c-dev \
    libcurl \
    libevent-dev \
    libgcrypt-dev \
    libplist-dev \
    libsodium-dev \
    libtool \
    libunistring-dev \
    libwebsockets-dev \
    make \
    mxml-dev \
    protobuf-c-dev \
    sqlite-dev \
    tar

### owntone-server source code
RUN mkdir -p /src/owntone-server && \
    wget -O- https://github.com/owntone/owntone-server/archive/${OWNTONE_SOURCE_VERSION}.tar.gz | tar xz -C /src/owntone-server --strip-components 1

RUN apk add --update --no-cache bison bsd-compat-headers file

RUN cd /src/owntone-server && \
    autoreconf -i && \
    ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --localstatedir=/var \
      --enable-itunes \
      --disable-mpd \
      --disable-spotify && \
    make && make DESTDIR=/src/owntone-server/build install && \
    rm -rf /src/owntone-server/build/etc/* /src/owntone-server/build/var && \ 
    mv /src/owntone-server/owntone.conf /src/owntone-server/build/etc/owntone.conf.orig

############## runtime stage ##############
FROM ghcr.io/vergilgao/alpine-baseimage

LABEL maintainer="VergilGao"
LABEL org.opencontainers.image.source="https://github.com/VergilGao/docker-owntone-server"
# set version label
ARG BUILD_DATE
ARG VERSION

ENV UMASK=002
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV TZ="Asia/Shanghai"

RUN apk add --update --no-cache \
        avahi \
        confuse \
        dbus \
        ffmpeg \
        json-c \
        libcurl \
        libgcrypt \
        libplist \
        libsodium \
        libwebsockets \
        mxml \
        protobuf-c \
        sqlite \
        sqlite-libs

RUN mkdir -p /music /config && \
    useradd -s /sbin/nologin owntone && \
    chown -R owntone /music /config

COPY --from=buildstage /src/owntone-server/build/ /

ADD /scripts/*.sh /opt/scripts/
RUN chmod -R 770 /opt/scripts/

VOLUME [ "/music", "/config" ]

ENTRYPOINT ["/opt/scripts/docker-entrypoint.sh"]