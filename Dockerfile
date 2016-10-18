# Ethereum playground for private networks
#
#FROM ethereum/client-go
FROM ubuntu:14.04


#-----------------------------------------------------------------------------
#install geth
RUN apt-get update && \
    apt-get upgrade -q -y && \
    apt-get dist-upgrade -q -y && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 && \
    echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu wily main" | tee -a /etc/apt/sources.list.d/ethereum.list && \
    apt-get update && \
    apt-get install -q -y geth

EXPOSE 8545
EXPOSE 30303
#-----------------------------------------------------------------------------

ENV GEN_NONCE="0xeddeadbabeeddead" \
    DATA_DIR="/root/.ethereum" \
    CHAIN_TYPE="private" \
    RUN_BOOTNODE=false \
    NET_ID=1981 \
    BOOTNODE_URL=""

RUN apt-get update -y && \
    apt-get install -y bootnode iproute2 curl xz-utils firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#-----------------------------------------------------------------------------
#install node

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.6.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs
#-------------------------------------------------------------------------------
# install chrome
# RUN \
#  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
#  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
#  apt-get update && \
#  apt-get install -y google-chrome-stable && \
#  rm -rf /var/lib/apt/lists/*
#-------------------------------------------------------------------------------

WORKDIR /opt/

# herdados de ethereum/client-go
# EXPOSE 30303
# EXPOSE 8545

# bootnode port
EXPOSE 30301

# kad port
EXPOSE 1337
EXPOSE 1338

EXPOSE 9000

ADD src/* /opt/


# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer
# ENV HOME /home/developer
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developera && \
    echo "developera:x:${uid}:${gid}:Developera,,,:/home/developera:/bin/bash" >> /etc/passwd && \
    echo "developera:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developera && \
    chmod 0440 /etc/sudoers.d/developera && \
    chown ${uid}:${gid} -R /home/developera


# WORKDIR /home/developer/
# USER developer
# ENTRYPOINT ["sudo", "/opt/startgeth.sh"]


ENTRYPOINT ["/opt/startgeth.sh"]

