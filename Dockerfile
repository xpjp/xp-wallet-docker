FROM ubuntu:xenial

# Change APT source and set locale
RUN \
  sed -i".bak" \
    "s@http://archive\.ubuntu\.com@http://ftp\.riken\.go\.jp/Linux/ubuntu@" \
    /etc/apt/sources.list

# Basic settings (Locales, timezone, etc)
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-utils && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    language-pack-ja language-pack-en tzdata software-properties-common && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  update-locale LANG=ja_JP.UTF-8 && \
  ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
  dpkg-reconfigure --frontend noninteractive tzdata
ENV \
  LANG=ja_JP.utf8 \
  XPD_DATA_DIR=/home/wallet/.XP

# Install gosu
ENV GOSU_VERSION 1.10
RUN set -ex; \
  \
  fetchDeps=' \
    ca-certificates \
    wget \
  '; \
  apt-get update; \
  apt-get install -y --no-install-recommends $fetchDeps; \
  rm -rf /var/lib/apt/lists/*; \
  \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu nobody true

# Prepare for build
RUN \
  add-apt-repository ppa:bitcoin/bitcoin -y && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential libssl-dev libdb4.8-dev libdb4.8++-dev \
    libboost-all-dev libqrencode-dev git curl unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Build as a normal user
RUN \
  useradd -d /home/wallet -m -s /bin/bash wallet
WORKDIR /home/wallet
RUN \
  gosu wallet git clone https://github.com/eXperiencePoints/XPCoin && \
  cd XPCoin/src && \
  gosu wallet make -f makefile.unix && \
  gosu wallet chmod +x XPd && \
  chown root:root XPd && \
  mv XPd /usr/local/bin && \
  gosu wallet rm -fr /home/wallet/XPCoin

COPY docker-entrypoint.sh /home/wallet/
RUN \
  gosu wallet mkdir ${XPD_DATA_DIR} && \
  chown wallet:wallet /home/wallet/docker-entrypoint.sh && \
  chmod +x /home/wallet/docker-entrypoint.sh

# RUN \
#   apt-get update && \
#   DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#     vim sudo && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/* && \
#   echo "wallet ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wallet

USER wallet
VOLUME ["${XPD_DATA_DIR}"]
EXPOSE 28191 28192
CMD ["/usr/local/bin/XPd", "--datadir=${XPD_DATA_DIR}"]
