#!/bin/sh

# To enable snmp host resources tests, add the "snmp-ifstat" tag to hosts.cfg.

$XYMONHOME/bin/xymongrep --noextras "snmp-ifstat" | cut -d' ' -f1,2 | while read ip host; do
    $XYMONHOME/ext/snmp-ifstat.pl $ip $host
done
