#!/bin/bash/sh
#
# Requires Ubuntu distribution - This should work fine on versions 16.04 and below...	
# LAST EDIT - Fixed UFW port addition	4 months ago
#This script with setup ajenti under Ubuntu with the built-in defaults. Its just taking the install commands from http://ajenti.org/ anf modifying them for script use on my servers.
#Use
#Clone the repo and run the script (note you need to be root / sudo): 
#cd ajenti-install 
#sudo sh install.sh 



# ---------- Script checks
WhichDistAmI()
{
	# Check for Ubuntu - This should work fine on versions 16.04 and below...	
	if [ -f "/usr/bin/lsb_release" ];
	then
		ubuntuVersion=`lsb_release -s -d`

		case $ubuntuVersion in
			*"Ubuntu"*)
				OS="Ubuntu"
				export OS
			;;

			*)
				echo -e "Script is for Ubuntu OS only. Exiting."
				exit 1
			;;
		esac
	fi
}

AmIroot()
{
	# Check for root, quit if not present with a warning.
	if [ "$(id -u)" != "0" ];
	then
		echo "\nScript needs to be run as root. Please elevate and run again!"
		exit 1
	else
		echo "\nScript running as root. Starting..."
	fi
}

#---------- ajenti Function
InstallAjenti
 {
 # This will install the ajenti server monitor
 	echo "\nThis will install the ajenti server monitor using built-in defaults."
 	ajenti=$(dpkg -l | grep "ajenti" >/dev/null && echo "y" || echo "n")
 		if [ $ajenti = "n" ];
		then
			echo "\najenti is not installed. Installing now..."
			echo "\nNote port 8000 will be opened..."
			sleep 2
			# Add the repo key			
			wget http://repo.ajenti.org/debian/key -O- | sudo apt-key add -
			# Add repository to /etc/apt/sources.list: 
			echo "deb http://repo.ajenti.org/ng/debian main main ubuntu" | sudo tee -a /etc/apt/sources.list
			apt update -qq && apt install -y ajenti
			sleep 2
			# Open port 8000
			ufw allow 8000
			# Start the service
			service ajenti restart
			sleep 2
		else
			echo "\najenti is already installed..."
			sleep 1
			echo "\nActivate the 'ajenti' service and browse to https://localhost:8000"
			sleep 1
		fi
 }
 
 #----------- Run
 
# WhichDistAmI
AmIroot
InstallAjenti
 
