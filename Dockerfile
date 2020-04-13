FROM ubuntu:trusty
MAINTAINER Laurent Coustet <ed@zehome.com>

# ubuntu extras
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 16126D3A3E5C1192

# apt
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/minimal && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/minimal && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty main restricted' >/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty main restricted' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main restricted' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-updates main restricted' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty universe' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty universe' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates universe' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-updates universe' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty multiverse' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty multiverse' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty-updates multiverse' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-updates multiverse' >>/etc/apt/sources.list && \
    echo 'deb http://fr.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse' >>/etc/apt/sources.list && \
    echo 'deb-src http://fr.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse' >>/etc/apt/sources.list && \
    echo 'deb http://security.ubuntu.com/ubuntu trusty-security main restricted' >>/etc/apt/sources.list && \
    echo 'deb-src http://security.ubuntu.com/ubuntu trusty-security main restricted' >>/etc/apt/sources.list && \
    echo 'deb http://security.ubuntu.com/ubuntu trusty-security universe' >>/etc/apt/sources.list && \
    echo 'deb-src http://security.ubuntu.com/ubuntu trusty-security universe' >>/etc/apt/sources.list && \
    echo 'deb http://security.ubuntu.com/ubuntu trusty-security multiverse' >>/etc/apt/sources.list && \
    echo 'deb-src http://security.ubuntu.com/ubuntu trusty-security multiverse' >>/etc/apt/sources.list && \
    echo 'deb http://extras.ubuntu.com/ubuntu trusty main' >>/etc/apt/sources.list && \
    echo 'deb-src http://extras.ubuntu.com/ubuntu trusty main' >>/etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get -qqy update && apt-get -y install \
    apt-transport-https software-properties-common python-software-properties

RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get -qqy update && \
    apt-get -y install \
    autoconf \
    automake \
    bison \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    flex \
    gcc-9 g++-9 \
    git \
    gperf \
    libbz2-dev \
    libexpat1-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libreadline-dev \
    libssl-dev \
    libsqlite3-dev \
    liblzma-dev \
    openssh-client \
    pkg-config \
    realpath \
    uuid-dev \
    wget \
    zlib1g-dev

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 40 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 40 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-9 40 && \
    update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-9 40


# Locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen && \
    update-locale

RUN apt-get clean

WORKDIR /root
CMD ["/bin/bash"]

