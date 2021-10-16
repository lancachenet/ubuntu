FROM ubuntu:24.04
LABEL maintainer="LanCache.Net Team <team@lancache.net>"

ARG DEBIAN_FRONTEND=noninteractive
ARG ARCH="amd64"
ARG OVERLAY_VERSION="v2.2.0.3"

ENV \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  LC_ALL=en_GB.UTF-8 \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  TZ=Europe/London

COPY overlay/ /

RUN \
  apt-get -y update && apt-get -y upgrade && \
  apt-get -y install curl wget bzip2 locales tzdata --no-install-recommends && \
  locale-gen en_GB.utf8 && \
  update-locale LANG=en_GB.utf8 \
  cd /tmp && \
  curl -sSfL -o s6-overlay.tar.gz "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${ARCH}.tar.gz" && \
  tar xfz s6-overlay.tar.gz -C / && \
  apt-get -y clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

ENTRYPOINT ["/init"]
