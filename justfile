set export

# Default Variables
KITTY_FONT_SIZE := env_var_or_default("KITTY_FONT_SIZE", "14")
KITTY_FONT_FAMILY := env_var_or_default("KITTY_FONT_FAMILY", "Berkeley Mono Regular")

# User can override these variables by setting them in their environment or by
# writing them to a `.env` file in the root of this project.
set dotenv-load

docker:
    docker build -t dalloriam/dotfiles .

test:
    echo "Testing $KITTY_FONT_SIZE"

strap +args="":
    echo $KITTY_FONT_SIZE
    ./bootstrap.sh {{args}}
