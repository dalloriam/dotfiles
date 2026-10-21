# Convert CD-ROM BIN/CUE images to CHD files.
export def chd [...files: path] {
    for file in $files {
        let cue = ($file | path expand)
        let parsed = ($cue | path parse)

        if not ($cue | path exists) {
            error make { msg: $"CUE file not found: ($cue)" }
        }

        if ($parsed.extension | str lowercase) != "cue" {
            error make { msg: $"Expected a .cue file: ($cue)" }
        }

        let output = ($parsed.parent | path join $"($parsed.stem).chd")
        print $"Converting ($cue) to ($output)..."
        ^chdman createcd -i $cue -o $output
    }
}
