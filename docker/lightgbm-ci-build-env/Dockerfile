FROM ubuntu:20.04

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
        software-properties-common 

RUN apt-add-repository ppa:git-core/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-utils \
        curl \
        git \
        jq \
        libcurl4 \
        libunwind8 \
        netcat \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt-get install -y --no-install-recommends git-lfs \
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
 && rm -rf /var/lib/apt/lists/*

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
RUN apt-get update \
 && apt-get install gpg-agent

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# Install Java
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9 \
 && add-apt-repository "deb http://repos.azulsystems.com/ubuntu stable main" -y \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    zulu-8 \
 && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME_8_X64=/usr/lib/jvm/zulu-8-amd64
ENV JAVA_HOME=$JAVA_HOME_8_X64

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

# Install Miniconda
RUN curl -sL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
 && chmod +x miniconda.sh \
 && ./miniconda.sh -b -p /opt/conda \
 && rm miniconda.sh \
 && /opt/conda/bin/conda install python=3 -q -y \
 && /opt/conda/bin/conda install mkl qt -q -y \
 && /opt/conda/bin/conda clean -a -y \
 && chmod -R 777 /opt/conda

ENV CONDA=/opt/conda/

# Install R
RUN add-apt-repository \
        "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" \
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

RUN apt-get update \
    && apt-get install \
        --no-install-recommends \
        -y \
            r-base-dev \
            pandoc \
            texinfo \
            texlive-latex-recommended \
            texlive-fonts-recommended \
            texlive-fonts-extra \
            qpdf

# Clean system
RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /etc/apt/sources.list.d/* \
 && rm -rf /tmp/*


WORKDIR /lightgbm
