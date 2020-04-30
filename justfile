install_binman:
    #!/bin/bash
    if test -f ~/bin/binman; then
        echo "Binman already installed"
    else
        wget https://github.com/purposed/binman/releases/latest/download/binman-linux-amd64 -O ~/bin/binman
        chmod +x ~/bin/binman
    fi


python_deps:
    pip3 install --user -r requirements.txt 1>/dev/null


install target:
    python3 install.py {{target}}


all: install_binman python_deps
    just install fonts
    just install config
    just install dotfiles
    just install scripts
    just install datahose
    just install tools
