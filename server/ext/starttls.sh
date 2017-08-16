#!/bin/bash

REDDAYS=7
YELLOWDAYS=14

# To enable starttls tests, add the "starttls=<host>:<port>:<proto>[,<host>:<port>:<proto>]" tag to hosts.cfg.
$XYMONHOME/bin/xymongrep --noextras "starttls*" | while read ip host hash line; do
    param=$(echo "$line" | cut -d'=' -f2)

    color='clear'
    statusout=''

    for stest in $(echo "$param" | tr ',' ' '); do
        addr=$(echo "$stest" | cut -d':' -f1-2)
        proto=$(echo "$stest" | cut -d':' -f3)

        output=$(echo Q | openssl s_client -connect $addr -starttls $proto 2>&1)
        res=$?

        scolor='clear'

        if [ $res -eq 0 ]; then
            subject=$(echo "$output" | grep subject= | cut -d= -f2-)
            issuer=$(echo "$output" | grep issuer= | cut -d= -f2-)

            cert=$(echo "$output" | sed '/--BEGIN CERTIFICATE--/,/--END CERTIFICATE--/!d' | openssl x509 -noout -text)
            startstr=$(echo "$cert" | grep 'Not Before:' | cut -d':' -f2-)
            endstr=$(echo "$cert" | grep 'Not After :' | cut -d':' -f2-)
            start=$(date -d "$startstr" +%s)
            end=$(date -d "$endstr" +%s)
            today=$(date +%s)
            daysleft=$(( ($end-$today)/(24*60*60)+1 ))
            size=$(echo "$cert" | grep 'Public-Key:' | cut -d':' -f2)

            if [[ $daysleft -le $REDDAYS ]]; then
                scolor='red'
            elif [[ $daysleft -le $YELLOWDAYS ]]; then
                scolor='yellow'
            else
                scolor='green'
            fi

            statusout="$statusout
&$scolor SSL certificate for $proto://$addr expires in $daysleft days

Server certificate:
        subject: $subject
        start date: $(date -u -d @$start +"%F %T %Z")
        end date: $(date -u -d @$end +"%F %T %Z")
        key size: $size
        issuer: $issuer

"
        else
            scolor='red'
            statusout="$statusout
$output

"
        fi

        # global color
        if [[ $color == 'clear' || $scolor == 'red' || $color != 'red' && $scolor == 'yellow' ]]; then
            color=$scolor
        fi
    done

    # send status
    ( echo "status $host.sslcert $color `date`"
      echo
      echo "$statusout"
    ) | bb $XYMSRV @
done
