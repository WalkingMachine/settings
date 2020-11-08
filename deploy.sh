#!/bin/bash
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
NC='\033[0m' # No Color

# Git User
	#ASK FOR YOUR GITHUB CREDENTIALS
	echo "Write your name:"
	read GIT_USER
	echo "Write your github email:"
	read GIT_EMAIL
    
# Packages to install
PACKAGES=(
    ack
    autoconf
    automake
    curl
    ffmpeg
    gettext
    gifsicle
    #git
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

    #Install git
    sudo apt install git -y 

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

#exec zsh
