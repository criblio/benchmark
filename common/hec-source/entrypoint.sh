#!/bin/bash

PORT=8088 

echo "waiting for test-system to launch and open up port: $PORT"
while ! nc -z test-system $PORT; do   
  sleep 1 # wait for 1 second before check again
done

echo "test-system launched, port $PORT is now accessible ..."


GOGEN_HEC_TOKEN=11111111-2222-3333-4444-555555555555
export GOGEN_HEC_TOKEN

cd /opt/gogen
./gogen -c ./configs/weblog.yml -v -o http -ot splunkhec --url http://test-system:$PORT/services/collector/event gen -c 1000 -ei 10000 -i 1 
