function btm
    set exe (which btm)
    if type -q darkman && test (darkman get) = light
        $exe --theme default-light
    else
        $exe
    end
end
