
def find_project [project_name: string] {
    let SRC_DIR = ($env.HOME | path join "src")
    let base = $SRC_DIR
    let matches = (
        glob ($base | path join "**" $project_name) --no-file --no-symlink
    )

    if ($matches | is-empty) {
        error make { msg: $"No project named '($project_name)' found under ($base)" }
    } else {
        $matches | first
    }
}

def list [path = "~/src"] {
    let path = $path | path expand
    let entries = (ls -a $path | where type == dir)
    let has_git = ($entries | any {|e| $e.name | path basename | $in == ".git"})

    if $has_git {
        let project_name = ($path | path basename)
        [$project_name]
    } else {
        $entries
        | where {|e| ($e.name | path basename) != ".git"}
        | each {|e| list $e.name}
        | flatten
    }
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
