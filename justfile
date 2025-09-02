set export := true

# Default Variables
# User can override these variables by setting them in their environment or by
# writing them to a `.env` file in the root of this project.

set dotenv-load := true

KITTY_FONT_SIZE := env_var_or_default("KITTY_FONT_SIZE", "14")
KITTY_FONT_FAMILY := env_var_or_default("KITTY_FONT_FAMILY", "TX-02")
JD_FOLDER := env_var_or_default("JD_FOLDER", "~/.jd")
MUSIC_DIR := env_var_or_default("MUSIC_DIR", "~/mnt/media/music")

docker:
    docker build -t dalloriam/dotfiles .

strap +args="":
    ./bootstrap.sh {{ args }}

update:
    cd private && git pull origin main && cd ..
