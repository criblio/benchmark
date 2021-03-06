#!/bin/bash


function clean_bench(){
  docker-compose down -v
}

function run_bench() {
  docker-compose up --build -d 1>&2
  SRC_CONTAINER=$(docker-compose ps -q source)

  echo waiting for source container to exit $SRC_CONTAINER 1>&2
  docker wait $SRC_CONTAINER 1>&2

  TEST_CONTAINER=$(docker-compose ps -q test-system)
  CPU_SECS=$(cat /sys/fs/cgroup/cpu/docker/$TEST_CONTAINER/cpuacct.stat | awk '{ sum += $2 } END { print sum/100 }')
  MEM_RSS=$(cat /sys/fs/cgroup/memory/docker/$TEST_CONTAINER/memory.stat | grep '^rss ' | awk '{print $2}')

  echo "$CPU_SECS,$MEM_RSS"
}

CRIBL_VERSION="3.5.0-RC0"
VECTOR_VERSION="0.22.2"
FLUENTBIT_VERSION="1.9.5"
SPLUNK_VERSION="9.0.0"
SYSLOGNG_VERSION="3.31.2"
LOGSTASH_VERSION="7.14.2"
export CRIBL_VERSION
export VECTOR_VERSION
export FLUENTBIT_VERSION
export SPLUNK_VERSION
export SYSLOGNG_VERSION
export LOGSTASH_VERSION

RESULT_DIR="results/$(date +"%Y%m%dT%H%M%S")/"
RESULT_FILE="${RESULT_DIR}/results.csv"
mkdir -p $RESULT_DIR


echo "LogStream: ${CRIBL_VERSION}"     >> $RESULT_DIR/versions.txt
echo "Vector: ${VECTOR_VERSION}"       >> $RESULT_DIR/versions.txt
echo "FluentBit: ${FLUENTBIT_VERSION}" >> $RESULT_DIR/versions.txt
echo "Splunk: ${SPLUNK_VERSION}"        >> $RESULT_DIR/versions.txt
echo "LogStash: ${LOGSTASH_VERSION}"  >> $RESULT_DIR/versions.txt
echo "Syslog-ng: ${SYSLOGNG_VERSION}"  >> $RESULT_DIR/versions.txt


cat /proc/cpuinfo > $RESULT_DIR/cpuinfo
cat /proc/meinfo  > $RESULT_DIR/meminfo
uname -a          > $RESULT_DIR/uname

echo "Results path=${RESULT_FILE}"
echo "DIR,CPU_TIME,MEM_RSS" > $RESULT_FILE

if [ -z "$1" ] 
then
   files=$(find cases/ -name docker-compose.yml | sort -t/ -k3,3 -k2,2 )
else 
   files=$(find cases/ -name docker-compose.yml | grep $1 | sort -t/ -k3,3 -k2,2 )
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

