# CMaker
CMaker is a small docker base image to build C and C++ applications without installing the build tools on your
computer.

## Usage
Simply define a function somewhere in your shell stuff
```bash
cmaker() {
    docker  run \
    --rm -it \
    -v $PWD:/src \
    dalloriam/cmaker \
    $@
}
```

From there, you should be able to invoke cmaker directly:
```bash
cmaker g++ hello.cpp
```