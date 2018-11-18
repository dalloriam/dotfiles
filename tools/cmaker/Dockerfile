FROM debian:buster

LABEL maintainer="William Dussault <dalloriam@gmail.com>"

RUN apt-get update \
    && apt-get install -y \
        make \
        gcc \
        libc6-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /src

WORKDIR /src