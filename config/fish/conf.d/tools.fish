
# Go Jump
status --is-interactive; and source (jump shell fish | psub)

# Purposed config
set -x PURPOSED_OWNER dalloriam
set -x PROJECT_HOME $HOME/src

alias workon "vf activate"
alias deactivate "vf deactivate"
alias lsvirtualenv "vf ls"
alias mkvirtualenv "vf new"
alias rmvirtualenv "vf rm"

set -gx FZF_DEFAULT_OPTS           '--height=50% --min-height=15 --reverse'
set -gx EDITOR 'vim'
