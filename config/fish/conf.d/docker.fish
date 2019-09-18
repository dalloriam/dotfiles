function del_stopped --argument name
	set state (docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if test $state = "false"
		docker rm $name
	end
end

function elasticsearch
	del_stopped elasticsearch

	docker run --rm -d \
		--name elasticsearch \
		-p 9200:9200 \
		-p 9300:9300 \
		-e "discovery.type=single-node" \
		docker.elastic.co/elasticsearch/elasticsearch:6.2.4
end

function ubuntu
	docker run --rm -it \
		--name ubuntu \
		ubuntu
end
