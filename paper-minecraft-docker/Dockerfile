FROM debian:jessie-slim

RUN echo "deb http://ppa.launchpad.net/linuxuprising/java/ubuntu bionic main" | tee /etc/apt/sources.list.d/linuxuprising-java.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 73C3DB2A

RUN apt-get update

RUN mkdir -p /usr/share/man/man1 && \
    echo oracle-java11-installer shared/accepted-oracle-license-v1-2 select true | /usr/bin/debconf-set-selections && \
    apt-get -y install oracle-java11-installer && \
    wget -q https://papermc.io/ci/job/Paper/lastSuccessfulBuild/artifact/paperclip.jar -O /paper.jar;

RUN echo exit 0 > /usr/sbin/policy-rc.d

WORKDIR /data
VOLUME /data

EXPOSE 25565

COPY start.sh /start.sh

CMD /start.sh
