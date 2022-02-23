run +args="":
    cd bootstrap/ && cargo build
    ./bootstrap/target/debug/bootstrap {{args}}

docker:
    docker system prune
    docker build -t dalloriam/dotfiles .
