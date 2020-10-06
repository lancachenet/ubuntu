FROM ubuntu:bionic
LABEL maintainer="LanCache.Net Team <team@lancache.net>"

ARG DEBIAN_FRONTEND=noninteractive

ADD ["https://github.com/just-containers/s6-overlay/releases/download/v1.17.2.0/s6-overlay-amd64.tar.gz", "/tmp"]

ENTRYPOINT ["/init"]

RUN \
# Extract S6 overlay
  tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
# Update and get dependencies
  apt-get update && \
  apt-get install -y \
  curl \
  wget \
  bzip2 \
  locales \
  tzdata \
  && \
# Add user
  useradd -u 911 -U -d /data -s /bin/false abc && \
  usermod -G users abc && \
# Timezone
  locale-gen en_GB.utf8 && \
  update-locale LANG=en_GB.utf8 && \
# Create directories
  mkdir /data && \
# Cleanup
  apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf var/tmp/*

ENV  \
  LC_ALL=en_GB.UTF-8 \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  TZ=Europe/London

COPY overlay/ /
