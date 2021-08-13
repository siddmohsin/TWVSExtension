#!/bin/bash

echo "INFO:Installing Qt ....  "

OSName=`uname`

echo "INFO: OSName = $OSName  "


#Set QTHome based on OS
if [ "$OSName" == "Darwin" ]
then
  OS=MacOS
  QT_HOME=/Users/Shared/Qt
  echo "INFO: Installing Qt for MacOS Location : $QT_HOME ..."
fi
if [ "$OSName" == "Linux" ]
then
  OS=Linux
  QT_HOME=/usr/share/Qt
  echo "INFO: Installing Qt for Linux Location : $QT_HOME ..."
fi

sudo mkdir -p $QT_HOME
sudo chmod -R 777 $QT_HOME

#Set QT Version
QT_VERSION=6.1.0


#Set Host Arch - x64 or ARM 64 
ARCH=`arch`
if [ "arm64"  == "$ARCH" ]
then
  HOST_ARCH=ARM64
fi

if [ "x86_64"  == "$ARCH" ]
then
  HOST_ARCH=x64
fi

if [ "i386"  == "$ARCH" ]
then
  HOST_ARCH=x64
fi

if [ "$HOST_ARCH" == "" ]
then
   echo "ERROR: Could not map host cpu architecture, unknown architecture : `arch`"
   exit 1
fi

DownloadQtFile() {
  OS=$1
  COMP=$2
  ARCH=$3

  echo "INFO: Downloading Qt component $COMP for $OS/$ARCH ..."
  InstallFolder=$QT_HOME/v${QT_VERSION}.0/${OS}-${ARCH}
  ExtractFolder=$InstallFolder
    
  if [ $COMP == "Base" ]
  then
     ExtractFolder=$InstallFolder/bin
  fi
  if [ $COMP == "Includes" ]
  then
     ExtractFolder=$InstallFolder/include
  fi
  if [ $COMP == "Libs" ]
  then
     ExtractFolder=$InstallFolder/lib
  fi

  if [ -d $ExtractFolder ]
  then
    echo "INFO: Directory $ExtractFolder exists, assuming already installed, skipping ..." 
    return 0
  fi
  echo "INFO: Directory $ExtractFolder does not exist, installing ..." 
  mkdir -p $InstallFolder
  QtZip=${QT_HOME}/Qt-${COMP}-${OS}-$ARCH.zip
  QtUrl=https://github.com/TallySolutions/qt6.libs/releases/download/v${QT_VERSION}.0/Qt-${COMP}-${OS}-${ARCH}.zip 
  if [ $OS == "iOS" -a $ARCH == "x64" -a $COMP == "Libs" ]
  then
    QtZip=${QT_HOME}/Qt-${COMP}-${OS}-$ARCH.7z
    QtUrl=https://github.com/TallySolutions/qt6.libs/releases/download/v${QT_VERSION}.0/Qt-${COMP}-${OS}-${ARCH}.7z 
  fi

  curl --fail -L $QtUrl --output $QtZip

  if [ $? != 0 ]
  then
     echo "ERROR: $QtUrl : Download failed."
     exit 1
  fi

  echo "INFO: Extracting $QtZip  ..."
 
  if [ "${QtZip: -3}" == ".7z" ]
  then
	7za x  $QtZip -o${QT_HOME}/v${QT_VERSION}.0/${OS}-${ARCH}
  else
  	unzip -q -o $QtZip -d ${QT_HOME}/v${QT_VERSION}.0/${OS}-${ARCH}
  fi
  if [ $? != 0 ]
  then
     echo "ERROR: $QtZip : Zip extraction failed."
     exit 1
  fi

  rm -rf $QtZip 

}


curl --help > /dev/null 2> /dev/null

if [ $? != 0 ]
then
   echo "ERROR: 'curl' not install, run following commands to install curl:"
   if [ "$OS" == "MacOS" ]
   then
	echo
        brew --help > /dev/null 2> /dev/null
        if [ $? != 0 ]
        then
	 echo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 
	fi
	echo brew install curl
   fi
   if [ "$OS" == "Linux" ]
   then
        echo sudo apt-get install curl 
   fi
   exit 1
fi

if [ "$OS" == "MacOS" ]
then
  7za --help > /dev/null 2> /dev/null
  if [ $? != 0 ]
  then
    echo "ERROR: 'p7zip' not install, run following commands to install p7z:"
    echo
    brew --help > /dev/null 2> /dev/null
    if [ $? != 0 ]
    then
	echo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 
    fi
    echo brew install p7z
  fi
fi

#Download Base zip file
DownloadQtFile $OS "Base" $HOST_ARCH

#Download Qt libs/Includes for  both architecture

if [ "$OS" == "MacOS" ]
then
    #IF MacOS, download MacOS and iOS

    DownloadQtFile MacOS "Libs" "x64"
    DownloadQtFile MacOS "Libs" "ARM64"
    DownloadQtFile iOS "Libs" "x64"
    DownloadQtFile iOS "Libs" "ARM64"

    DownloadQtFile MacOS "Includes" "x64"
    DownloadQtFile MacOS "Includes" "ARM64"
    DownloadQtFile iOS "Includes" "x64"
    DownloadQtFile iOS "Includes" "ARM64"
fi

if [ "$OS" == "Linux" ]
then
    #IF Linux, download Linux

    DownloadQtFile "Linux" "Libs" "x64"
    DownloadQtFile "Linux" "Libs" "ARM64"

    DownloadQtFile "Linux" "Includes" "x64"
    DownloadQtFile "Linux" "Includes" "ARM64"
fi

sudo chmod -R 777 $QT_HOME

echo "INFO:Installing of Qt Completed Successfully.. "
