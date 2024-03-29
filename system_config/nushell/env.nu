# Nushell Environment Config File

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str collect (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
let-env GOROOT = "/usr/local/go"
let-env GO111MODULE = "on"
let-env GOPATH = $env.HOME
let-env COVEO_REPOSITORY_ROOT = $"($env.HOME)/src/github.com/coveo"

let-env PATH = ($env.PATH | prepend $"($env.GOPATH)/bin")
let-env PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin")
let-env PATH = ($env.PATH | prepend /usr/local/bin)
let-env PATH = ($env.PATH | prepend /usr/local/go/bin)
let-env PATH = ($env.PATH | prepend /opt/homebrew/bin)
let-env PATH = ($env.PATH | prepend $"($env.HOME)/.nix-profile/bin")
let-env PATH = ($env.PATH | prepend /nix/var/nix/profiles/default/bin)

# Setting up starship
starship init nu | save ~/.cache/starship/init.nu
