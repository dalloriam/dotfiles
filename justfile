build:
    cd bootstrap && cargo build

run +args="":
    @just build
    ./bootstrap/target/debug/bootstrap {{args}}

docker:
    docker build -t dalloriam/dotfiles .
