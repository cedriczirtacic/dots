#!/bin/bash
# based on https://gist.github.com/glennzw/8c6b84849d078b9c33f0a040a4973f12
# use nohup
AIRPORT=/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport
RECONDB=/tmp/new_wifi_clients.txt
RESOLVEHW=true

case $RESOLVEHW in
    true)
        ETH="eth.addr_resolved"
        ;;
    false)
        ETH="eth.addr"
        ;;
esac

tshark -Q -l -i en0 -Y "bootp.option.type == 53" -T fields -e bootp.option.hostname -e $ETH -E occurrence=l -E separator=, \
| grep --line-buffered -v '^,' | sed -l "s/,/ (/; s/$/)/" \
| while IFS= read -r l; do
    [ ! -e "$RECONDB" ] && touch $RECONDB;
    if ! grep -q -o "$l" $RECONDB;then
        echo "$l" >> $RECONDB;
    fi
    SSID=$( $AIRPORT -I | grep -E '^\s*SSID:' |sed -E 's/[^:]+: (.*)$/\1/' )
    terminal-notifier -ignoreDnD -appIcon https://i.imgur.com/LSVs3i3.png -title "New Device joined ${SSID}" -message "$l" > /dev/null
done
