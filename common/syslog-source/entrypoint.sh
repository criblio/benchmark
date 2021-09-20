#!/bin/bash

PORT=9514 

echo "waiting for test-system to launch and open up port: $PORT"
while ! nc -z test-system $PORT; do   
  sleep 1 # wait for 1 second before check again
done

echo "test-system launched, port $PORT is now accessible ..."

zcat /data/syslog.log.gz | nc -q0 test-system $PORT
zcat /data/syslog.log.gz | nc -q0 test-system $PORT
zcat /data/syslog.log.gz | nc -q0 test-system $PORT
