function did
  docker ps -a | tail -n +2 | eval "fzf $FZF_DEFAULT_OPTS -m --header='[select:container]'" | awk '{print $1}'
end

