FROM alpine:3.18.4

RUN apk add git \
    cmake=3.26.5-r0 \
    make \
    g++=12.2.1_git20220924-r10 \
    tar \
    zip \
    curl \
    bash

# Install Java
ARG JAVA_ZULU_DOWNLOAD_VERSION=zulu8.72.0.17-ca-jdk8.0.382-linux_musl_x64
ARG JAVA_ZULU_SHA256=4c570c3033a1368407078025db84b96131338bfe695037280339e37bf67d382a
RUN mkdir /java \
    && curl https://cdn.azul.com/zulu/bin/${JAVA_ZULU_DOWNLOAD_VERSION}.tar.gz -o java.tar.gz \
    && if [[ "$(sha256sum java.tar.gz | cut -d " " -f1)" != "${JAVA_ZULU_SHA256}" ]]; then echo "INVALID DOWNLOAD HASH!"; exit 1; fi \
    && tar -xzvf java.tar.gz -C /java \
    && rm java.tar.gz
ENV JAVA_HOME="/java/${JAVA_ZULU_DOWNLOAD_VERSION}"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Swig
RUN curl -L https://downloads.sourceforge.net/project/swig/swig/swig-3.0.12/swig-3.0.12.tar.gz -o swig.tar.gz
RUN tar -xzf swig.tar.gz \
 && cd swig-3.0.12 \
 && ./configure --prefix=/usr/local --without-pcre \
 && make \
 && make install \
 && cd .. \
 && rm swig.tar.gz \
 && rm -rf swig-3.0.12

WORKDIR lightgbm/
