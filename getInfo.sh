#!/usr/bin/env bash
#
# Description: Get hardware info
# based on the script from https://teddysun.com/444.html

clear
export myMail="ask@hpc4you.top"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
PLAIN='\033[0m'

getHardwareInfo() {
get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}


dashLine() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

machineID=$(cat /etc/machine-id)
cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
tram=$( free -g | awk '/Mem/ {print $2}' )

opsy=$( get_opsy )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
kern=$( uname -r )

dashLine
echo -e "CPU\t$cname"
echo -e "Cores\t$cores"
echo -e "Memory\t$tram GB"
echo -e "OS\t$opsy"
echo -e "Arch\t$arch ($lbit Bit)"
echo -e "Kernel\t$kern"

echo -e "ID\t${machineID}"
dashLine
echo ""
echo ""
echo -e "Disk Info:"
dashLine

for disk in `lsblk | grep ^sd | awk '{print $1}'`; do echo -e "DiskID:\t`lsblk --nodeps -no serial /dev/$disk`"; done
for disk in `lsblk | grep ^nvme | awk '{print $1}'`; do echo -e "DiskID:\t`lsblk --nodeps -no serial /dev/$disk`"; done
dashLine
}


getHardwareInfo > `hostname`-hardware.dat
fingerPrint=`md5sum *-hardware.dat`

echo ""
echo -e "I have created a file ${RED}`hostname`-hardware.dat${PLAIN} in current folder."
echo -e "Please copy and paste the following ${BLUE}blue content${PLAIN} into the body of your email..."
echo ""

# echo -e "\t |"
# echo -e "\t \u142f"
echo -e "${BLUE}The digital fingerprint information is: ${PLAIN}"
echo -e "${BLUE}${fingerPrint}${PLAIN}"
#echo -e "\t \u1431"
#echo -e "\t |"

echo ""
echo -e "Upload file (${RED}`hostname`-hardware.dat${PLAIN}) as an attachment..."
echo -e "Then, send the email to ${GREEN}${myMail}${PLAIN} to request the hpc4you_toolkit."
echo -e "The email title/subject/?????? should be ${RED}Request hpc4you toolkit${PLAIN}. "
echo ""
# echo -e "${RED}!!!Caution, do not edit the file (`hostname`-hardware.dat) on Windows!!!${PLAIN}"
# echo ""
echo -e "The full path of the file (${RED}`hostname`-hardware.dat${PLAIN}) is, "
# echo -e "${GREEN}`pwd`${PLAIN}"
# echo ""
echo -e "\t ${GREEN}`pwd`/`hostname`-hardware.dat${PLAIN}"
# ls -h `hostname`-hardware.dat
echo ""
echo -e "Transfer file(s): Linux <---> Windows PC"
echo -e "Video tutorial, ${BLUE}https://www.bilibili.com/video/BV1FN4y1T7r7${PLAIN}"
echo ""

#echo -e "By the way, this toolkit is ${RED}not free of charge${PLAIN}."
#echo ""
echo -e "${RED}hpc4you_toolkit solo${PLAIN}, for workstation,\t starts at 49 USD."
echo -e "${GREEN}hpc4you_toolkit${PLAIN}, setup HPC by yourself,\t starts at 99 USD."
echo ""
echo -e "Please contact ${GREEN}${myMail}${PLAIN} for price and discount details."
echo ""

echo -e "Remember to use your education email to apply for the discount, " 
echo -e "and mention your name and field of study. "
echo -e "This toolkit is ${RED}only free${PLAIN} if you come to my office in person to ask for it."
echo ""

echo -e "For video tutorials, go to ${BLUE}bilibili.com${PLAIN}, under user ID ${BLUE}hpc4you${PLAIN}, "
echo -e "and search for \"${RED}hpc4you toolkit${PLAIN}\". "
echo ""
echo "Good Luck."
