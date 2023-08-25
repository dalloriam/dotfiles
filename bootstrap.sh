os=`uname`

echo "=== Bootstrap ==="

if command -v apt-get &> /dev/null
then
    # We're on ubuntu/debian
    echo "Ensuring ubuntu prerequisites are installed..."

    if ! command -v fish &> /dev/null
    then
        echo "Installing fish..."
        sudo add-apt-repository ppa:fish-shell/release-3
        sudo apt-get update
        sudo apt-get install -y fish build-essential wget
    else
        echo "Fish already installed!"
    fi

    sudo apt-get install -y build-essential fish wget
    echo "Done!"
fi

if command -v pacman &> /dev/null
then
    # We're on arch
    echo "Ensuring Arch prerequisites are installed..."
    sudo pacman --noconfirm -S base-devel fish wget
    echo "Done!"
fi

# TODO: Add more mac prereqs
if [[ "$os" == 'Darwin' ]]; then
    echo "Ensuring MacOS prerequisites are installed..."
    # Setup brew
    if ! command -v brew &> /dev/null
    then
        echo "Installing brew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Brew already installed!"
    fi


    PATH=/opt/homebrew/bin:$PATH
    PATH=$(brew --prefix)/opt/llvm/bin:$PATH

    brew update
    brew install fish

    echo "Done!"
fi

echo "Handing over to setup..."
fish -c "strap/setup.fish $1"
