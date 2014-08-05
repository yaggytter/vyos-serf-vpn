#!/bin/bash

source /opt/vyos-serf-vpn/bin/commonvars.sh

sudo yum install git

cd /opt
git clone https://github.com/yaggytter/vyos-serf-vpn.git

cd /opt/vyos-serf-vpn
git pull
 
