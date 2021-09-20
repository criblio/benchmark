# Observability Pipeline Benchmarking

## Requirements 
1. docker 
2. docker-compose 
3. 4+ vCPU system (8+ recommended)
4. 8GB RAM (16GB+ recommended)
5. 8GB disk space (16GB+ recommended)

## Run the benchmark 
To run the benchmarks you simply execute the following command at the root of the repo
```
 ./run.sh 
```

## Results 
The results of the benchmark execution will be stored in `results/<date-time>/results.csv` as well as output before `./run.sh` completes.

## What's measured?
The benchmarking tool will measure the `test-system`'s:
1. CPU consumption
2. RSS memory (measured at exit)

These measurements are collected from `/sys/fs/cgroups/<cpu|memory>/docker/<container>/...` - ie they include **all** processes in the `test-system` (see `run.sh` for more details) 

## How does it work?
The benchmark uses `docker-compose` to create test case scenarios which follow this pattern: `source -> test-system -> destination`, where:
1. source - is the data producer and/or load generator. 
2. test-system - is the system under observeration 
3. destination - a system where `test-system` sends its results to

The tests use a simple pattern of `source` generating and pushing a constant "load" to the `test-system`, which is assumed to be configured and operate correctly (ie no correctness check are embedded) 

The repo is organized as follows:
1. cases - this is where the test cases live 
3. common - this is where common services are defined (eg. data producer or sinks)

Test cases are organized as follows
```
cases/<test-case-name>/<system>/
cases/<test-case-name>/<system>/docker-compose.yml      -- defines the test case for <system>, must include test-system service
cases/<test-case-name>/<system>/test-system/Dockerfile  -- defines test-system service
```

