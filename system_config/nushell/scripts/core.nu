def bin-exists [name:string] {
  (which $name | length) == 1
}

def read-export [name:string] {
    cat $name | gzip -d | from json --objects
}
