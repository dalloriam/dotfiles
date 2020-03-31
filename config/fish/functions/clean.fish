function clean --argument a
	cat $a | jq . >> temp.json
	mv temp.json $a
end
