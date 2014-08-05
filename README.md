vyos-serf-vpn
=============

VyOS auto configuration fullmesh vpn by serf

http://www.momiage.com/vyosserf

ex. AWS

set userdata and launch vyos ec2 instance.

userdata ->
<pre>
PREKEY,aaabbbPREKEY22cccddd
SERFKEY,6UIpjHbohEyOETGiuNqgNQ==
ROLE,vpngrp1
JOINIP,127.0.0.1
DISPNAME,VyOSSerf1-Tokyo
LOCALNET,10.15.0.0/16
</pre>

copy all scripts to /opt/vyos-serf-vpn
<pre>
vyos$ cd /opt ; git clone https://github.com/yaggytter/vyos-serf-vpn.git
</pre>
and
<pre>
vyos$ cd /opt/vyos-serf-vpn/bin ; ./startserfvpn.sh 
</pre>

build full mesh IPSec vpn automatically across serf cluster
