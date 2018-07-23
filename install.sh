#!/bin/sh
BASE=$(dirname $(readlink -f $0))
ln -sf $BASE/server/ext/Hobbit.py /usr/lib/xymon/server/ext/Hobbit.py
ln -sf $BASE/server/ext/apc.sh /usr/lib/xymon/server/ext/apc.sh
ln -sf $BASE/server/ext/pfsense.sh /usr/lib/xymon/server/ext/pfsense.sh
ln -sf $BASE/server/ext/pfsense.pl /usr/lib/xymon/server/ext/pfsense.pl
ln -sf $BASE/server/ext/ipmi_trends /usr/lib/xymon/server/ext/ipmi_trends
ln -sf $BASE/server/ext/starttls.sh /usr/lib/xymon/server/ext/starttls.sh
ln -sf $BASE/server/ext/hpprinter.sh /usr/lib/xymon/server/ext/hpprinter.sh
ln -sf $BASE/server/ext/snmp-ifstat.sh /usr/lib/xymon/server/ext/snmp-ifstat.sh
ln -sf $BASE/server/ext/snmp-ifstat.pl /usr/lib/xymon/server/ext/snmp-ifstat.pl
ln -sf $BASE/server/ext/zyxel-snmp.py /usr/lib/xymon/server/ext/zyxel-snmp.py

ln -sf $BASE/client/ext/sensors /usr/lib/xymon/client/ext/sensors
ln -sf $BASE/client/ext/mysql /usr/lib/xymon/client/ext/mysql

ln -sf $BASE/tasks.d/apc.cfg /etc/xymon/tasks.d/apc.cfg
ln -sf $BASE/tasks.d/pfsense.cfg /etc/xymon/tasks.d/pfsense.cfg
ln -sf $BASE/tasks.d/ipmi_trends.cfg /etc/xymon/tasks.d/ipmi_trends.cfg
ln -sf $BASE/tasks.d/starttls.cfg /etc/xymon/tasks.d/starttls.cfg
ln -sf $BASE/tasks.d/hpprinter.cfg /etc/xymon/tasks.d/hpprinter.cfg
ln -sf $BASE/tasks.d/snmp-ifstat.cfg /etc/xymon/tasks.d/snmp-ifstat.cfg
ln -sf $BASE/tasks.d/zyxel-snmp.cfg /etc/xymon/tasks.d/zyxel-snmp.cfg

ln -sf $BASE/clientlaunch.d/sensors.cfg /etc/xymon/clientlaunch.d/sensors.cfg
ln -sf $BASE/clientlaunch.d/mysql.cfg /etc/xymon/clientlaunch.d/mysql.cfg

ln -sf $BASE/xymonserver.d/apc.cfg /etc/xymon/xymonserver.d/apc.cfg
ln -sf $BASE/xymonserver.d/smart.cfg /etc/xymon/xymonserver.d/smart.cfg
ln -sf $BASE/xymonserver.d/ipmi.cfg /etc/xymon/xymonserver.d/ipmi.cfg
ln -sf $BASE/xymonserver.d/printer.cfg /etc/xymon/xymonserver.d/printer.cfg
ln -sf $BASE/xymonserver.d/mysql.cfg /etc/xymon/xymonserver.d/mysql.cfg

ln -sf $BASE/graphs.d/apc.cfg /etc/xymon/graphs.d/apc.cfg
ln -sf $BASE/graphs.d/cpu.cfg /etc/xymon/graphs.d/cpu.cfg
ln -sf $BASE/graphs.d/memory.cfg /etc/xymon/graphs.d/memory.cfg
ln -sf $BASE/graphs.d/smart.cfg /etc/xymon/graphs.d/smart.cfg
ln -sf $BASE/graphs.d/ipmi.cfg /etc/xymon/graphs.d/ipmi.cfg
ln -sf $BASE/graphs.d/printer.cfg /etc/xymon/graphs.d/printer.cfg
ln -sf $BASE/graphs.d/mysql.cfg /etc/xymon/graphs.d/mysql.cfg

