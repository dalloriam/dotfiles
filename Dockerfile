FROM ubuntu:22.04
LABEL maintainer="William Dussault <william@dussault.dev>"


# Setup prereqs
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:fish-shell/release-3 && \
    apt-get update && \
    apt-get install -y fish build-essential sudo libssl-dev wget curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    cargo install just


RUN useradd -ms /usr/bin/fish dev && passwd -d dev && usermod -aG sudo dev

USER dev

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD . /home/dev/.dotfiles
RUN sudo chown -R dev /home/dev/.dotfiles

WORKDIR /home/dev/.dotfiles
RUN yes | ./bootstrap.sh


WORKDIR /home/dev

ENTRYPOINT "fish"
