FROM rust
ADD ./bootstrap /app
WORKDIR /app
RUN cargo build --release

FROM ubuntu:22.04

LABEL maintainer="William Dussault <william@dussault.dev>"

# Setup prereqs
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssl libssl1.1 libssl-dev fish unzip git curl sudo locales build-essential pkg-config

COPY --from=0 /app/target/release/bootstrap /usr/bin/bootstrap
RUN useradd -ms /usr/bin/fish dev && passwd -d dev && usermod -aG sudo dev
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

USER dev
WORKDIR /home/dev

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN yes | bootstrap all

ENTRYPOINT "/usr/bin/fish"
