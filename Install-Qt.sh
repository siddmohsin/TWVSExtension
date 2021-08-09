#!/bin/bash

echo "INFO:Installing Qt ....  "

OSName=`uname -r`

#Set QTHome based on OS
$QtHOME=$env:QT_HOME

#Set OS Version
$QtVersion="6.1.0"


#Set Host Arch - x64 or ARM 64 

if ( $env:PROCESSOR_ARCHITECTURE -eq "AMD64" )
{
    $host_arch="x64"
}else{
    $host_arch="ARM64"
}


#Download Base zip file
DownloadQtFile $OS "Base" $host_arch

#Download Qt libs for  both architecture

#IF MacOS, download MacOS and iOS
DownloadQtFile MacOS "Libs" "x64"
DownloadQtFile MacOS "Libs" "ARM64"
DownloadQtFile iOS "Libs" "x64"
DownloadQtFile iOS "Libs" "ARM64"

#IF Linux, download Linux
DownloadQtFile "Linux" "Libs" "x64"
DownloadQtFile "Linux" "Libs" "ARM64"

#Download Qt uncludes for  both architecture

#IF MacOS, download MacOS and iOS
DownloadQtFile MacOS "Includes" "x64"
DownloadQtFile MacOS "Includes" "ARM64"
DownloadQtFile iOS "Includes" "x64"
DownloadQtFile iOS "Includes" "ARM64"

#IF Linux, download Linux
DownloadQtFile "Linux" "Includes" "x64"
DownloadQtFile "Linux" "Includes" "ARM64"

echo "INFO:Installing of Qt Completed Successfully.. "
