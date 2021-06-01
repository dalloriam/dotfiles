FROM rust
ADD ./bootstrap /app
WORKDIR /app
RUN cargo build --release

FROM ubuntu:20.04

LABEL maintainer="William Dussault <dalloriam@gmail.com>"

# Setup prereqs
RUN apt update && apt install -y libssl-dev fish unzip git
COPY --from=0 /app/target/release/bootstrap /usr/bin/bootstrap
RUN useradd -ms /usr/bin/fish dev

USER dev
WORKDIR /home/dev
RUN /usr/bin/bootstrap all

# Bootstrap binman, jump & just.
#ADD . /root/.dotfiles
#RUN cd /root/.dotfiles/ && \

# Hijack the prompt because for some reason it doesn't work in docker...
# TODO: Fix.
#RUN truncate --size 0 /root/.dotfiles/config/fish/functions/fish_prompt.fish

#WORKDIR /root
ENTRYPOINT "/usr/bin/fish"
