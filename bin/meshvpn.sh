#!/bin/vbash
# serf event handler
# configuration fullmesh vpn

IPSECCMD_TEMPLATE=/opt/vyos-serf-vpn/etc/ipsec.conf.template
IPSECCMD=/opt/vyos-serf-vpn/etc/ipsec.conf

source ./getinfo.sh

gettag()
{

  TAGNAME="$1="
  LINEBUF="$2"

  VALUE=$(echo ${LINEBUF} | awk -F ${TAGNAME} '{print $2}' | cut -d ',' -f 1)

  echo "${VALUE}"

}

setupvpn()
{

  cat ${IPSECCMD_TEMPLATE} | sed -e "s@%%DESTIP%%@$1@g" -e "s@%%NO%%@$2@g" -e "s@%%PEERIP%%@$3@g" -e "s@%%GLOBALIP%%@$4@g" -e "s@%%PREKEY%%@$5@g" -e "s@%%LOCALIP%%@$6@g" -e "s@%%LINKLOCALMY%%@$8@g" -e "s@%%LINKLOCALDEST%%@$9@g" -e "s@%%DISPNAME%%@$7@g" > ${IPSECCMD}

  source ${IPSECCMD}

}

serflinetovpn()
{

  source ./getmaxvtinum.sh

  DESTIP=$(gettag localnetwork "$1")
  NO=${VTINUM}
  PEERIP=$(gettag globalip "$1")
# GLOBALIP=
  PREKEY=$(gettag presharedkey "$1")
# LOCALIP=
  DISPNAME=$(gettag dispname "$1")

  EXIST=$(run show configuration commands | grep "${DESTIP}")
  if [ "" = "${EXIST}" ]
  then
    echo "start setup to ${DESTIP} vpn"
  else
    echo "already setup to ${DESTIP} vpn!!!"
    return 0
  fi

  echo setupvpn ${DESTIP} ${NO} ${PEERIP} ${GLOBALIP} ${PREKEY} ${LOCALIP} ${DISPNAME}
  setupvpn ${DESTIP} ${NO} ${PEERIP} ${GLOBALIP} ${PREKEY} ${LOCALIP} ${DISPNAME} $2 $3
 
}

serflinetodeletevpn()
{
  DESTIP=$(gettag localnetwork "$1")
  PEERIP=$(gettag globalip "$1")

  VTIRET=$(run show configuration commands | grep "${DESTIP}" | awk '{print $7}' | sed -e "s/'//g" | sort | uniq | tail -1)
  
  delete vpn ipsec site-to-site peer ${PEERIP}
  delete interfaces vti ${VTIRET}
  delete protocols static interface-route ${DESTIP}
  commit

}

join()
{
  RET=$(gettag localip "$1")
  echo "taglocalip=${RET} localip=${LOCALIP}"

  if [ "${RET}" = "" ]
  then
    return 0
  fi

  if [ "${RET}" = "${LOCALIP}" ]
  then
    ${SERFBIN} members | while read line
    do
      echo "members = ${line}"
      RET=$(echo "${line}" | grep "${LOCALIP}")
      if [ "${RET}" = "" ] 
      then
        serflinetovpn "${line}" 1 2
      fi
    done
  else
    serflinetovpn "${1}" 2 1
  fi

  run restart vpn

}

serfalldeletevpn()
{

  run show configuration commands | grep "SerfVPN" | grep "vti" | awk '{print $4}' | while read line
  do
    run show configuration commands | grep "interface-route" | grep ${line} | awk '{print $5}' | while read line2
    do
      echo delete protocols static interface-route ${line2}
      delete protocols static interface-route ${line2}
    done
    echo delete interfaces vti ${line} 
    delete interfaces vti ${line} 
  done
  run show configuration commands | grep "SerfVPN" | grep "site-" | awk '{print $6}' | while read line
  do
    echo delete vpn ipsec site-to-site peer ${line}
    delete vpn ipsec site-to-site peer ${line}
  done
  
  commit

}

leave()
{
  RET=$(gettag localip "$1")
  echo "taglocalip=${RET} localip=${LOCALIP}"

  if [ "${RET}" = "" ]
  then
    return 0
  fi

  if [ "${RET}" = "${LOCALIP}" ]
  then
    serfalldeletevpn
  else
    serflinetodeletevpn "${1}" 1 2
  fi

  return 0
}

concheck()
{

  ${SERFBIN} members | while read line
  do
    echo "members = ${line}"
    RET=$(echo "${line}" | grep "${LOCALIP}" | grep alive)
    if [ "${RET}" = "" ] 
    then
      TARGETIP=$(gettag localip "${line}")
      if [ "${TARGETIP}" != "" ]
      then
        LATENCY=$(/bin/ping -i 0.5 -c 3 -W 2 ${TARGETIP} | grep rtt | awk -F '/' '{print $5}')
        if [ "${LATENCY}" != "" ] 
        then
          echo "VPNSTATUS" 
          echo "VPNSTATUS ${DISPNAME} ${LOCALIP} ${TARGETIP} ${LATENCY}"
        fi
      fi
    fi
  done

}

while read line
do

  echo "serf message = ${line}"

    case ${SERF_EVENT} in
    "member-join")
      echo "serf join"
      join "${line}"
;;
    "member-leave" | "member-failed")
      echo "serf leave or failed"
      leave "${line}"
;;
    "query")
      if [ "${SERF_QUERY_NAME}" = "concheck" ]
      then
        concheck
      fi
;;
    esac

done 

exit

