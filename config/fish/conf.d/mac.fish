if test (uname) = "Darwin"
    set PATH $PATH /usr/local/bin
    set PATH $PATH /usr/local/go/bin

    set PATH ~/Library/Python/3.8/bin $PATH
    set PATH /opt/homebrew/bin $PATH

    # Disable smart quotes.
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
end
