export def commit [] {
  git commit -m (gum input --width 50 --placeholder "Commit message")
}

export def commit-push [] {
  commit
  git push origin (git rev-parse --abbrev-ref HEAD | str trim)
}

export def git-checkpoint [] {
  let date = (date now | format date "%Y-%m-%d %H:%M:%S")
  git stash push --include-untracked -m $"checkpoint: ($date)"
  git stash apply
}
