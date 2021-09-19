#!/bin/bash

sleep 10
zcat /data/syslog.log.gz | nc -q0 test-system 9514
zcat /data/syslog.log.gz | nc -q0 test-system 9514
zcat /data/syslog.log.gz | nc -q0 test-system 9514
