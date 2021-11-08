#!/bin/bash

echo "INFO:apt update & upgrade in progress ....  "
sudo apt update && sudo apt -y upgrade  

if [ $? != 0 ]
then
	echo "ERROR: apt update & upgrade failed."
	exit -1
fi

sudo apt -y autoremove

if [ $? != 0 ]
then
	echo "ERROR: autoremove failed."
	exit -1
fi


# Build essentials
echo  "INFO:Installing build-essential .. will take some time to complete ... "
sudo apt install -y build-essential 

if [ $? != 0 ]
then
	echo "ERROR: build-essentials failed."
	exit -1
fi

 
# gdb server
echo "INFO:Installing gdbserver in progress ....  "
sudo apt install -y gdbserver  

if [ $? != 0 ]
then
	echo "ERROR: gdbserver failed."
	exit -1
fi
 
# core utilities
echo "INFO:Installing core utilities, gdb make rsync zip in progress ....  "
sudo apt install -y g++ gdb make rsync zip  

if [ $? != 0 ]
then
	echo "ERROR: core utilities failed."
	exit -1
fi


# Install open ssh server (if already installed it will tell you)
echo "INFO:Installing ssh server in progress ....  "
sudo apt install -y openssh-server  

if [ $? != 0 ]
then
	echo "ERROR: ssh server failed."
	exit -1
fi

 
# Generate an SSH key
echo "INFO:Generate an SSH key.... Enter the password  "
sudo ssh-keygen -A 

if [ $? != 0 ]
then
	echo "ERROR: ssh-keygen failed."
	exit -1
fi


sudo sed -i "s/.*PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config 
if [ $? != 0 ]
then
	echo "ERROR:sed command failed."
	exit -1
fi

sudo sed -i "s/.*PermitUserEnvironment.*/PermitUserEnvironment yes/g" /etc/ssh/sshd_config 

if [ $? != 0 ]
then
	echo "ERROR:sed command failed."
	exit -1
fi


#start ssh service 
echo "INFO:SSH service start....  "
sudo service ssh start 

if [ $? != 0 ]
then
	echo "ERROR: ssh service start failed."
	exit -1
fi


echo "INFO:Downloading and installing LLVM version 12....  "
wget https://apt.llvm.org/llvm.sh  --directory-prefix=$HOME 

if [ $? != 0 ]
then
	echo "ERROR: LLVM download failed."
	exit -1
fi

chmod +x $HOME/llvm.sh   


sudo $HOME/llvm.sh 12   ## use version 12

if [ $? != 0 ]
then
	echo "ERROR: LLVM Installtion failed."
	exit -1
fi
rm $HOME/llvm.sh

# Clang and co
echo "INFO:Installing Clang and co...  "
sudo apt install -y clang-12 clang-tools-12 clang-12-doc libclang-common-12-dev libclang-12-dev libclang1-12 clang-format-12 python3-clang-12 clangd-12 clang-tidy-12 

if [ $? != 0 ]
then
	echo "ERROR: clang 12 install failed."
	exit -1
fi

sudo apt install python3-lldb-12 -y
if [ $? != 0 ]
then
	echo "ERROR: python3-lldb-12 Installation failed."
	exit -1
fi

 
# libfuzzer
echo "INFO:Installing ibfuzzer-12-dev ...  "
sudo apt install -y libfuzzer-12-dev  

if [ $? != 0 ]
then
	echo "ERROR: ibfuzzer-12-dev failed."
	exit -1
fi

 
# lldb
echo "INFO:Installing lldb ...  "
sudo apt install -y lldb-12  

if [ $? != 0 ]
then
	echo "ERROR: lldb failed."
	exit -1
fi

 
# lld (linker)
echo "INFO:Installing lld (linker) ...  "
sudo apt install -y libc++1-12 libc++abi1-12
if [ $? != 0 ]
then
	echo "ERROR: libc++ failed."
	exit -1
fi

sudo apt install -y lld-12  

if [ $? != 0 ]
then
	echo "ERROR: lld failed."
	exit -1
fi

 
# libc++
echo "INFO:Installing libc++ ...  "
sudo apt install -y libc++-12-dev libc++abi-12-dev  

if [ $? != 0 ]
then
	echo "ERROR: libc++ failed."
	exit -1
fi

 
# OpenMP
echo "INFO:Installing OpenMP ...  "
sudo apt install -y libomp-12-dev 

if [ $? != 0 ]
then
	echo "ERROR: OpenMP failed."
	exit -1
