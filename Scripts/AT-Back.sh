#!/bin/bash
#--------------- Description
#
# A script to chug along and grab all those pesky switch configurations.
# To use:
# 1. Load your switch IP's into a file called 'switches.txt'. Store in the same run location of this script."
# 2. Follow the prompts in the script and let the magic happen."
# 3. ????"
# 4. Profit."
#
# Josh Angel - 06/03/2018
# Version 0.4
#--------------- Variables

U='Admin' #Switch Username, change if required.
D=`date +%Y-%m-%d` #Current Date
RED=`tput setaf 1`
GREEN=`tput setaf 2`
PURPLE=`tput setaf 125`
GREY=`tput setaf 239`
NOCOLOR=`tput sgr0`

#-------------- Functions
Banner()
{
	echo "${GREEN}        _______     ____             _    ";
	echo "     /\|__   __|   |  _ \           | |   ";
	echo "    /  \  | |______| |_) | __ _  ___| | __";
	echo "   / /\ \ | |______|  _ < / _\` |/ __| |/ /";
	echo "  / ____ \| |      | |_) | (_| | (__|   < ";
	echo " /_/    \_\_|      |____/ \__,_|\___|_|\_|";
	echo " Backin' up configs... with style.";
	echo " ${RED}Version 0.4 - Josh A      ${NOCOLOR}";
	echo "-------------------------------------------"
}

ShowHelp() ## Help
{
	echo "\nA script to chug along and grab all those pesky switch configurations. "
	echo "\n8000gs only at the moment..."
	echo "\nTo use:"
	echo "1. Load your switch IP's into a file called 'switches.txt'. Store in the same run location of this script."
	echo "2. Follow the prompts in the script and let the magic happen."
	echo "3. ????"
	echo "4. Profit."
	echo ""
	echo "-------------------------------------------"
}

AmIRoot() ## Check if running as root
{
	# Check for root, quit if not present with a warning.
	if [ "$(id -u)" != "0" ];
	then
		echo "${RED}\nERROR: AT-Back needs to be run as root. Please elevate and run again!${NOCOLOR}"
		exit 1
	else
		echo "${GREEN}\nScript running as root. Starting...${NOCOLOR}"
		sleep 1
	fi
}

GetCreds() ## Prompt for Admin user password
{
	echo "\n > Getting credentials..."
	read -s -p "Please enter the password for the 'Admin' user on switches: " P
}

StartTFTP() ## Load the tftp plist and start the service. macOS only
{
  echo "\n > Starting TFTP Server..."
  sleep 2
  launchctl load -F /System/Library/LaunchDaemons/tftp.plist
  launchctl start com.apple.tftpd
}

StopTFTP() ## Unload the tftp plist and stop the service. macOS only
{
  echo "\n${NOCOLOR} > Stopping TFTP Server..."
  sleep 2
  launchctl unload -F /System/Library/LaunchDaemons/tftp.plist
  launchctl stop com.apple.tftpd
}

SetPerms() ## Add the file to the tftp server first so the switch can write to it... macOS only
{
  echo " > Setting permissions and making files..."
  sleep 2
	cat ./switches.txt |  while read switch
	do
		#If you’ll be transferring a file TO the tftp server, the file will need to exist on the server beforehand.
  	touch /private/tftpboot/$Client-$switch-$D-Running-Config
  	chmod 777 /private/tftpboot/$Client-$switch-$D-Running-Config
	done
}

Alive() ## Ping each device and check if it's alive.
{
	echo "\n > Checking IP avaliblity..."
	echo "" #Spacer
	cat ./switches.txt |  while read switch
	do
    ping -c 1 $switch > /dev/null
    if [ $? -eq 0 ]; then
			echo "${GREEN} SUCCESS:${NOCOLOR} Host $switch is Alive. Proceeding..."
			sleep 1
    else
			echo "${RED} ERROR:${NOCOLOR} Host $switch is not Alive! Try again later or check switch IP."
			exit 1
    fi
	done
}

GetOS()
{
	#Check OS and prompt for TFTP server IP as needed.
	echo "\n > Detecting OS..."
	sleep 1

	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		echo "- Linux detected... (Nice!)"
	  read -p "Please enter the IP of your TFTP device: " TFTP

	elif [[ "$OSTYPE" == "darwin"* ]]; then
		sleep 1
			echo "- macOS detected... Using built in tftp..."
		sleep 1
			IP=`ifconfig | grep inet | awk '/inet / && $2 != "127.0.0.1"{print $2}'`
			echo "Your IP is ${PURPLE}$IP${NOCOLOR}... Proceeding..."
		sleep 1
			StartTFTP
			SetPerms
	fi
	}

GetClient ()
{
	echo "\n > Enter client identifier..."
	sleep 1
  read -p "Please enter a client site identifier for the configuration(s) (e.g. MAGS): " Client
}

Complete()
{
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		echo "${GREEN}\n COMPLETE:${NOCOLOR} Script completed."
		echo " > Files saved to default DIR on ${PURPLE}$TFTP${NOCOLOR}"
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		mkdir -p ~/Desktop/SwitchBackups/$Client/$D/ #Make a new DIR for the backups.
		mv /private/tftpboot/* ~/Desktop/SwitchBackups/$Client/$D/ #Shift the backups to the new DIR.
		echo "-------------------------------------------"
		echo "${GREEN}\n COMPLETE:${NOCOLOR} Script processes complete."
		sleep 2
		echo " > Cleaning up files..."
		sleep 1
		echo " > Files moved to ${PURPLE}~/Desktop/SwitchBackups/$Client/$D/${NOCOLOR}"
		sleep 1
		echo " Have a nyan cat! "
		echo "" # Spacer
		echo "'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^          ,---/V\  ";
		echo "*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.    ~~|__(o.o) ";
		echo ".*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,*'^\`*.,     UU  UU  ";
		echo "" #Spacer
	fi
}

Main()
{
  echo " > Starting connections...${GREY}"
  sleep 2
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
	cat ./switches.txt |  while read switch
		do
  		echo "" ## Spacer
				( echo open "$switch"
  		sleep 1
				#echo ""
			#sleep 1
    		echo "$U"
  		sleep 1
    		echo "$P"
  		sleep 1
    		echo "copy run tftp://$TFTP/$Client-$switch-$D-Running-Config"
  		sleep 8
    		echo "exit") | telnet
				echo "${GREEN}\n DONE:${NOCOLOR} Backup should be stored in /YourTFTPServer/$Client-$switch-$D-Running-Config${GREY}"
		done
	elif [[ "$OSTYPE" == "darwin"* ]]; then
	cat ./switches.txt |  while read switch
		do
	  		echo "" ## Spacer
					( echo open "$switch"
	  	sleep 1
					#echo ""
				#sleep 1
	   		echo "$U"
	  	sleep 1
	   		echo "$P"
	 		sleep 1
    		echo "copy run tftp://$IP/$Client-$switch-$D-Running-Config"
			sleep 8
	    	echo "exit") | telnet
						if [ ! -f /private/tftpboot/$Client-$switch-$D-Running-Config ]; then
								echo "${RED}\n ERROR:${NOCOLOR} Something has gone wrong! Please check settings and try again.${GREY}"
							else
								echo "${GREEN}\n DONE:${NOCOLOR} Backup should be stored in /private/tftpboot/$Client-$switch-$D-Running-Config${GREY}"
						fi
	 	done
	fi
	echo " > Process complete..."
}

#-------------- Run
clear
Banner
ShowHelp
AmIRoot
GetCreds
GetClient
Alive
GetOS
Main
StopTFTP
Complete
