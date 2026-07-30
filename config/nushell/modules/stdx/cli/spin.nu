# spin.nu show a spinner + message while a closure runs
#
# Usage:
#   spin "Building firmware..." { cargo build --release }
#   spin "Flashing FPGA image" { just flash } --interval 60ms

export def main [
    msg: string                      # message shown next to the spinner
    cmd: closure                     # code to run while spinning
    --interval (-i): duration = 80ms # frame interval
    --return (-r)                     # return the {stdout, stderr, exit_code} record
] {

    let frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
    mut i = 0

    # Run the closure in a background thread. `complete` captures
    # stdout/stderr/exit_code instead of letting output race the spinner.
    let job_id = (job spawn {
        let result = (do $cmd | complete)
        $result | job send 0
    })

    # Poll: the job disappears from `job list` once it finishes.
    while (job list | where id == $job_id | is-not-empty) {
        let frame = ($frames | get ($i mod ($frames | length)))
        print -n $"\r(ansi erase_line)(ansi cyan_bold)($frame)(ansi reset) ($msg)"
        $i += 1
        sleep $interval
    }

    let result = (job recv)

    if $result.exit_code == 0 {
        print $"\r(ansi erase_line)(ansi green_bold)✓(ansi reset) ($msg)"
    } else {
        print $"\r(ansi erase_line)(ansi red_bold)✗(ansi reset) ($msg) (ansi red_dimmed)\(exit ($result.exit_code)\)(ansi reset)"
    }

    if ($result.stdout | str trim | is-not-empty) {
        print $result.stdout
    }
    if ($result.stderr | str trim | is-not-empty) {
        print -e $result.stderr
    }

    if $return {
        $result
    } else {
        null
    }
}
