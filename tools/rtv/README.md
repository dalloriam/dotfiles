# RTV
Simple docker wrapper for Reddit Terminal Viewer.

## Usage
As usual, define this function somewhere in your shell config.
```bash
reddit() {
    docker run \
    -v $HOME/.config/rtv:/root/.config/rtv \
    -v $HOME/.local/share/rtv:/root/.local/share/rtv \
    --rm -it \
    dalloriam/rtv
}
```

*Note: Make sure to define all the appropriate rtv-related configuration files in the* `$HOME/.config/rtv` directory.