#! /usr/bin/env fish

# Platform tags usable as a `.tag` suffix on any file or directory name.
set -g PLATFORM_TAGS linux macos arch ubuntu

function is_linux
    if test (uname) = Linux
        return 0
    else
        return 1
    end
end

function is_mac
    if test (uname) = Darwin
        return 0
    else
        return 1
    end
end

function is_arch
    if type -q pacman
        return 0
    else
        return 1
    end
end

function is_ubuntu
    if type -q apt-get
        return 0
    else
        return 1
    end
end

function installed --argument program
    if type -P -- $program >/dev/null 2>/dev/null
        return 0
    else
        return 1
    end
end

function ensure_installed --argument program
    if not installed $program
        echo "$program installing"
        ./strap/installers/$program

        # Re-source everything in fish/conf.d
        for file in $__fish_config_dir/conf.d/*.fish
            source $file
        end
    end
end

# --- Platform tags --------------------------------------------------------

# Echoes the platform tag of a single path component, if it has one.
function platform_tag --argument name
    set --local matches (string match -r '\.([^.\/]+)$' -- $name)
    if test (count $matches) -lt 2
        return 0
    end

    if contains -- $matches[2] $PLATFORM_TAGS
        echo $matches[2]
    end
end

# True when the given platform tag applies to the current machine.
function platform_matches --argument tag
    switch $tag
        case linux
            is_linux
        case macos
            is_mac
        case arch
            is_arch
        case ubuntu
            is_ubuntu
        case '*'
            false
    end
end

# True unless some component of the path carries a tag for another platform.
function platform_allows --argument path
    for part in (string split / -- $path)
        set --local tag (platform_tag $part)
        if test -n "$tag"; and not platform_matches $tag
            return 1
        end
    end

    return 0
end

function strip_platform_tag --argument name
    set --local tag (platform_tag $name)
    if test -n "$tag"
        string replace -r -- '\.'$tag'$' "" $name
    else
        echo $name
    end
end

function strip_platform_tags --argument path
    set --local parts
    for part in (string split / -- $path)
        set --append parts (strip_platform_tag $part)
    end

    string join / -- $parts
end

# --- Installation ---------------------------------------------------------

function render_file --argument source target
    # We only want to substitute the known variables, not things like `PATH`.
    envsubst "$(cat VARIABLES)" <$source >$target
end

# json targets are deep-merged, everything else is concatenated.
function merge_strategy --argument target
    if not string match -q -- '*.json' $target
        echo append
        return
    end

    # jq does the merging, and the config stages run before the tool stage on a
    # fresh machine, so pull it in on demand rather than assuming it's there.
    if not set -q __strap_checked_jq
        set -g __strap_checked_jq 1
        ensure_installed jq
    end

    if installed jq
        echo json
    else
        echo "  warning: jq unavailable, $target will be overwritten instead of merged" >&2
        echo append
    end
end

# Merges $overlay into $base, in place. The overlay wins on conflicts.
# Returns non-zero, leaving $base untouched, when the two can't be merged
# (either side unparseable, or not two objects); the caller decides what a
# failed merge means for the file it's installing.
function apply_layer --argument strategy base overlay
    switch $strategy
        case json
            set --local merged (mktemp)
            set --local errors (mktemp)
            if jq -s --indent 4 '.[0] * .[1]' $base $overlay >$merged 2>$errors
                cat $merged >$base
                rm -f $merged $errors
                return 0
            end

            echo "  jq: "(head -n 1 $errors) >&2
            rm -f $merged $errors
            return 1
        case '*'
            echo >>$base
            cat $overlay >>$base
            return 0
    end
end

function install_file --argument source target
    set --local strategy (merge_strategy $target)

    set --local staged (mktemp)
    render_file $source $staged

    # Layer any platform-specific companion files on top of the base file.
    set --local source_tag (platform_tag $source)
    if test -z "$source_tag"
        for tag in $PLATFORM_TAGS
            set --local layer "$source.$tag"
            if test -f $layer; and platform_matches $tag
                set --local rendered (mktemp)
                render_file $layer $rendered
                if not apply_layer $strategy $staged $rendered
                    echo "  warning: "(basename $layer)" could not be merged into $target, layer skipped" >&2
                end
                rm -f $rendered
            end
        end
    end

    if test $strategy = json; and test -f $target
        # Merge over what's installed so keys the app wrote itself survive.
        set --local existing (mktemp)
        cat $target >$existing
        if apply_layer json $existing $staged
            cat $existing >$target
        else
            # The installed file is the app's own state. Never drop it quietly.
            cat $target >"$target.strap-bak"
            cat $staged >$target
            echo "  warning: $target was unmergeable and has been replaced, previous copy in $target.strap-bak" >&2
        end
        rm -f $existing
    else
        if test -e $target
            rm $target
        end
        cat $staged >$target
    end

    rm -f $staged

    # Set the dest executable if the source is executable.
    if test -x $source
        chmod +x $target
    end
end

# Installs every file of $source_dir under $target_prefix, honoring platform
# tags. $target_prefix is prepended as-is, so it needs its own trailing
# separator (`$HOME/.config/`, `$HOME/.`, ...).
function install_tree --argument source_dir target_prefix force_executable
    for file_path in (find $source_dir/* -type f)
        set --local src_path (realpath $file_path)

        # Remove $source_dir from the file path
        set --local file_name (echo $file_path | sed "s|$source_dir/||")

        if not platform_allows $file_name
            continue
        end

        # A platform file sitting next to its base file is a layer of that
        # file, and gets installed along with it rather than on its own.
        set --local tag (platform_tag $file_name)
        if test -n "$tag"; and test -e (strip_platform_tag $src_path)
            continue
        end

        set --local tgt_path $target_prefix(strip_platform_tags $file_name)

        # Create the directory if it doesn't exist
        mkdir -p (dirname $tgt_path)

        install_file $src_path $tgt_path

        if test -n "$force_executable"
            chmod +x $tgt_path
        end

        echo $file_name
    end
end
