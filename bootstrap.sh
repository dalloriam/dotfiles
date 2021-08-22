version=`curl -XGET https://api.github.com/repos/dalloriam/dotfiles/releases/latest | grep -o 'v.\..\..' | head -n 1`
os=`uname`
url="https://github.com/dalloriam/dotfiles/releases/download/$version/bootstrap-$os-amd64"

curl -L $url > ./.bootstrap
chmod +x ./.bootstrap
./.bootstrap all -i
rm ./.bootstrap
