function setup_neovim
    if test -d ~/.config/nvim
        echo "Neovim setup already exists"
        return
    end

    git clone git@github.com:dalloriam/nvim.git ~/.config/nvim
end
