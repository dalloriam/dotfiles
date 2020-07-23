function del_stopped --argument name
	set state (docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if test $state = "false"
		docker rm $name
	end
end

function relies_on --argument name
	set state (docker inspect --format "{{.State.Running}}" $name 2>/dev/null)

	if test $state = "false" -o $state = ""
		echo "$name" is not running, starting it for you
		$name
		sleep 2
	end
end

function traefik
	docker container run --rm -d --name traefik \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		-p 80:80 \
		-p 8080:8080 \
		traefik --api.insecure=true --providers.docker
end

function server --argument directory
	relies_on traefik

    docker run --rm \
    	-v (realpath $directory):/usr/share/nginx/html \
        -p "9998:80" \
        --label "traefik.http.routers.nginx.rule=Host(`web.stk`)" \
        --label traefik.port=9998 \
        nginx
end

function browse --argument directory
	relies_on traefik

	docker run --rm \
		-v (realpath $directory):/shared \
		-p 8001:8001 \
		--label "traefik.http.routers.browse.rule=Host(`file.stk`)" \
		--label traefik.port=8001 \
		pldubouilh/gossa
end

function sourcegraph
	relies_on traefik

	docker run --rm -d \
		--name sourcegraph \
	    -v ~/.devstack/sourcegraph/config:/etc/sourcegraph \
	    -v ~/.ssh:/etc/sourcegraph/ssh \
	    -v ~/.devstack/sourcegraph/data:/var/opt/sourcegraph \
	    -p "7080:7080" \
	    --label "traefik.http.routers.sourcegraph.rule=Host(`sourcegraph.stk`)" \
	    --label traefik.port=7080 \
    	sourcegraph/server:3.13.0
end

function elasticsearch
	relies_on traefik
	docker run --rm -d \
		--name elasticsearch \
		-p 9200:9200 \
		-p 9300:9300 \
		-e "discovery.type=single-node" \
		--label "traefik.http.routers.elasticsearch.rule=Host(`elastic.stk`)" \
		--label "traefik.port=9200" \
		docker.elastic.co/elasticsearch/elasticsearch:6.2.4
end

function ubuntu
	docker run --rm -it \
		--name ubuntu \
		ubuntu
end

function cppdep
	docker run --rm -it \
		--name cppdep \
		-v (realpath $PWD):/workspace \
		dalloriam/cppdep:latest $argv
end
