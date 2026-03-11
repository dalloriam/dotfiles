# macOS-specific configuration
# (PATH additions are handled in env.nu; add runtime-only macOS config here)
$env.PATH = ($env.PATH | prepend "/usr/local/bin")
$env.PATH = ($env.PATH | prepend ($env.HOME | path join "Library/Python/3.9/bin"))
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")

# Homebrew LLVM (check both Apple Silicon and Intel paths)
for llvm_bin in ["/opt/homebrew/opt/llvm/bin" "/usr/local/opt/llvm/bin"] {
    if ($llvm_bin | path exists) {
        $env.PATH = ($env.PATH | prepend $llvm_bin)
        break
    }
}

$env.PATH = ($env.PATH | prepend "/Applications/Obsidian.app/Contents/MacOS")
$env.PATH = ($env.PATH | prepend "/Applications/Sublime Text.app/Contents/SharedSupport/bin")

# 1Password SSH agent for non-OpenSSH implementations (e.g. libgit2 used by jujutsu)
$env.SSH_AUTH_SOCK = ($env.HOME | path join "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock")

# Google Cloud SDK
let gcloud_bin = "/Users/wduss/.gcloud/sdk/google-cloud-sdk/bin"
if ($gcloud_bin | path exists) {
    $env.PATH = ($env.PATH | prepend $gcloud_bin)
}
