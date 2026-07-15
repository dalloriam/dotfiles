export def killall [] {
    let ids = (^docker ps -aq | lines | str trim | where { |it| $it != "" })
    if ($ids | is-not-empty) {
        $ids | each { |id| ^docker stop $id | ignore }
        $ids | each { |id| ^docker rm $id | ignore }
    }
    ^docker image prune -a -f | ignore
}
