#!/bin/sh
BASE=$(dirname $(readlink -f $0))
ln -sf $BASE/server/ext/Hobbit.py /usr/lib/xymon/server/ext/Hobbit.py
ln -sf $BASE/server/ext/apc /usr/lib/xymon/server/ext/apc
ln -sf $BASE/server/ext/pfsense.sh /usr/lib/xymon/server/ext/pfsense.sh
ln -sf $BASE/server/ext/pfsense.pl /usr/lib/xymon/server/ext/pfsense.pl
ln -sf $BASE/server/ext/ipmi_trends /usr/lib/xymon/server/ext/ipmi_trends
ln -sf $BASE/server/ext/starttls /usr/lib/xymon/server/ext/starttls
ln -sf $BASE/server/ext/hpprinter /usr/lib/xymon/server/ext/hpprinter
ln -sf $BASE/server/ext/snmp-ifstat /usr/lib/xymon/server/ext/snmp-ifstat
ln -sf $BASE/server/ext/zyxel-snmp /usr/lib/xymon/server/ext/zyxel-snmp
ln -sf $BASE/server/ext/opnsense /usr/lib/xymon/server/ext/opnsense
ln -sf $BASE/server/ext/unifi-snmp /usr/lib/xymon/server/ext/unifi-snmp

ln -sf $BASE/client/ext/mdstat-ext /usr/lib/xymon/client/ext/mdstat-ext
ln -sf $BASE/client/ext/sensors /usr/lib/xymon/client/ext/sensors
ln -sf $BASE/client/ext/mysql /usr/lib/xymon/client/ext/mysql
ln -sf $BASE/client/ext/linux-iostat /usr/lib/xymon/client/ext/linux-iostat
ln -sf $BASE/client/ext/nginx /usr/lib/xymon/client/ext/nginx

ln -sf $BASE/tasks.d/apc.cfg /etc/xymon/tasks.d/apc.cfg
ln -sf $BASE/tasks.d/pfsense.cfg /etc/xymon/tasks.d/pfsense.cfg
ln -sf $BASE/tasks.d/ipmi_trends.cfg /etc/xymon/tasks.d/ipmi_trends.cfg
ln -sf $BASE/tasks.d/starttls.cfg /etc/xymon/tasks.d/starttls.cfg
ln -sf $BASE/tasks.d/hpprinter.cfg /etc/xymon/tasks.d/hpprinter.cfg
ln -sf $BASE/tasks.d/snmp-ifstat.cfg /etc/xymon/tasks.d/snmp-ifstat.cfg
ln -sf $BASE/tasks.d/zyxel-snmp.cfg /etc/xymon/tasks.d/zyxel-snmp.cfg
ln -sf $BASE/tasks.d/opnsense.cfg /etc/xymon/tasks.d/opnsense.cfg
ln -sf $BASE/tasks.d/unifi-snmp.cfg /etc/xymon/tasks.d/unifi-snmp.cfg

ln -sf $BASE/clientlaunch.d/mdstat-ext.cfg /etc/xymon/clientlaunch.d/mdstat-ext.cfg
ln -sf $BASE/clientlaunch.d/sensors.cfg /etc/xymon/clientlaunch.d/sensors.cfg
ln -sf $BASE/clientlaunch.d/mysql.cfg /etc/xymon/clientlaunch.d/mysql.cfg
ln -sf $BASE/clientlaunch.d/linux-iostat.cfg /etc/xymon/clientlaunch.d/linux-iostat.cfg
ln -sf $BASE/clientlaunch.d/nginx.cfg /etc/xymon/clientlaunch.d/nginx.cfg

ln -sf $BASE/xymonserver.d/apc.cfg /etc/xymon/xymonserver.d/apc.cfg
ln -sf $BASE/xymonserver.d/smart.cfg /etc/xymon/xymonserver.d/smart.cfg
ln -sf $BASE/xymonserver.d/ipmi.cfg /etc/xymon/xymonserver.d/ipmi.cfg
ln -sf $BASE/xymonserver.d/hpprinter.cfg /etc/xymon/xymonserver.d/hpprinter.cfg
ln -sf $BASE/xymonserver.d/mysql.cfg /etc/xymon/xymonserver.d/mysql.cfg
ln -sf $BASE/xymonserver.d/temp_multigraph.cfg /etc/xymon/xymonserver.d/temp_multigraph.cfg
ln -sf $BASE/xymonserver.d/linux-iostat.cfg /etc/xymon/xymonserver.d/linux-iostat.cfg
ln -sf $BASE/xymonserver.d/nginx.cfg /etc/xymon/xymonserver.d/nginx.cfg

ln -sf $BASE/graphs.d/apc.cfg /etc/xymon/graphs.d/apc.cfg
ln -sf $BASE/graphs.d/cpu.cfg /etc/xymon/graphs.d/cpu.cfg
ln -sf $BASE/graphs.d/memory.cfg /etc/xymon/graphs.d/memory.cfg
ln -sf $BASE/graphs.d/smart.cfg /etc/xymon/graphs.d/smart.cfg
ln -sf $BASE/graphs.d/ipmi.cfg /etc/xymon/graphs.d/ipmi.cfg
ln -sf $BASE/graphs.d/hpprinter.cfg /etc/xymon/graphs.d/hpprinter.cfg
ln -sf $BASE/graphs.d/mysql.cfg /etc/xymon/graphs.d/mysql.cfg
ln -sf $BASE/graphs.d/voltage.cfg /etc/xymon/graphs.d/voltage.cfg
ln -sf $BASE/graphs.d/fanrpm.cfg /etc/xymon/graphs.d/fanrpm.cfg
ln -sf $BASE/graphs.d/linux-iostat.cfg /etc/xymon/graphs.d/linux-iostat.cfg
ln -sf $BASE/graphs.d/nginx.cfg /etc/xymon/graphs.d/nginx.cfg

