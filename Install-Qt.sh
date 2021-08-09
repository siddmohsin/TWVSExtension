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


echo "INFO:Downloading and installing LLVM version 11....  "
wget https://apt.llvm.org/llvm.sh  --directory-prefix=$HOME 

if [ $? != 0 ]
then
	echo "ERROR: LLVM download failed."
	exit -1
fi

chmod +x $HOME/llvm.sh   
sudo $HOME/llvm.sh 11   ## use version 11

if [ $? != 0 ]
then
	echo "ERROR: LLVM Installtion failed."
	exit -1
fi
rm $HOME/llvm.sh

# Clang and co
echo "INFO:Installing Clang and co...  "
sudo apt install -y clang-11 clang-tools-11 clang-11-doc libclang-common-11-dev libclang-11-dev libclang1-11 clang-format-11 python3-clang-11 clangd-11 clang-tidy-11 

if [ $? != 0 ]
then
	echo "ERROR: clang 11 install failed."
	exit -1
fi

 
# libfuzzer
echo "INFO:Installing ibfuzzer-11-dev ...  "
sudo apt install -y libfuzzer-11-dev  

if [ $? != 0 ]
then
	echo "ERROR: ibfuzzer-11-dev failed."
	exit -1
fi

 
# lldb
echo "INFO:Installing lldb ...  "
sudo apt install -y lldb-11  

if [ $? != 0 ]
then
	echo "ERROR: lldb failed."
	exit -1
fi

 
# lld (linker)
echo "INFO:Installing lld (linker) ...  "
sudo apt install -y lld-11  

if [ $? != 0 ]
then
	echo "ERROR: lld failed."
	exit -1
fi

 
# libc++
echo "INFO:Installing libc++ ...  "
sudo apt install -y libc++-11-dev libc++abi-11-dev  

if [ $? != 0 ]
then
	echo "ERROR: libc++ failed."
	exit -1
fi

 
# OpenMP
echo "INFO:Installing OpenMP ...  "
sudo apt install -y libomp-11-dev 

if [ $? != 0 ]
then
	echo "ERROR: OpenMP failed."
	exit -1
fi

 
#Add links for clang, clang++
echo "INFO:Add links for clang, clang++  "
cd /usr/bin  
sudo ln -f clang-11 clang 

if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

sudo ln -f clang++-11 clang++

if [ $? != 0 ]
then
	echo "ERROR: link command failed."
	exit -1
fi

cd -

# Packages to support cross compilation(to be done after Clang11 installation)
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

sudo apt remove --purge --auto-remove cmake
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main'
sudo apt update
sudo apt install cmake

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

IFS='/' read -ra ADDR <<< `pwd` 
TWWorkspace=""
TWWorkspaceDrive=""
count=0
for i in "${ADDR[@]}"; do
  echo $count
  if [[ $i == "TallyWorldPMT" ]]
  then
	break
  fi

  if [ $count == 3 ]
  then
	TWWorkspaceDrive=$TWWorkspace
  fi
  if [[ $i != "" ]]
  then
  	TWWorkspace=${TWWorkspace}/$i
  fi
  ((count=count+1))
done

if [ ! -d $TWWorkspace ]
then
    echo "ERROR: Not a valid Workspace : $TWWorkspace "
	exit -1
fi

echo "TWWorkspaceHomeDrive=$TWWorkspaceDrive" > ~/.ssh/environment
if [ $? != 0 ]
then
	echo "ERROR:can not create ~/.ssh/environment."
	exit -1
fi

echo "TWWorkspaceHome=$TWWorkspace" >> ~/.ssh/environment
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

echo "INFO:Installing Wine ...  "

sudo apt install wine
if [ $? != 0 ]
then
	echo "ERROR:Wine install failed."
	exit -1
fi

sudo dpkg --add-architecture i386 && sudo apt-get update && sudo apt-get install wine32
if [ $? != 0 ]
then
	echo "ERROR:Wine multiarch setting up failed."
	exit -1
fi


echo "INFO:Installing of Packages Completed Successfully.. "
