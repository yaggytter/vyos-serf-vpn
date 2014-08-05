#!/bin/vbash
# create serf configuration file and start serf agent 

source /opt/vyos-serf-vpn/bin/commonvars.sh

### BAD CODE
sleep 30

CONFFILE=/opt/vyos-serf-vpn/etc/meshvpn.conf

source /opt/vyatta/etc/functions/script-template

source ./getinfo.sh
source ./getmaxvtinum.sh

${SERFBIN} leave

sleep 20

### BAD CODE

SERFCMD="${SERFBIN} agent -config-file=${CONFFILE}"

CONFFILE_TEMPLATE=/opt/vyos-serf-vpn/etc/meshvpn.conf.template
echo ${PREKEY}
echo ${SERFKEY}
echo ${ROLE}
echo ${LOCALIP}
echo ${GLOBALIP}
echo ${LOCALNET}
echo ${VTINUM}
echo ${JOINIP}

cat ${CONFFILE_TEMPLATE} | sed -e "s@PREKEY@${PREKEY}@g" -e "s@SERFKEY@${SERFKEY}@g" -e "s/ROLE/${ROLE}/g" -e "s/LOCALIP/${LOCALIP}/g" -e "s/GLOBALIP/${GLOBALIP}/g" -e "s@LOCALNET@${LOCALNET}@g" -e "s/JOINIP/${JOINIP}/g" -e "s/INSTANCEID/${INSTANCEID}/g" -e "s/HOSTNAME/${HOSTNAME}/g" -e "s/DISPNAME/${DISPNAME}/g" > ${CONFFILE}

${SERFCMD} &

