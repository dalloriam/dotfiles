# === PATH ===
$env.PATH = ($env.PATH | prepend ($env.HOME | path join "bin"))
$env.PATH = ($env.PATH | prepend "/usr/local/go/bin")

# === C++ ===
if (which clang++ | is-not-empty) {
    $env.CXX = (which clang++ | get path | first)
}

# === Python ===
$env.WORKON_HOME = ($env.HOME | path join ".virtualenvs")
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".local/bin"))

# === Go ===
if (which go | is-not-empty) {
    $env.GO111MODULE = "on"
    $env.GOPATH = $env.HOME
    $env.PATH = ($env.PATH | prepend ($env.GOPATH | path join "bin"))
}

# === Rust ===
if (($env.HOME | path join ".cargo/bin") | path exists) {
    $env.PATH = ($env.PATH | prepend ($env.HOME | path join ".cargo/bin"))
}

# === Tools ===
$env.SD_ROOT = ($env.HOME | path join "scripts")
$env.FZF_DEFAULT_OPTS = "--height=50% --min-height=15 --reverse"
$env.EDITOR = "nvim"

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

# === Generate tool init cache files (sourced by config.nu) ===
mkdir ~/.cache/starship
mkdir ~/.cache/zoxide
mkdir ~/.cache/jj

if (which starship | is-not-empty) {
    starship init nu | save -f ~/.cache/starship/init.nu
} else {
    "# starship not installed" | save -f ~/.cache/starship/init.nu
}

if (which zoxide | is-not-empty) {
    zoxide init --cmd j nushell | save -f ~/.cache/zoxide/init.nu
} else {
    "# zoxide not installed" | save -f ~/.cache/zoxide/init.nu
}

if (which jj | is-not-empty) {
    jj util completion nushell | save -f ~/.cache/jj/completions.nu
} else {
    "# jj not installed" | save -f ~/.cache/jj/completions.nu
}
