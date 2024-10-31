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

    # Set 1password SSH agent for non-OpenSSH implementations
    # (e.g. libgit2 used by jujutsu)
    set -x SSH_AUTH_SOCK ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/wduss/.gcloud/sdk/google-cloud-sdk/path.fish.inc' ]
    . '/Users/wduss/.gcloud/sdk/google-cloud-sdk/path.fish.inc'
end
