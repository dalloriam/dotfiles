# bottom: use light theme when darkman reports light mode
def btm [] {
    if (which darkman | is-not-empty) and ((^darkman get | str trim) == "light") {
        ^btm --theme default-light
    } else {
        ^btm
    }
}

# Prettify a JSON file in-place
def clean [file: path] {
    let formatted = (open $file | to json --indent 2)
    $formatted | save -f $file
}

# Select a docker container interactively with fzf, returns container ID(s)
def did [] {
    ^docker ps -a | ^fzf --header-lines=1 -m | lines | each { |line|
        $line | str trim | split row --regex '\s+' | first
    }
}

# SCP via SDM (AWS Systems Manager)
# Usage: sdm-scp i-123456789:/path/to/file /path/to/file
def sdm-scp [src: string, dst: string] {
    ^scp -S /usr/local/bin/sdm -osdmSCP $src $dst
}

# Stop, remove all containers and prune all images
def docker-killall [] {
    let ids = (^docker ps -aq | lines | str trim | where { |it| $it != "" })
    if ($ids | is-not-empty) {
        $ids | each { |id| ^docker stop $id | ignore }
        $ids | each { |id| ^docker rm $id | ignore }
    }
    ^docker image prune -a -f | ignore
}

# Yazi file manager with shell directory integration
def --env y [...args: string] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX" | str trim)
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp | str trim)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -f $tmp
}

def nufzf [] {
  $in | each {|i| $i | to json --raw}
      | str join "\n"
      | fzf -m
      | lines
      | each {$in | from json}
      | reduce {|it, acc| $acc | append $it }
}

def --wrapped bazel [...rest] {
  ^bazelisk ...$rest
}
