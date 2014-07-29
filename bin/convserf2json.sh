#!/bin/bash
# sample
# convert serf query response to json

SX=30
SY=30
GROUP=1

QUERYFILE=./serfquery.dat
TMPQUERYFILE=./serfquery.dat.tmp

echo '{'
echo '  "nodes":['

cp  -f ${QUERYFILE} ${TMPQUERYFILE}
cat ${QUERYFILE} | grep VPNSTATUS | awk '{print $2 " " $3}' | sort | uniq | while read line
do
  
#  RET=$(echo "${line}" | grep from) 
#  if [ "${RET}" = "" ]
#  then

    if [ ${GROUP} -ne 1 ]
    then
      echo ","
    fi
    echo '{"name":"'${line}'", "group":'${GROUP}', "sx":'${SX}', "sy":'${SY}'}'
  
    INDEXNO=$(expr ${GROUP} - 1)
    IP=$(echo ${line} | awk '{print $2}')
    
    cat ${TMPQUERYFILE} | sed "s@${IP}@${INDEXNO}@g" > ${TMPQUERYFILE}.tmp
    cp  -f ${TMPQUERYFILE}.tmp ${TMPQUERYFILE}
  
    SY=$(expr ${SY} + 30)
    GROUP=$(expr ${GROUP} + 1)

#  fi

done


echo '  ],'
echo '  "links":['

GROUP=1
cat ${TMPQUERYFILE} | awk '{print $3 " " $4 " " $5}' | sed "s@\.@ @g" | sort -g -r -k 3 | uniq | while read line
do

#  RET=$(echo "${line}" | grep VPNSTATUS) 
#  if [ "${RET}" = "" ]
#  then

    if [ ${GROUP} -ne 1 ]
    then
      echo ","
    fi
  
    SOURCE=$(echo ${line} | awk '{print $1}')
    TARGET=$(echo ${line} | awk '{print $2}')
    VALUE=$(echo ${line} | awk '{print $3}')
    echo '{"source":'${SOURCE}',"target":'${TARGET}',"value":'${VALUE}'}'
  
    GROUP=$(expr ${GROUP} + 1)

#  fi

done

echo '  ]'
echo '}'

rm -f ${TMPQUERYFILE}

