#!/bin/bash
# check inter vpn connection by serf query 

while test 1
do

  serf query -timeout="20s" concheck do | grep VPNSTATUS | grep -v VPNSTATUS$ > ./serfquery.dat
  ./convserf2json.sh > /opt/serf/etc/webmonitor/meshvpn.json

  sleep 20

done

