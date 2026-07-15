# === Shell settings ===
$env.config.show_banner = false

# === Direnv hook ===
use std/config *

# Initialize the PWD hook as an empty list if it doesn't exist
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

$env.config.hooks.env_change.PWD ++= [{||
  if (which direnv | is-empty) {
    # If direnv isn't installed, do nothing
    return
  }

  direnv export json | from json | default {} | load-env
  # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
  $env.PATH = do (env-conversions).path.from_string $env.PATH
}]

# === FNM Hook ===
if not (which fnm | is-empty) {
  fnm env --json | from json | load-env
  $env.PATH = $env.PATH | prepend ($env.FNM_MULTISHELL_PATH | path join (if $nu.os-info.name == 'windows' {''} else {'bin'}))
  $env.config.hooks.env_change.PWD = (
      $env.config.hooks.env_change.PWD? | append {
          condition: {|| ['.nvmrc' '.node-version', 'package.json'] | any {|el| $el | path exists}}
          code: {|| ^fnm use}
      }
  )
}

# === Completion Styling ===
$env.config.menus ++= [{
   name: completion_menu
   only_buffer_difference: false
   marker: "| "
   type: {
     layout: ide
     columns: 1
     col_width: 25
     selection_rows: 20
     description_rows: 20
   }
   style: {
   } 
}]

# === Modules ===
source aliases.nu
source functions.nu
source keybinds.nu

# === Platform-specific ===
if $nu.os-info.name == "linux" {
    source linux.nu
} else if $nu.os-info.name == "macos" {
    source macos.nu
}

# === Tool integrations ===
source ~/.cache/starship/init.nu
source ~/.cache/zoxide/init.nu
source ~/.cache/jj/completions.nu
source $"($nu.cache-dir)/carapace.nu"
