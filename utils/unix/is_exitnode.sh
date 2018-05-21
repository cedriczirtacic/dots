#!/bin/bash
# checks if IP is a TOR exit node
if [ -z $1 ];then
    echo "usage: $0 <ipaddr>" 1>&2
    exit 1;
fi

IPADDR=$1
grep -E "ExitAddress $IPADDR\s" \
    <(curl -s -A "checkTor" https://check.torproject.org/exit-addresses)

if [ $? -gt 0 ];then
    echo "Address not found."
    exit 1;
fi

exit 0
