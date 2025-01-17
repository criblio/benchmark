#!/bin/bash


function clean_bench(){
  docker-compose down -v
}

function run_bench() {
  docker-compose up --build -d 1>&2
  SRC_CONTAINER=$(docker-compose ps --no-trunc -q source)

  echo waiting for source container to exit $SRC_CONTAINER 1>&2
  docker wait $SRC_CONTAINER 1>&2

  TEST_CONTAINER=$(docker-compose ps --no-trunc -q test-system)
  CPU_SECS=$(cat /sys/fs/cgroup/system.slice/docker-$TEST_CONTAINER.scope/cpu.stat | grep 'usage_usec' | awk '{print $2}')
  MEM_USAGE=$(cat /sys/fs/cgroup/system.slice/docker-$TEST_CONTAINER.scope/memory.current)

  echo "$CPU_SECS,$MEM_USAGE"
}

CRIBL_VERSION="4.8.2"
VECTOR_VERSION="0.41.1"
FLUENTBIT_VERSION="3.1.7"
# SPLUNK_VERSION="9.3.1"
SYSLOGNG_VERSION="4.7.1"
LOGSTASH_VERSION="8.15.1"
export CRIBL_VERSION
export VECTOR_VERSION
export FLUENTBIT_VERSION
# export SPLUNK_VERSION
export SYSLOGNG_VERSION
export LOGSTASH_VERSION

RESULT_DIR="results/$(date +"%Y%m%dT%H%M%S")/"
RESULT_FILE="${RESULT_DIR}/results.csv"
mkdir -p $RESULT_DIR


echo "Stream: ${CRIBL_VERSION}"     >> $RESULT_DIR/versions.txt
echo "Vector: ${VECTOR_VERSION}"       >> $RESULT_DIR/versions.txt
echo "FluentBit: ${FLUENTBIT_VERSION}" >> $RESULT_DIR/versions.txt
# echo "Splunk: ${SPLUNK_VERSION}"        >> $RESULT_DIR/versions.txt
echo "LogStash: ${LOGSTASH_VERSION}"  >> $RESULT_DIR/versions.txt
echo "Syslog-ng: ${SYSLOGNG_VERSION}"  >> $RESULT_DIR/versions.txt


cat /proc/cpuinfo > $RESULT_DIR/cpuinfo
cat /proc/meinfo  > $RESULT_DIR/meminfo
uname -a          > $RESULT_DIR/uname

echo "Results path=${RESULT_FILE}"
echo "DIR,CPU_TIME,MEM_RSS" > $RESULT_FILE

if [ -z "$1" ] 
then
   files=$(find cases/ -name docker-compose.yml | grep -v splunk | sort -t/ -k3,3 -k2,2 )
else 
   files=$(find cases/ -name docker-compose.yml | grep -v splunk | grep $1 | sort -t/ -k3,3 -k2,2 )
fi

# find and run all the tests, order by the system being tested (smoothen out docker pulls)
for file in $files
do
  DIR=$(dirname $file)
  echo -e "\n\nEntering $DIR ..." 1>&2
  cd $DIR
  RUN_STATS=$(run_bench)
  clean_bench
  cd -
  echo "${DIR#cases/},$RUN_STATS" >> $RESULT_FILE
  RESULTS="$RESULTS\n$DIR,$RUN_STATS"
done

echo -e "\n\n######## RESULTS ###########"
cat $RESULT_FILE

