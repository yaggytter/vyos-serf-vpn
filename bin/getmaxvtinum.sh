#!/bin/vbash
## get max vti number from VyOS configuration
export VTIRET=$(run show configuration commands | grep "vti bind" | awk '{print $9}' | sed -e 's/vti//g' -e "s/'//g" | sort | uniq -n | tail -1)
# export VTIRET=$(cat ./ipsec* |  grep "vti bind" | awk '{print $9}' | sed -e 's/vti//g' -e "s/'//g" | sort | uniq | tail -1)

if [ "" = "${VTIRET}" ]
then
  VTIRET=0
fi

export VTINUM=$(expr ${VTIRET} + 1)

