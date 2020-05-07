FROM ubuntu:20.04

LABEL maintainer="William Dussault <dalloriam@gmail.com>"

# Setup prereqs
RUN apt update && apt install -y libssl-dev python3-pip fish unzip
RUN chsh -s /usr/bin/fish

# Bootstrap binman, jump & just.
ADD https://github.com/purposed/binman/releases/latest/download/binman-linux-amd64 /usr/local/bin/binman
ADD https://github.com/casey/just/releases/download/v0.5.10/just-v0.5.10-x86_64-unknown-linux-musl.tar.gz /tmp/just.tar.gz
ADD https://github.com/gsamokovarov/jump/releases/latest/download/jump_linux_amd64_binary /usr/local/bin/jump
ADD https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip /tmp/exa.zip
RUN chmod +x /usr/local/bin/binman && \
    chmod +x /usr/local/bin/jump && \
    cd /tmp && \
    tar xvf just.tar.gz && \
    mv just /usr/local/bin/just && \
    unzip exa.zip && \
    chmod +x exa-linux-x86_64 && \
    mv exa-linux-x86_64 /usr/bin/exa

ADD . /root/.dotfiles
RUN cd /root/.dotfiles/ && \
    just minimal

# Hijack the prompt because for some reason it doesn't work in docker...
# TODO: Fix.
RUN truncate --size 0 /root/.dotfiles/config/fish/functions/fish_prompt.fish

WORKDIR /root
ENTRYPOINT "/usr/bin/fish"
