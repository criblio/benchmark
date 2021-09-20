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

CRIBL_VERSION="3.1.2-TC4"
VECTOR_VERSION="0.16.1"
FLUENTBIT_VERSION="1.8.7"
SPLUNK_VERSION="8.2.2"
export CRIBL_VERSION
export VECTOR_VERSION
export FLUENTBIT_VERSION
export SPLUNK_VERSION

RESULT_FILE="results/$(date +"%Y%m%dT%H%M%S")/results.csv"
mkdir -p $(dirname $RESULT_FILE)


echo "Results path=${RESULT_FILE}"
echo "DIR,CPU_TIME,MEM_RSS" > $RESULT_FILE

# find and run all the tests, order by the system being tested (smoothen out docker pulls)
for file in $(find cases/ -name docker-compose.yml | sort -t/ -k3,3 -k2,2 )
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

