# sdm_scp i-123456789:/path/to/file /path/to/file
function sdm_scp --argument src --argument dst
    scp -S/usr/local/bin/sdm -osdmSCP $src $dst
end
