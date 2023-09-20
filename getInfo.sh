#!/usr/bin/env bash
#
# Description: Get hardware info
# based on the script from https://teddysun.com/444.html

clear
export myMail="ask@hpc4you.top"
export weChatID="hpc4you"
export currentTime=$(date "+%Y%m%d-%H%M")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
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

if ! command -v lsblk &> /dev/null
then
    if [[ -f /etc/redhat-release ]]; then
        echo "lsblk not found. Installing on RHEL..."
        yum install util-linux -y
    elif [[ -f /etc/lsb-release ]]; then
        echo "lsblk not found. Installing on Ubuntu..."
        apt-get update
        apt-get install util-linux -y
    else
        echo "Unknown distribution. Cannot install lsblk."
        echo "Please install lsblk manually and try again."
        exit 1
    fi
fi

for disk in `lsblk | grep ^sd | awk '{print $1}'`; do echo -e "DiskID:\t`lsblk --nodeps -no serial /dev/$disk`"; done | sort | uniq
for disk in `lsblk | grep ^nvme | awk '{print $1}'`; do echo -e "DiskID:\t`lsblk --nodeps -no serial /dev/$disk`"; done | sort | uniq
dashLine
}

rm -fr hardware$$.dat &> /dev/null 
getHardwareInfo > hardware$$.dat
hardwareFile="hardware$$.dat"
fingerPrint=`md5sum hardware$$.dat`
serialNumber=`curl -k -s --upload-file ${hardwareFile} https://tophpc.top:8443 | awk -F '/' '{print $4}'`

echo ""
echo -e "
To protect your rights and ensure your eligibility for the paid hpc4you toolkit, 
please send the following blue text via WeChat/WeiXin or email."
echo ""
echo -e "${BLUE}${fingerPrint}${PLAIN}"
echo -e "${BLUE}SN: ${serialNumber}${PLAIN}"
echo ""
echo -e "- WeChat/Weixin/: ${GREEN}${weChatID}${PLAIN} "
echo -e "- Email: ${GREEN}${myMail}${PLAIN}"
echo ""
echo "Good Luck."

