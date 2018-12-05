FROM ubuntu:bionic
MAINTAINER SteamCache.Net Team <team@steamcache.net>
ARG DEBIAN_FRONTEND=noninteractive
RUN \
  apt-get -y update && apt-get -y upgrade && \
  apt-get -y install supervisor curl wget bzip2 locales && \
  locale-gen en_GB.utf8 && \
  update-locale LANG=en_GB.utf8 && \
  mkdir --mode 777 -p /var/log/supervisor && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/*
ENV \
  SUPERVISORD_EXIT_ON_FATAL=1 \
  LC_ALL=en_GB.UTF-8 \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 
COPY overlay/ /
RUN chmod -R 755 /init /hooks
ENTRYPOINT ["/bin/bash", "-e", "/init/entrypoint"]
CMD ["/init/supervisord"]
