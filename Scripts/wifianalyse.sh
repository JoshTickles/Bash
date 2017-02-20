#!/bin/bash
# Copyright 2016 Rumesh Sudhaharan - Modded for personal use - Josh
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#####   
#     About
#
#     wifianalyse is a simple bash script that allows you to get the signal level, 
#     link quality and ping time of your device connected to a network. This script was tested on a Raspberry Pi 
#     running raspbian and a laptop running Ubuntu 16.04.
#
#     Usage
#
#     Using the script is very simple. just open a terminal cd to the directoryu containing the script
#     and run ./wifianalyse. if you to run the script from anywhere place the script in /usr/local/bin folder.
#     You will be asked to enter the inerface name and ip addresss of your router when you run the script. 
#     This information is vital to the running of the script so please enter the correct information. 
#     The interface name can be found by running iwconfig.
#
#    Tips
#
#     Move the wifianalyse script to /usr/local/bin/ to be able to run the script from anywhere. 
#     If the file is not executable, run chmod +x wifianalyseto make it an executable.
#####

echo "Please enter the wireless interface you wish to use - you can use iwconfig to check."
read -e wifiinterface
echo "Please enter the routers ip address(or any system you wish to ping)"
read -e pingaddress

count=0
echo "Interface: $wifiinterface    Ping Address: $pingaddress" >> ~/wifianalyse.log
echo "        Time           Count                    Output                              Ping"
echo "        Time           Count                    Output                              Ping" >> ~/wifianalyse.log
while [ 1 -eq 1 ]
do
	sleep 1
	count=$((count + 1))
	countf=$(printf "%05s" $count)
	wifioutput=$(iwconfig $wifiinterface | grep -i --color quality)
	pingoutput=$(ping -c 1 $pingaddress | grep -E -o -m 1 'time.{0,10}' & )
	curtime=$(date +%d/%m/%y\ %H:%M:%S)
	echo [$curtime] "| " "$countf""  |  " $wifioutput " |   " $pingoutput
	echo [$curtime] "| " "$countf""  |  " $wifioutput " |   " $pingoutput >> ~/wifianalyse.log
done
