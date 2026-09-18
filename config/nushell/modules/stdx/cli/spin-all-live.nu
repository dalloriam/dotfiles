# spin-all-live.nu — like spin-all, but tails each closure's latest output line live
#
# Each task's stdout+stderr is redirected to a temp file as it runs, and the
# task's line shows the most recent line written to that file. Useful for
# closures that `print` progress (e.g. `cargo build` piped through a filter).
#
# Usage:
#   spin-all-live [
#     {msg: "Building firmware...", cmd: {cargo build --release}}
#     {msg: "Flashing FPGA image", cmd: {just flash}}
#   ]
#   spin-all-live $tasks --verbose   # print full captured output for every job, not just failed ones
export def main [
    tasks: list<record<msg: string, cmd: closure>>
    --interval (-i): duration = 80ms
    --verbose (-v)   # print captured output for every job, not just failed ones
    --return (-r)    # return the list of {msg, result} records instead of exiting
] {
    let frames = ["⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"]
    let n = ($tasks | length)
    let width = (try { (term size).columns } catch { 80 })

    mut jobs = ($tasks | each {|t|
        let tmp = (mktemp)
        let id = (job spawn {
            let exit_code = (try {
                do $t.cmd out+err> $tmp
                0
            } catch {|e|
                ($e.exit_code? | default 1)
            })
            {exit_code: $exit_code} | job send 0 --tag (job id)
        })
        {id: $id, msg: $t.msg, tmp: $tmp, done: false, result: null}
    })

    mut frame_i = 0
    for job in $jobs { print $"  ($job.msg)" }   # reserve n lines

    while ($jobs | any {|j| not $j.done }) {
        $jobs = ($jobs | each {|job|
            if $job.done { $job } else {
                let r = (try { job recv --tag $job.id --timeout 0sec } catch { null })
                if $r == null { $job } else { {id: $job.id, msg: $job.msg, tmp: $job.tmp, done: true, result: $r} }
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
                let last_line = (try { open $job.tmp | lines | last } catch { "" } | default "")
                let prefix_len = ($job.msg | str length) + 4
                let avail = ([($width - $prefix_len) 10] | math max)
                let tail = if ($last_line | str trim | is-empty) {
                    ""
                } else {
                    let t = ($last_line | str trim)
                    let t = if ($t | str length) > $avail {
                        $"($t | str substring 0..($avail - 1))…"
                    } else {
                        $t
                    }
                    $"  (ansi white_dimmed)($t)(ansi reset)"
                }
                $"(ansi cyan_bold)($frame)(ansi reset) ($job.msg)($tail)"
            }
            print $"\r(ansi erase_line)($line)"
        }
        $frame_i += 1
        sleep $interval
    }

    for job in $jobs {
        if $verbose or $job.result.exit_code != 0 {
            let output = (try { open $job.tmp } catch { "" })
            if ($output | str trim | is-not-empty) { print $output }
        }
        rm -f $job.tmp
    }

    let failed = ($jobs | where {|j| $j.result.exit_code != 0})

    if $return {
        $jobs | select msg result
    } else if not ($failed | is-empty) {
        exit 1
    }
}
