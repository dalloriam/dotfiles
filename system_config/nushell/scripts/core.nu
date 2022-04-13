def bin-exists [name:string] {
  (which $name | length) == 1
}

def "git current-branch" [] {
  git rev-parse --abbrev-ref HEAD | str trim
}

def gcp [msg:string] {
  git commit -m $msg
  git push origin (git current-branch)
}
