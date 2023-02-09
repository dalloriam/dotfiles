def "git todo" [] {
    git diff | rg "FIXME\(pr\)" | lines
}

def gc [message: string] {
    let todos = (git todo)
    if ($todos | length) > 0 {
        echo "Cannot commit, TODOs are pending:"
        for $todo in $todos {
            echo $todo
        }
    } else {
        git commit -m $message
    }
}

def "git current-branch" [] {
  git rev-parse --abbrev-ref HEAD | str trim
}

def gcp [msg:string] {
  git commit -m $msg
  git push origin (git current-branch)
}
