#!/bin/bash
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

# Git User
if $HELP
then
    echo "This help Will Be implemented shortly."
    echo "For now, start nagging Raphael for it! :p"
    exit 0
else
	#ASK FOR YOUR GITHUB CREDENTIALS
	echo "Write your name:"
	read GIT_USER
	echo "Write your github email:"
	read email
fi
    
# Packages to install
PACKAGES=(
    ack
    autoconf
    automake
    curl
    ffmpeg
    gettext
    gifsicle
    git
    graphviz
    guake
    htop
    jq 
    lynx
    markdown
    memcached
    mercurial
    minicom
    mtr
    nmap
    npm
    pkg-config
    postgresql
    python
    python3
    pypy
    rename
    tmux
    traceroute
    tree
    tilda
    vim
    wget
    wakeonlan
    zsh
)

# Packages to install
PACKAGES_MACOS_ONLY=(
    mas
    ssh-copy-id
    terminal-notifier
    the_silver_searcher
    boot2docker
    libjpeg
)

CASKS_PACKAGES=(
    iterm2
    caffeine
    docker
    transmission
    1password
    visual-studio-code
    spotify
    dockey
    postman
    tunnelblick
)

PYTHON_PACKAGES=(
    virtualenv
    virtualenvwrapper
    ansible
    molecule
    molecule[docker]
    asn1crypto
    bcrypt
    cffi
    cryptography
    idna
    Jinja2
    MarkupSafe
    testinfra
)

# Filter by system type
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo -e "${GREEN}Begin:${NC} Run deployment as Linux system."

    # Prepare
    echo -e "${GREEN}Deployment:${NC} Update Aptitude packages."
    sudo apt update -qqq
    sudo apt-get -f install -y -qqq
    sudo apt upgrade -y -qqq

    # Divers tools
    echo -e "${GREEN}Deployment:${NC} Installing Divers Tools"
    sudo apt install ${PACKAGES[@]} -y -qqq

    #NEXT ARE FOR SSH LOGIN CONFIGURATION ON GITHUB
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo -e "${GREEN}Deployment:${NC} Create SSH Key for Git"
        ssh-keygen -t rsa -b 4096 -C $GIT_EMAIL
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa
    fi

    shopt -s expand_aliases
    alias echo="echo -e"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "${GREEN}Begin:${NC} Run deployment as Mac OS system."

    # Prepare
    if test ! $(which brew); then
        echo "${GREEN}Deployment:${NC} Installing Brew."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    # Updating Brew Packages
    echo "${GREEN}Deployment:${NC} Updating Brew packages."
    brew update
    
    # Installing MacOS Command Line Tools
    echo -e "${GREEN}Deployment:${NC} Installing MacOS Command Line Tools"
    xcode-select --install

    # Accept licences
    echo -e "${GREEN}Deployment:${NC} Accept licences"
    sudo xcodebuild -license

    # Installing GNU core utilities (those that come with OS X are outdated)
    echo -e "${GREEN}Deployment:${NC} Installing GNU core utilities"
    brew install coreutils
    brew install gnu-sed
    brew install gnu-tar
    brew install gnu-indent
    brew install gnu-which

    # Divers tools
    echo "${GREEN}Deployment:${NC} Installing Divers Tools"
    brew install ${PACKAGES[@]}

    # Cleaning up
    echo "${GREEN}Deployment:${NC} Cleaning Brew"
    brew cleanup

    # Installing Cask
    echo "${GREEN}Deployment:${NC} Installing Cask"
    brew install caskroom/cask

    # Installing Cask Apps
    echo "${GREEN}Deployment:${NC} Installing Cask Apps"
    brew cask install --force --require-sha ${CASKS_PACKAGES[@]}

    mas install 1176895641 # Spark
    mas install 441258766  # Magnet
    mas install 1295203466 # Microsoft RDP
    mas install 494803304  # Wifi Explorer
    mas install 1191449274 # Tooth Fairy
    mas install 411643860  # Daisy Disk
    mas install 803453959  # Slack
    mas install 425424353  # The Unarchiver

    #NEXT ARE FOR SSH LOGIN CONFIGURATION ON GITHUB
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "${GREEN}Deployment:${NC} Create SSH Key for Git"
        ssh-keygen -t rsa -b 4096 -C $GIT_EMAIL
        eval "$(ssh-agent -s)"
        ssh-add -K ~/.ssh/id_rsa
    fi
else
        echo "${YELLOW}Error:${NC} OS is not supported."
        exit 1
fi

# Installing Python Apps
echo "${GREEN}Deployment:${NC} Installing Python Apps"
pip install ${PYTHON_PACKAGES[@]}

# Installing Docker
echo "${GREEN}Deployment:${NC} Installing Docker"
sudo sh -c "$(curl -fsSL https://get.docker.com/)"
sudo usermod -aG docker $(whoami)


# AUTO DEPLOYMENT - CONFIG
echo "${GREEN}Deployment:${NC} Installation of dotfiles in ./dotfiles"
for f in $(ls ./dotfiles)
do
    echo "${YELLOW}Dotfile:${NC} $(echo $f )"
    if [ ! -d ./dotfiles/${f} ]; then
        cp -f ./dotfiles/${f} ~/.${f}
    fi
done

# Slack
echo -e "${GREEN}Deployment:${NC} Install Slack"
sudo snap install slack # --classic

#Discord
echo -e "${GREEN}Deployment:${NC} Install Discord"
sudo snap install discord # --classic

if $INSTALL_AUTO
then
    # AUTO DEPLOYMENT - INSTALL
    echo -e "${GREEN}Deployment:${NC} Installation of contents in ./installers."
    for f in `ls ./installers/*.sh `
    do
        if [ ! -d ${f} ]; then
            echo -e "${RED}Installation:${NC} $(echo $f | cut --delimiter='/' --fields=3 | cut --delimiter='.' --fields=1)"
            ${f}
        fi
    done
    # # AUTO DEPLOYMENT - CONFIG
    # echo -e "${GREEN}Deployment:${NC} Installation of dotfiles in ./dotfiles"
    # for f in `ls ./dotfiles`
    # do
    #     echo -e "${YELLOW}Config:${NC} $(echo $f | cut --delimiter='/' --fields=3)"
    #     if [ -d ./dotfiles/${f} ]; then
    #         mkdir -p ~/.${f}
    #         cp -f -r ./dotfiles/${f}/* ~/.${f}
    #     else
    #         cp ./dotfiles/${f} ~/.${f}
    #     fi
    # done
fi

	#MAKE SURE EVERY PACKAGE AS ITS DEPENDENCIES
sudo apt-get -f install	
source ~/.zshrc


# CONFIGURE GITHUB
echo "${GREEN}Deployment:${NC} Configure Git"
git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL

# DEPLOYIMG ZSH
echo "${GREEN}Deployment:${NC} Configure ZSH"
if [ ! -d ~/.oh-my-zsh ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    sudo chsh -s /bin/zsh $(whoami)
fi

# WALLPAPERS
echo "${GREEN}Deployment:${NC} Installing wallpapers"
cp -fr ./wallpapers/* ~/Pictures/

exec zsh
