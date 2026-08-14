
const SRC_DIR = "~/src"

# All git projects under $path, as {name, path} records. Recursion stops at a
# project boundary, so vendored/build dirs inside a project are never walked.
def discover [path: string] {
    let path = ($path | path expand)

    if ($path | path join ".git" | path exists) {
        return [{name: ($path | path basename), path: $path}]
    }

    ls -a $path
    | where type == dir
    | where {|e| ($e.name | path basename) != ".git"}
    | each {|e| discover $e.name}
    | flatten
}

def find_project [project_name: string] {
    let matches = (discover $SRC_DIR | where name == $project_name)

    if ($matches | is-empty) {
        error make { msg: $"No project named '($project_name)' found under ($SRC_DIR)" }
    }

    if (($matches | length) > 1) {
        let paths = ($matches | get path | str join "\n  ")
        error make { msg: $"Ambiguous project name '($project_name)':\n  ($paths)" }
    }

    $matches | first | get path
}

def list [path = $SRC_DIR] {
    discover $path | get name
}

export def cli [project_name: string] {
    let project_path = find_project $project_name
    cd $project_path
    zellij attach $project_name --create
}

export def gui [project_name: string] {
    let project_path = find_project $project_name
    zed $project_path
}

export def pick-cli [] {
    let picked = (list | input list --fuzzy)
    if ($picked | is-not-empty) {
        cli $picked
    }
}

export def pick-gui [] {
    let picked = (list | input list --fuzzy)
    if ($picked | is-not-empty) {
        gui $picked
    }
}

export alias ls = list
