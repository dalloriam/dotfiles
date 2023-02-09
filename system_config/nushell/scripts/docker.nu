def "docker killall" [] {
    let output = (docker ps -aq)
    docker stop $output | ignore
    docker rm $output | ignore
    yes | docker image prune | ignore
}
