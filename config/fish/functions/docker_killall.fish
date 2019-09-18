function docker_killall
	set output (docker ps -aq)
	docker stop $output > /dev/null
	docker rm $output > /dev/null
	yes | docker image prune > /dev/null
end