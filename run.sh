#!/bin/bash


function clean_bench(){
  docker-compose down
}

function run_bench() {
  docker-compose up --build -d 1>&2
  SRC_CONTAINER=$(docker-compose ps -q source)
  TEST_CONTAINER=$(docker-compose ps -q test-system)

  echo waiting for source container to exit $SRC_CONTAINER 1>&2
  docker wait $SRC_CONTAINER 1>&2
  
  TIME_SPENT_SECS=$(cat /sys/fs/cgroup/cpu/docker/$TEST_CONTAINER/cpuacct.stat | awk '{ sum += $2 } END { print sum/100 }')
  echo $TIME_SPENT_SECS
}

CRIBL_VERSION="3.1.2-TC4"
VECTOR_VERSION="0.16.1"
FLUENTBIT_VERSION="1.8.7"

export CRIBL_VERSION
export VECTOR_VERSION
export FLUENTBIT_VERSION

RESULTS="DIR,CPU_TIME"
for file in $(find cases/ -name docker-compose.yml)
do
  DIR=$(dirname $file)
  echo -e "\n\nEntering $DIR ..." 1>&2
  cd $DIR
  TIME=$(run_bench)
  clean_bench
  cd -
  echo ">> RESULTS: $DIR,$TIME" 1>&2
  RESULTS="$RESULTS\n$DIR,$TIME"
done

echo -e "\n\n######## RESULTS ###########"
echo -e $RESULTS
