#!/bin/ash
# Installation script by Aulian

DIR=/usr/bin

finish(){
clear
        echo ""
        echo "INSTALL SUCCESSFULLY ;)"
        echo ""
}
download_files()
{
        clear
        echo "Downloading files from repo watchpingloop..."
        wget -O $DIR/watchpingloop.sh https://raw.githubusercontent.com/ElysianWhirl/watchpingloop/main/watchpingloop.sh && chmod +x $DIR/watchpingloop.sh
        finish
}

echo ""
echo "Install Script code from repo Aulian."

while true; do
    read -p "This will download the files into $DIR. Do you want to continue (y/n)? " yn
    case $yn in
        [Yy]* ) download_files; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer 'y' or 'n'.";;
    esac
done
