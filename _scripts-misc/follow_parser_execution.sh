#!/bin/bash
while true; do clear; t=0; r=0; for i in _results/201809/2018092[3,8]*_5; do r=$(ls $i/*.csv|wc -l); t=$(($t+$r)); echo $i $r $(($r*100/2048))%; done; ssh wsilva@eslsrv13 'cd /files/seri/esl.lapps; for j in _results/201809/2018092[5,7]*_5; do r=$(ls $j/*.csv|wc -l); t=$(($t+r)); echo $j $r $(($r*100/2048))%; done'; sleep 10; done

