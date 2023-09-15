# Using this version instead of the latest LTS because we need a version with glibc version < than what we have in cloud instances (v2.26)
FROM ubuntu:16.04

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        build-essential \
        libomp-dev \
        clang \
        apt-utils \
        curl \
        git \
        tar \
        gnupg-curl \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/*

# Install CMake
RUN curl -OL https://github.com/Kitware/CMake/releases/download/v3.27.4/cmake-3.27.4-linux-aarch64.sh \
 && curl -OL https://github.com/Kitware/CMake/releases/download/v3.27.4/cmake-3.27.4-SHA-256.txt \
 && curl -OL https://github.com/Kitware/CMake/releases/download/v3.27.4/cmake-3.27.4-SHA-256.txt.asc \
 && gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys C6C265324BBEBDC350B513D02D2CEF1034921684 \
 && gpg --verify cmake-3.27.4-SHA-256.txt.asc cmake-3.27.4-SHA-256.txt \
 && rm cmake-3.27.4-SHA-256.txt.asc \
 && sha256sum -c --ignore-missing cmake-3.27.4-SHA-256.txt \
 && rm cmake-3.27.4-SHA-256.txt \
 && mv cmake-3.27.4-linux-aarch64.sh cmake.sh \
 && chmod +x cmake.sh \
 && ./cmake.sh --prefix=/usr/local --exclude-subdir \
 && rm cmake.sh

# Install Java
ARG JAVA_ZULU_DOWNLOAD_VERSION=zulu8.72.0.17-ca-jdk8.0.382-linux_aarch64
ARG JAVA_ZULU_SHA256=bde61dd92b47baf9c9a15461c365765ae825b5e6e37602014c457b5be6f7b428
RUN mkdir /java \
    && curl https://cdn.azul.com/zulu-embedded/bin/${JAVA_ZULU_DOWNLOAD_VERSION}.tar.gz -o java.tar.gz \
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
