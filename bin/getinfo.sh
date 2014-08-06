#!/bin/vbash
## get vpn variables

source ./commonvars.sh

DEBUG="$2"

export INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export HOSTNAME=$(hostname)

## get other variables from aws user data 
if [ "${DEBUG}" = "" ] 
then
  AWSUSERDATACMD="curl http://169.254.169.254/latest/user-data"
else
  AWSUSERDATACMD="cat ./testuserdata"
fi

while read LINE
do
  echo "AWS user data = ${LINE}"
  CMD=$(echo ${LINE} | awk -F ',' '{print "export " $1 "=" $2;}')
#  echo ${CMD}
  ${CMD}
done <<__EOC__
  $(${AWSUSERDATACMD})
__EOC__

## get local ip from local interface eth0
export LOCALIP=$(run show interfaces | grep eth0 | awk '{print $2}' | awk -F '/' '{print $1}')
echo "LOCALIP = ${LOCALIP}"

## get local network address from eth0
if [ "${LOCALNET}" = "" ]
then
  export LOCALNET=$(run show ip route connected | grep eth0 | awk '{print $2}')
fi
echo "LOCALNET = ${LOCALNET}"

## get global ip from aws meta data
if [ "${DEBUG}" = "" ] 
then
  export GLOBALIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
else
  export GLOBALIP="10.10.10.10"
fi
echo "GLOBALIP = ${GLOBALIP}"

## get display name by hostname command
if [ "${DISPNAME}" = "" ]
then
  export DISPNAME="${HOSTNAME}"
fi

