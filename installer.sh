#!/bin/bash
function Install(){
echo -e "\033[01;32mInstalling . . . . . . . . "
gcc -O2 -Wall -o hamachid-patcher.so -shared hamachid-patcher.c
gcc -O2 -Wall -o hamachid hamachid.c
sudo mv /opt/logmein-hamachi/bin/hamachid /opt/logmein-hamachi/bin/hamachid.org
sudo cp hamachid-patcher.so /opt/logmein-hamachi/bin/
sudo cp hamachid /opt/logmein-hamachi/bin/
sudo /etc/init.d/logmein-hamachi stop
sudo /etc/init.d/logmein-hamachi start
exit;
}

function Uninstall(){
echo -e "\033[01;31mUninstalling . . . . . . . . "
sudo rm  /opt/logmein-hamachi/bin/hamachid
sudo rm /opt/logmein-hamachi/bin/hamachid.org 
arc=$(getconf LONG_BIT)
if (( $arc == 64 ))
then
wget -O logmein-hamachi_2.1.0.203-1_amd64.deb https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_amd64.deb
sudo dpkg -i logmein-hamachi_2.1.0.203-1_amd64.deb
else
wget -O logmein-hamachi_2.1.0.203-1_i386.deb https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_i386.deb
sudo dpkg -i logmein-hamachi_2.1.0.203-1_i386.deb
fi

exit;
 
}


echo -e "\033[01;31m===================================================================================="
echo -e "|                          \033[01;32m hamachi crash fix by ejtagle \033[01;31m                          |"
echo -e "|      \033[01;32m https://github.com/ejtagle/hamachi-fix-ubuntu20.04-or-newer \033[01;31m               |"

echo -e "====================================================================================\033[01;37m"
echo "                              select option by number:"
echo "1) Install"
echo "2) Uninstall"
echo "3) Quit"
read opcao
case $opcao in
        "1")
            Install
            ;;
        "2")
            Uninstall
            ;;
        "3")
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
