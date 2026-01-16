# prompt
if type -q starship
    starship init fish | source
end

# zoxide (quick jump)
if type -q zoxide
    zoxide init --cmd j fish | source
end

# direnv
if type -q direnv
    direnv hook fish | source
end

# Jujutsu VCS
if type -q jj
    jj util completion fish | source
end

# Purposed config
set -x PURPOSED_OWNER dalloriam
set -x PROJECT_HOME $HOME/src
set -x JD_ROOT $JD_FOLDER
set -x CLOUD_CREDS $PERSONAL_CLOUD
set -x SD_ROOT $HOME/scripts

alias workon "vf activate"
alias deactivate "vf deactivate"
alias lsvirtualenv "vf ls"
alias mkvirtualenv "vf new"
alias rmvirtualenv "vf rm"

set -gx FZF_DEFAULT_OPTS '--height=50% --min-height=15 --reverse'
set -gx EDITOR nvim

if type -q fnm
    fnm env --use-on-cd --shell fish | source
end
