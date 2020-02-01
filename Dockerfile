FROM ubuntu:bionic
MAINTAINER LanCache.Net Team <team@lancache.net>
ARG DEBIAN_FRONTEND=noninteractive
RUN \
  apt-get -y update && apt-get -y upgrade && \
  apt-get -y install python-pip curl wget bzip2 locales tzdata && \
  locale-gen en_GB.utf8 && \
  update-locale LANG=en_GB.utf8
RUN \
  pip install supervisor && \
  mkdir --mode 777 -p /var/log/supervisor
RUN \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/*
ENV \
  SUPERVISORD_EXIT_ON_FATAL=1 \
  LC_ALL=en_GB.UTF-8 \
  LANG=en_GB.UTF-8 \
  LANGUAGE=en_GB.UTF-8 \
  TZ=Europe/London \
  SUPERVISORD_LOGLEVEL=WARN
COPY overlay/ /
RUN chmod -R 755 /init /hooks
ENTRYPOINT ["/bin/bash", "-e", "/init/entrypoint"]
CMD ["/init/supervisord"]
