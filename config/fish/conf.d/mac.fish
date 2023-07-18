if test (uname) = Darwin
    set PATH $PATH /usr/local/bin
    set PATH $PATH /usr/local/go/bin

    set PATH ~/Library/Python/3.9/bin $PATH
    set PATH /opt/homebrew/bin $PATH
    set PATH (brew --prefix)/opt/llvm/bin $PATH

    set PATH /Applications/Sublime\ Text.app/Contents/SharedSupport/bin $PATH

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/wduss/.gcloud/path.fish.inc' ]
        . '/Users/wduss/.gcloud/path.fish.inc'
    end
end
