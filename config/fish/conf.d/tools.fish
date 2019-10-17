
# Go Jump
status --is-interactive; and source (jump shell fish | psub)

# Purposed config
set -x PURPOSED_OWNER dalloriam
set -x PROJECT_HOME $HOME/src

# Venv config.
# TODO: Add step to install virtualfish.
eval (python -m virtualfish)

alias workon "vf activate"
alias deactivate "vf deactivate"
alias lsvirtualenv "vf ls"
alias mkvirtualenv "vf new"
alias rmvirtualenv "vf rm"
