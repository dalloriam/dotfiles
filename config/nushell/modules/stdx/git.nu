export def commit [] {
  git commit -m (gum input --width 50 --placeholder "Commit message")
}

export def commit-push [] {
  commit
  git push origin (git rev-parse --abbrev-ref HEAD | str trim)
}
