FROM rust
ADD ./bootstrap /app
WORKDIR /app
RUN cargo build --release

FROM archlinux:latest
LABEL maintainer="William Dussault <william@dussault.dev>"


# Setup prereqs
RUN pacman -Syu --noconfirm && pacman --noconfirm -S openssl git curl sudo nushell tar zip

COPY --from=0 /app/target/release/bootstrap /usr/bin/bootstrap
RUN useradd -ms /usr/bin/nu dev && passwd -d dev && usermod -aG wheel dev
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers

USER dev

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD . /home/dev/.dotfiles
RUN sudo chown -R dev /home/dev/.dotfiles

WORKDIR /home/dev/.dotfiles
RUN yes | bootstrap apply config scripts
RUN mkdir -p /home/dev/.cache/starship && \
    starship init nu > /home/dev/.cache/starship/init.nu


WORKDIR /home/dev

ENTRYPOINT "/usr/bin/nu"
