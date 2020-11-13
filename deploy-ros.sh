
# Ros Kinetic for Ubuntu
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo apt-get update

sudo apt-get install ros-kinetic-desktop-full

#Add to bashrc
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

#Add to zshrc
echo "source /opt/ros/kinetic/setup.zsh" >> ~/.zshrc
source ~/.zshrc

sudo apt install python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential

sudo apt install python-rosdep

sudo rosdep init
rosdep update

# Sara install first installation
# TODO: Make sure that sara_install is installed in ~/
git clone git@github.com:WalkingMachine/sara_install.git -b config/simulation_kinetic -- ~/sara_install/

source ~/sara_install/script/setup.sh

# TODO: If this doesn't exist as an alias replace it by the alias definition in ~/sara_install/script/setup.sh
INSTALL_SARA

source ~/sara_install/script/setup.sh

