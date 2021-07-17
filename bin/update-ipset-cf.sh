#!/bin/bash

# rwahyudi : script to allow WEB only from CloudFlare IPs
# Add script to cronjob :
# Update IP set every 15 minutes
# 1 1 * * *  /root/bin/update-ipset-cf.sh

# Need curl iptables ipset


WEBPORT="80,443"
IPSET="/usr/sbin/ipset"
CURL="/usr/bin/curl"
DATE="/bin/date"
IPTABLES="/usr/sbin/iptables"


for CMD in $IPSET $DATE $IPTABLES $CURL
do
	command -v $CMD >/dev/null 2>&1 || { echo >&2 "I require $CMD but it's not installed.  Aborting."; exit 1; }
done


for VER in 4; do

    URL="https://www.cloudflare.com/ips-v$VER"
    SET_NAME="cloudflare-$VER"
    TMP_NAME="$SET_NAME.$($DATE +%s)"

    IP_LIST="$($CURL -s $URL)"
    if [ ! $? ]
    then
        echo "Unable to download IPv$VER IPs list"
        exit 1
    fi

    $IPSET create "$TMP_NAME" hash:net family "inet${VER/4/}"
    for IP in $IP_LIST
    do
        $IPSET add "$TMP_NAME" "$IP"
    done

    if $IPSET list $SET_NAME &>/dev/null
    then
        $IPSET swap $SET_NAME "$TMP_NAME"
        $IPSET destroy "$TMP_NAME"
    else
        $IPSET rename "$TMP_NAME" $SET_NAME
    fi

	# Check iptables & add iptable rules if it doesn't exist
	if [ "$($IPTABLES -L -n  | grep -c "match-set $SET_NAME src" )" -lt 1 ]
	then
	        $IPTABLES -A INPUT -p tcp -m tcp --match multiport --dports $WEBPORT -m set --match-set $SET_NAME src -j ACCEPT
	fi

done

