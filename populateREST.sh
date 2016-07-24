#!/bin/bash
START=1

if [ -z "$1" ]; then
  END=100
else
  END=$1
fi

printf "Agrego elementos a la base KV\n\n"

for (( i=$START; i<=$END; i++ ))
do
  printf "*** Arego dato - (%s,%s) :: " "key$i" "value$i"
  curl -X POST --data "key=key$i&value=value$i" http://localhost:8888/entries
  printf "\n**** Consulto el dato agregado :: "
  curl -X GET http://localhost:8888/entries/key$i
  printf "\n\n"
done
