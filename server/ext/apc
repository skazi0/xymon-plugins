#!/bin/sh

# To enable apc tests, add the "apc" tag to hosts.cfg.

$XYMONHOME/bin/xymongrep --noextras "apc" | while read ip host hash line; do
    output=$(/sbin/apcaccess)
    res=$?

    status=$(echo "$output" | grep STATUS | cut -d: -f2 | sed -r 's/^\s+|\s+$//g')

    color='red'
    if [ "$status" = 'ONLINE' ]; then
        color='green'
    fi

    # send status
    ( echo "status $host.apc $color $(LANG=C date) $status"
      echo
      echo "$output"
    ) | $XYMON $XYMSRV @
done
