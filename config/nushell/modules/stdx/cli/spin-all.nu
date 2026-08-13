# spin-all.nu — run several closures concurrently, each with its own spinner line
#
# Usage:
#   spin-all [
#     {msg: "Building firmware...", cmd: {cargo build --release}}
#     {msg: "Flashing FPGA image", cmd: {just flash}}
#   ]
#   spin-all $tasks --verbose   # always show logs, even for jobs that succeeded
export def main [
    tasks: list<record<msg: string, cmd: closure>>
    --interval (-i): duration = 80ms
    --verbose (-v)   # print stdout/stderr for every job, not just failed ones
    --return (-r)    # return the list of {msg, result} records instead of exiting
] {
    let frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
    let n = ($tasks | length)

    mut jobs = ($tasks | each {|t|
        let id = (job spawn {
            let result = (do $t.cmd | complete)
            $result | job send 0 --tag (job id)
        })
        {id: $id, msg: $t.msg, done: false, result: null}
    })

    mut frame_i = 0
    for job in $jobs { print $"  ($job.msg)" }   # reserve n lines

    while ($jobs | any {|j| not $j.done }) {
        $jobs = ($jobs | each {|job|
            if $job.done { $job } else {
                let r = (try { job recv --tag $job.id --timeout 0sec } catch { null })
                if $r == null { $job } else { {id: $job.id, msg: $job.msg, done: true, result: $r} }
            }
        })

        print -n $"\e[($n)A"   # move cursor up to the top of the block
        for job in $jobs {
            let line = if $job.done {
                if $job.result.exit_code == 0 {
                    $"(ansi green_bold)✓(ansi reset) ($job.msg)"
                } else {
                    $"(ansi red_bold)✗(ansi reset) ($job.msg) (ansi red_dimmed)\(exit ($job.result.exit_code)\)(ansi reset)"
                }
            } else {
                let frame = ($frames | get ($frame_i mod ($frames | length)))
                $"(ansi cyan_bold)($frame)(ansi reset) ($job.msg)"
            }
            print $"\r(ansi erase_line)($line)"
        }
        $frame_i += 1
        sleep $interval
    }

    for job in $jobs {
        if $verbose or $job.result.exit_code != 0 {
            if ($job.result.stdout | str trim | is-not-empty) { print $job.result.stdout }
            if ($job.result.stderr | str trim | is-not-empty) { print -e $job.result.stderr }
        }
    }

    let failed = ($jobs | where {|j| $j.result.exit_code != 0})

    if $return {
        $jobs | select msg result
    } else if not ($failed | is-empty) {
        exit 1
    }
}
