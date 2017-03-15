#!/bin/sh
BASE=$(dirname $(readlink -f $0))
ln -sf $BASE/server/ext/apc.sh /usr/lib/xymon/server/ext/apc.sh
ln -sf $BASE/server/ext/pfsense.sh /usr/lib/xymon/server/ext/pfsense.sh
ln -sf $BASE/server/ext/pfsense.pl /usr/lib/xymon/server/ext/pfsense.pl

ln -sf $BASE/client/ext/sensors /usr/lib/xymon/client/ext/sensors

ln -sf $BASE/tasks.d/apc.cfg /etc/xymon/tasks.d/apc.cfg
ln -sf $BASE/tasks.d/pfsense.cfg /etc/xymon/tasks.d/pfsense.cfg

ln -sf $BASE/clientlaunch.d/sensors.cfg /etc/xymon/clientlaunch.d/sensors.cfg

ln -sf $BASE/xymonserver.d/apc.cfg /etc/xymon/xymonserver.d/apc.cfg

ln -sf $BASE/graphs.d/apc.cfg /etc/xymon/graphs.d/apc.cfg
ln -sf $BASE/graphs.d/cpu.cfg /etc/xymon/graphs.d/cpu.cfg
ln -sf $BASE/graphs.d/memory.cfg /etc/xymon/graphs.d/memory.cfg
ln -sf $BASE/graphs.d/smart.cfg /etc/xymon/graphs.d/smart.cfg

