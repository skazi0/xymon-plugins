#!/bin/bash

REDDAYS=7
YELLOWDAYS=14

# To enable starttls tests, add the "starttls=<host>:<port>:<proto>" tag to hosts.cfg.
$XYMONHOME/bin/xymongrep --noextras "starttls*" | while read ip host hash line; do
    param=$(echo "$line" | cut -d'=' -f2)
    domain=$(echo "$param" | cut -d':' -f1)
    port=$(echo "$param" | cut -d':' -f2)
    proto=$(echo "$param" | cut -d':' -f3)

    output=$(echo Q | openssl s_client -host $domain -port $port -starttls $proto 2>&1)
    res=$?

    color='clear'

    if [ $res -eq 0 ]; then
        subject=$(echo "$output" | grep subject= | cut -d= -f2-)
        issuer=$(echo "$output" | grep issuer= | cut -d= -f2-)

        cert=$(echo "$output" | sed '/--BEGIN CERTIFICATE--/,/--END CERTIFICATE--/!d' | openssl x509 -noout -text)
        startstr=$(echo "$cert" | grep 'Not Before:' | cut -d':' -f2-)
        endstr=$(echo "$cert" | grep 'Not After :' | cut -d':' -f2-)
        start=$(date -d "$startstr" +%s)
        end=$(date -d "$endstr" +%s)
        today=$(date +%s)
        daysleft=$(( ($end-$today)/(24*60*60) ))
        size=$(echo "$cert" | grep 'Public-Key:' | cut -d':' -f2)

        if [[ $daysleft -le $REDDAYS ]]; then
            color='red'
        elif [[ $daysleft -le $YELLOWDAYS ]]; then
            color='yellow'
        else
            color='green'
        fi

        output="
&$color SSL certificate for $proto://$domain:$port expires in $daysleft days

Server certificate:
        subject: $subject
        start date: $(date -u -d @$start +"%F %T %Z")
        end date: $(date -u -d @$end +"%F %T %Z")
        key size: $size
        issuer: $issuer
"
    else
        color='red'
    fi

    # send status
    ( echo "status $host.sslcert $color `date`"
      echo
      echo "$output"
    ) | bb $XYMSRV @
done
