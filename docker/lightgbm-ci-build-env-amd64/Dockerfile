# This image uses very specific (and old) versions of the OS and tools. The aim is two-fold.
# First, to match the build pipeline used for the official Microsoft LightGBM releases, for which there are official tests, avoiding unexpected bugs.
# Second, retain libc==2.12, to ensure compatibility of the produced LightGBM binaries with any target machine.
# TLDR: do no not change this version
FROM ubuntu:14.04

### This Dockerfile aims to replace LightGBM's CI Dockerfile environment
### for users that don't have Microsoft credentials.
### LightGBM developers have no intention of changing that image,
### to maintain with older systems.

### Last checked to be compatible at 2020-05-12.
MAINTAINER Alberto Ferreira (alberto.ferreira@feedzai.com)

################ (replicate microsoft/vsts-agent:ubuntu-14.04) ################

# https://github.com/microsoft/vsts-agent-docker/blob/master/ubuntu/14.04/Dockerfile

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections  # dpkg-reconfigure debconf
RUN rm /etc/apt/preferences.d/ubuntu-esm-infra-trusty

# Trusty needs an updated backport of apt to avoid hash sum mismatch errors
RUN [ "trusty" = "trusty" ] \
 && sudo apt-get install curl \
 && curl -s https://packagecloud.io/install/repositories/computology/apt-backport/script.deb.sh |  bash \
 && apt-get update \
 && apt-get install apt=1.2.10 \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/* \
 || echo -n "SETUP trusty done."

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        software-properties-common \
 && apt-add-repository ppa:git-core/ppa \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        apt-utils \
        curl \
        git \
        jq \
        libcurl3 \
        libicu52 \
        libunwind8 \
        netcat \
 && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
 && apt-get install -y --no-install-recommends --allow-unauthenticated git-lfs \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/* \
 echo "UPDATED."

############################ LightLBM CI Dockerfile ############################

# Install basic command-line utilities
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    locales \
    sudo \
    unzip \
    wget \
    zip \
    make \
    tar \
 && rm -rf /var/lib/apt/lists/*

# Update ca certificates to safely perform curls
ADD ca-certificates_20210119~20.04.2.tar.xz /tmp/
RUN cd /tmp/ca-certificates-20210119~20.04.1 \
    && sudo rm -rf /usr/share/ca-certificates/* \
    && sudo make \
    && sudo make install \
    && sudo update-ca-certificates --fresh \
    && /usr/bin/c_rehash /etc/ssl/certs

# Setup the locale
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
RUN locale-gen $LANG \
 && update-locale

# Install essential build tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install CMake
RUN curl -sL https://cmake.org/files/v3.17/cmake-3.17.0-Linux-x86_64.sh -o cmake.sh \
 && chmod +x cmake.sh \
 && ./cmake.sh --prefix=/usr/local --exclude-subdir \
 && rm cmake.sh

# Install clang
ARG CLANG_VER=9.0.0
RUN curl -sL https://releases.llvm.org/$CLANG_VER/clang%2bllvm-$CLANG_VER-x86_64-linux-gnu-ubuntu-14.04.tar.xz -o clang.tar.xz \
 && tar -C /usr/local -xf clang.tar.xz --strip 1 \
 && curl -sL https://releases.llvm.org/$CLANG_VER/openmp-$CLANG_VER.src.tar.xz -o openmp.tar.xz \
 && tar -xf openmp.tar.xz \
 && cd openmp-$CLANG_VER.src \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang .. \
 && make \
 && make install \
 && echo /usr/local/lib > /etc/ld.so.conf.d/openmp.conf \
 && ldconfig \
 && cd ../.. \
 && rm clang.tar.xz \
 && rm openmp.tar.xz \
 && rm -rf openmp-$CLANG_VER.src

# Install Java
ARG JAVA_ZULU_DOWNLOAD_VERSION=zulu8.72.0.17-ca-jdk8.0.382-linux_x64
ARG JAVA_ZULU_SHA256=7b15a56f2ae005beda0f875a269b3daad14ffa12969306cc745478385b25ba96
RUN mkdir /java \
    && curl https://cdn.azul.com/zulu/bin/${JAVA_ZULU_DOWNLOAD_VERSION}.tar.gz -o java.tar.gz \
    && if [[ "$(sha256sum java.tar.gz | cut -d " " -f1)" != "${JAVA_ZULU_SHA256}" ]]; then echo "INVALID DOWNLOAD HASH!"; exit 1; fi \
    && tar -xzvf java.tar.gz -C /java \
    && rm java.tar.gz
ENV JAVA_HOME="/java/${JAVA_ZULU_DOWNLOAD_VERSION}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install SWIG
RUN curl -sL https://downloads.sourceforge.net/project/swig/swig/swig-3.0.12/swig-3.0.12.tar.gz -o swig.tar.gz \
 && tar -xzf swig.tar.gz \
 && cd swig-3.0.12 \
 && ./configure --prefix=/usr/local --without-pcre \
 && make \
 && make install \
 && cd .. \
 && rm swig.tar.gz \
 && rm -rf swig-3.0.12

# Clean system
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/* \
 && rm -rf /tmp/*


WORKDIR /lightgbm
