#!/bin/sh

# To enable pfsense tests, add the "pfsense" tag to hosts.cfg.

$XYMONHOME/bin/xymongrep --noextras "pfsense" | while read ip host hash line; do
    $XYMONHOME/ext/pfsense.pl $ip $host
done
