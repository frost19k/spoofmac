#!/usr/bin/env bash

###>> Intel Corporate MAC Addresses
##> https://mac.lc/company/intel-corporate
wlpids=(
    "f8:16:54"
    "80:9b:20"
    "14:ab:c5"
    "0c:dd:24"
    "e4:f8:9c"
)

###>> Generate NIC identifier
nicid=$(openssl rand -hex 3 | fold -w 2 | tr '\n' ':' | sed 's/\:$//')

###>> Select a random OUI prefix
##> Old method (unreliable)
# randint=$(date +%s)
# prefix=${wlpids[${randint} % ${#wlpids[@]}]}
idx=$( shuf -n 1 -i 0-$(( ${#wlpids[@]} - 1 )) )
prefix=${wlpids[idx]}

###>> Genreate full MAC Address
mac="${prefix}:${nicid}"

###>> Get device name
[[ -z ${device} ]] && device=$1
##> Comment out the lines below is autodetect fails
##> and modify 'ExecStart=' in spoofmac.service accordingly...
device=$(lshw -class network -json 2>/dev/null | jq -r '.[] | select( (.description|ascii_downcase) | contains("wireless") ) | .logicalname')
(( $(grep -c . <<<${device}) > 1 )) && echo "Invalid device name '${device}'"


###>> Spoof the Mac Address
echo -e "Setting ${device} MAC Address to ${mac}"
ip link set dev ${device} down
ip link set dev ${device} address ${mac}
ip link set dev ${device} up

exit 0
