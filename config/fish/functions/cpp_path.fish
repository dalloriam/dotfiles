function cpp_path --argument source_file --argument header_file
    cppdep --infer \
           --recursive \
           --includeorigin \
           $source_file $header_file
end
