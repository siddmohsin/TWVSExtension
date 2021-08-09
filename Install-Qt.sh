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

#Set QT Version
QT_VERSION=6.1.0


#Set Host Arch - x64 or ARM 64 
ARCH=`arch`
if [ "arm64"  == `arch` ]
then
  HOST_ARCH=ARM64
fi

if [ "x86_64"  == `arch` ]
then
  HOST_ARCH=x64
fi

DownloadQtFile() {
  OS=$1
  COMP=$2
  ARCH=$3

  echo "INFO: Downloading Qt component $COMP for $OS/$ARCH ..."
}

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


echo "INFO:Installing of Qt Completed Successfully.. "
