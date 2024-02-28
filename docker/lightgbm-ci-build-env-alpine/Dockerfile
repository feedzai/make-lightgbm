FROM alpine:3.18.4

RUN apk add clang git cmake make gcc g++ tar zip curl openjdk8 bash

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

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk/

WORKDIR lightgbm/
