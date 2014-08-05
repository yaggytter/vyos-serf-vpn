#!/bin/bash
# check inter vpn connection by serf query 

source /opt/vyos-serf-vpn/bin/commonvars.sh

while test 1
do

  serf query -timeout="20s" concheck do | grep VPNSTATUS | grep -v VPNSTATUS$ > ./serfquery.dat
  ./convserf2json.sh > /opt/vyos-serf-vpn/etc/webmonitor/meshvpn.json

  sleep 20

done

