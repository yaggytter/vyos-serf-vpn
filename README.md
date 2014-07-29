vyos-serf-vpn
=============

VyOS auto configuration fullmesh vpn by serf

http://www.momiage.com/vyosserf

ex. AWS

set userdata and launch ec2 vyos instance.

userdata ->
PREKEY,aaabbbPREKEY22cccddd
SERFKEY,6UIpjHbohEyOETGiuNqgNQ==
ROLE,vpngrp1
JOINIP,127.0.0.1
DISPNAME,VyOSSerf1-Tokyo
LOCALNET,10.15.0.0/16

copy all scripts to /opt/serf
and
vyos$ cd /opt/serf/bin ; ./startserfvpn.sh 

build full mesh IPSec vpn automatically across serf cluster
