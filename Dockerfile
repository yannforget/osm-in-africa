FROM jupyter/scipy-notebook:abdb27a6dfbb

ENV PROTOZERO_VERSION 1.6.7
ENV OSMIUM_VERSION 2.15.1
ENV OSMIUM_TOOL_VERSION 1.10.0
ENV PYOSMIUM_VERSION 2.15.2

USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Libosmium dependencies
        build-essential \
        cmake \
        g++ \
        git \
        graphviz \
        libboost-dev \
        libbz2-dev \
        libexpat1-dev \
        libgdal-dev \
        libgeos++-dev \
        libproj-dev \
        libsparsehash-dev \
        make \
        ruby \
        ruby-json \
        spatialite-bin \
        zlib1g-dev \
        # Osmium-tool dependencies
        libprotozero-dev \
        libboost-program-options-dev && \
    rm -rf /var/lib/apt/lists/*

# Build protozero, libosmium and osmium-tool
RUN wget https://github.com/osmcode/libosmium/archive/v${OSMIUM_VERSION}.tar.gz && \
    wget https://github.com/osmcode/osmium-tool/archive/v${OSMIUM_TOOL_VERSION}.tar.gz && \
    wget https://github.com/mapbox/protozero/archive/v${PROTOZERO_VERSION}.tar.gz && \
    for f in *.tar.gz; do tar xzvf $f && rm $f; done && \
    mv protozero* protozero && mv libosmium* libosmium && mv osmium-tool* osmium-tool && \
    mkdir osmium-tool/build && cd osmium-tool/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && make -j$(nproc) && make install

# Install more conda packages
ADD environment.yml /tmp/environment.yml
RUN conda env update -n root -f /tmp/environment.yml

RUN rm -r libosmium && rm -r osmium-tool && rm -r protozero

USER $NB_UID
