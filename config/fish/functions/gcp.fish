function gcp --argument msg
	git commit -m $msg
	git push origin (git rev-parse --abbrev-ref HEAD)
end