fi

 
#Add links for clang, clang++
echo "INFO:Add links for clang, clang++  "
cd /usr/bin  
sudo ln -f clang-12 clang 

if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

sudo ln -f clang++-12 clang++

if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

sudo ln -f llvm-ar-12 llvm-ar
if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

sudo ln -f llvm-ranlib-12 llvm-ranlib
if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi
sudo ln -f lld-link-12 lld-link
if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

cd -

# Packages to support cross compilation(to be done after Clang12 installation)
echo "INFO:Installing Packages to support cross compilation..  "
sudo apt install -y gcc-aarch64-linux-gnu   

if [ $? != 0 ]
then
	echo "ERROR: cross compilation failed."
	exit -1
fi

sudo apt install -y libgcc-9-dev-arm64-cross 

if [ $? != 0 ]
then
	echo "ERROR: cross compilation failed."
	exit -1
fi

sudo apt install -y libstdc++-9-dev-arm64-cross  

if [ $? != 0 ]
then
	echo "ERROR: cross compilation failed."
	exit -1
fi



#install CMake 3.19.0
echo "INFO:Installing Latest CMake  ...  "

sudo apt remove --purge --auto-remove cmake -y
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' -y
sudo apt update -y
sudo apt install cmake -y

if [ $? != 0 ]
then
	echo "ERROR: cmake install failed."
	exit -1
fi
    
#install Ninja
echo "INFO:Installing Ninja ...  "
sudo apt install ninja-build

if [ $? != 0 ]
then
	echo "ERROR:Ninja install failed."
	exit -1
fi

mkdir -p ~/.ssh

echo "TWWorkspaceHome=~/.vs" >> ~/.ssh/environment
if [ $? != 0 ]
then
	echo "ERROR:can not write to ~/.ssh/environment."
	exit -1
fi
echo "LLVMInstallDir=/usr" >>  ~/.ssh/environment
if [ $? != 0 ]
then
	echo "ERROR:can not write to ~/.ssh/environment."
	exit -1
fi
chmod 600 ~/.ssh/environment
if [ $? != 0 ]
then
	echo "ERROR:can not change permission of ~/.ssh/environment."
	exit -1
fi

#echo "INFO:Installing Wine ...  "

#sudo apt install wine
#if [ $? != 0 ]
#then
#	echo "ERROR:Wine install failed."
#	exit -1
#fi

#sudo dpkg --add-architecture i386 && sudo apt-get update && sudo apt-get install wine32
#if [ $? != 0 ]
#then
#	echo "ERROR:Wine multiarch setting up failed."
#	exit -1
#fi

echo "INFO:Installing Qt support packages ...  "

sudo apt install zlib1g
if [ $? != 0 ]
then
	echo "ERROR:zlib1g install failed."
	exit -1
fi

sudo apt install zlib1g-dev
if [ $? != 0 ]
then
	echo "ERROR:zlib1g-dev install failed."
	exit -1
fi

sudo cp /etc/apt/sources.list /etc/apt/sources.list~
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
sudo apt-get update

sudo apt-get build-dep qt5-default libxcb-xinerama0-dev  -y
if [ $? != 0 ]
then
	echo "ERROR:failed to get packages : build-dep, qt5-default, libxcb-xinerama0-dev."
	exit -1
fi

sudo apt-get install build-essential libgl1-mesa-dev
if [ $? != 0 ]
then
	echo "ERROR:libgl1-mesa-dev install failed."
	exit -1
fi


sudo apt-get install build-essential perl python -y
if [ $? != 0 ]
then
	echo "ERROR:perl/python install failed."
	exit -1
fi

sudo apt-get install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev -y
if [ $? != 0 ]
then
	echo "ERROR:libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev install failed."
	exit -1
fi

sudo apt-get install gperf libicu-dev libxslt-dev ruby libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev libfontconfig1-dev libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev nodejs -y
if [ $? != 0 ]
then
	echo "ERROR:gperf libicu-dev libxslt-dev ruby ibxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev libfontconfig1-dev libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev nodejs install failed."
	exit -1
fi


echo "INFO:Installing flex/bison..."
sudo apt-get install flex
if [ $? != 0 ]
then
	echo "ERROR:flex install failed."
	exit -1

sudo apt-get install bison
if [ $? != 0 ]
then
	echo "ERROR:bison install failed."
	exit -1
fi

echo "INFO:Installing of Packages Completed Successfully.. "
