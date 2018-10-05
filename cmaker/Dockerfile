FROM debian:buster

RUN apt-get update \
    && apt-get install -y \
        make \
        gcc \
        libc6-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /src

WORKDIR /src