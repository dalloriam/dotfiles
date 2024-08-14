# sdm_scp i-120391203:/path/to/file /path/to/file
function sdm_scp --argument src --argument dst
    scp -S'/usr/local/bin/sdm' -osdmSCP $src $dst
end
