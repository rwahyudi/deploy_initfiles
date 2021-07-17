#!/bin/bash

# rwahyudi : script to allow SSH only from certain IP
# If you have dynamic DNS - use www.duckdns.org and consider donating
# Add script to cronjob :
# Update IP set every 15 minutes
# */15 * * * *  /root/bin/update-ipset-ssh.sh

# Need bind-utils iptables ipset 

# Provide list of hostnames
ALLOWED="home.rwahyudi.com"

# ipset list name
SET_NAME="allowed-ssh"

# SSH Port
SSHPORT="6022"

#-----------------------------------------------------------------------------------------

IPSET="/usr/sbin/ipset"
DATE="/bin/date"
IPTABLES="/usr/sbin/iptables"
DIG="/usr/bin/dig"

IP_LIST=""

TMP_NAME="$SET_NAME.$($DATE +%s)"


for CMD in $IPSET $DATE $IPTABLES $DIG
do
	command -v $CMD >/dev/null 2>&1 || { echo >&2 "I require $CMD but it's not installed.  Aborting."; exit 1; }
done


for DNSNAME in $ALLOWED
do
        # Normalise CNAME & grep the IP
        IP_LIST="$IP_LIST $($DIG +short $DNSNAME | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort)"
done

$IPSET create "$TMP_NAME" hash:net family "inet${VER/4/}"
for IP in $IP_LIST
do
    $IPSET add "$TMP_NAME" "$IP"
done

if $IPSET list "$SET_NAME" &>/dev/null
then
    $IPSET swap "$SET_NAME" "$TMP_NAME"
    $IPSET destroy "$TMP_NAME"
else
    $IPSET rename "$TMP_NAME" "$SET_NAME"
fi

# Check iptables & add iptable rules if it doesn't exist
if [ "$($IPTABLES -L -n  | grep -c "match-set $SET_NAME src" )" -lt 1 ]
then
        $IPTABLES -A INPUT -p tcp -m tcp --dport $SSHPORT -m set --match-set $SET_NAME src -j ACCEPT
fi

