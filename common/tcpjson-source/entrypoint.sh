#!/bin/bash

PORT=10070 

echo "waiting for test-system to launch and open up port: $PORT"
while ! nc -z test-system $PORT; do   
  sleep 1 # wait for 1 second before check again
done

echo "test-system launched, port $PORT is now accessible ..."

cd /opt/gogen
./gogen -c ./configs/weblog.yml -ot json gen -c 1000 -ei 10000 -i 1 | nc -q0 test-system $PORT
