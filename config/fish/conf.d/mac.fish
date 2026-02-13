if test (uname) = Darwin
    fish_add_path /usr/local/bin

    fish_add_path ~/Library/Python/3.9/bin/
    fish_add_path /opt/homebrew/bin
    fish_add_path (brew --prefix)/opt/llvm/bin
    fish_add_path /Applications/Obsidian.app/Contents/MacOS

    fish_add_path /Applications/Sublime\ Text.app/Contents/SharedSupport/bin

    # Set 1password SSH agent for non-OpenSSH implementations
    # (e.g. libgit2 used by jujutsu)
    set -x SSH_AUTH_SOCK ~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock

    # The next line updates PATH for the Google Cloud SDK.
    if [ -f '/Users/wduss/.gcloud/sdk/google-cloud-sdk/path.fish.inc' ]
        . '/Users/wduss/.gcloud/sdk/google-cloud-sdk/path.fish.inc'
    end
end
