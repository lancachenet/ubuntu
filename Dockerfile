FROM ubuntu:24.04
LABEL maintainer="LanCache.Net Team <team@lancache.net>"

ARG DEBIAN_FRONTEND=noninteractive
ARG ARCH="amd64"
ARG ARCH_ALT="x86_64"
ARG OVERLAY_VERSION="3.2.0.0"

ENV \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_VERBOSITY=1 \
  LC_ALL=en_GB.UTF-8 \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  TZ=Europe/London

COPY overlay/ /

RUN \
  apt-get -y update && apt-get -y upgrade && \
  apt-get -y install ca-certificates curl locales tzdata wget xz-utils --no-install-recommends && \
  locale-gen en_GB.utf8 && \
  update-locale LANG=en_GB.utf8 \
  cd /tmp && \
  curl -sSfL -o s6-overlay-noarch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
  curl -sSfL -o s6-overlay.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-${ARCH_ALT}.tar.xz" && \
  tar -C / -Jpxf s6-overlay-noarch.tar.xz && \
  tar -C / -Jpxf s6-overlay.tar.xz && \
  apt-get -y clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

ENTRYPOINT ["/init"]
