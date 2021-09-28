def "jd categories" [] {
    ^jd --json categories | from json
}

def "jd ls" [c: any] {
    let p = (echo $c | format {$it})
    ^jd --json ls $p | from json
}

def "jd search" [query: string] {
    ^jd --json search $query | from json | where category.id < 90
}

def "jd ssearch" [query: string] {
    ^jd --json search $query | from json
}

def "jd openrow" [] {
    each {
        ^jd open $it.id
    }
}
