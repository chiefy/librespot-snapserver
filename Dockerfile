FROM rust:latest AS librespot

RUN apt-get update \
    && apt-get -y install build-essential portaudio19-dev curl unzip \
    && apt-get clean && rm -fR /var/lib/apt/lists

ARG ARCH=amd64
ARG LIBRESPOT_VERSION=0.3.1

COPY ./install-librespot.sh /tmp/
RUN /tmp/install-librespot.sh

FROM debian:bullseye

ARG SNAPCAST_VERSION=0.26.0
ARG ARCH=amd64

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl libasound2 mpv \
    && curl -L -o /tmp/snapserver.deb "https://github.com/badaix/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_${ARCH}.deb" \
    && dpkg -i /tmp/snapserver.deb || apt-get install -f -y --no-install-recommends \
    && mv /etc/snapserver.conf /etc/snapserver.conf.orig \
    && apt-get clean && rm -fR /var/lib/apt/lists

COPY --from=librespot /usr/local/cargo/bin/librespot /usr/local/bin/

VOLUME [ "/etc/snapserver.conf" ]

CMD [ "snapserver" ]

ENV DEVICE_NAME=Snapcast

EXPOSE 1704/tcp 1705/tcp
