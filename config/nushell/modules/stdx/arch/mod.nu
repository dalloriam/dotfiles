export def installed [] {
  pacman -Qe | detect columns --no-headers | get column0 
}

export def prune [] {
  let packages = (pacman --query --deps --unrequired | detect columns --no-headers | get column0 | sort | uniq)

  if ($packages | is-empty) {
      gum style --foreground 112 "✓ System is clean, no orphan packages."
      exit 0
  }

  gum join --vertical ...$packages
  gum confirm "Remove these packages?"

  if $env.LAST_EXIT_CODE != 0 {
      gum style --foreground 214 "✗ Aborted, no packages were removed."
      exit 0
  }

  gum spin --title "Removing..." -- sudo pacman --noconfirm --remove --nosave --recursive ...$packages
}

export def restart-waybar [] {
  pkill waybar
  if $env.LAST_EXIT_CODE == 0 {
      setsid --fork waybar out+err> /dev/null
  }
}

