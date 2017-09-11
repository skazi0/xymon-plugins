#!/bin/bash

# To enable hpprinter tests, add the "hpprinter" tag to hosts.cfg.
$XYMONHOME/bin/xymongrep --noextras "hpprinter" | while read ip host hash line; do
    color='clear'

    output=$(snmpwalk -v1 -cpublic $host 1 2>&1)
    res=$?

    if [ $res -eq 0 ]; then
        rawout="$output"
        pages=$(echo "$rawout" | grep pages)
        counts=$(echo "$rawout" | grep count)
        life=$(echo "$rawout" | grep life)
        energy=$(echo "$rawout" | grep energy)
        output="$pages
$counts
$life
$energy"
        # cleanup
        output=$(echo "$output" | grep INTEGER | cut -d: -f3- | sed -r 's/.0\s*=\s*INTEGER//' | sort -u)
        # TODO: tresholds and colors?
        color='green'
    else
        color='red'
    fi

    # send status
    ( echo "status $host.printer $color `date`"
      echo
      echo "$output"
    ) | bb $XYMSRV @
done
