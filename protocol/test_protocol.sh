#!/usr/bin/env bash

set -eo pipefail
# Export all variables
set -a

# Define global parameters
RUN_TIME=300
STOP_TIMEOUT=0
BREAK_TIME=60

# Define users and number of statements
USERS_NUMBER=1000
SPAWN_RATE=10
WORKERS_NUMBER=1
STUDENTS_NUMBER=200
STUDENT_SEED=742
STATEMENTS_PER_REQ=1

# Generate dataset for this run 
make dataspec
make dataset

# Scenario to be run
SCENARIO=post
ITERATION_NUMBER=3


# Test for Ralph with Elasticsearch database
LRS=ralph
RALPH_DB=es

# Launch test
for ((i=1;i<=ITERATION_NUMBER;i++));
do
    ITERATION=$(printf "%02d" $i)
    make run
    sleep $RUN_TIME
    make down
    sleep $BREAK_TIME
done


# Test for Learninglocker
LRS=learninglocker

# Launch test
for ((i=1;i<=ITERATION_NUMBER;i++));
do
    ITERATION=$(printf "%02d" $i)
    make run
    sleep $RUN_TIME
    make down
    sleep $BREAK_TIME
done



# Test for lrsql
LRS=lrsql

# Launch test
for ((i=1;i<=ITERATION_NUMBER;i++));
do
    ITERATION=$(printf "%02d" $i)
    make run
    sleep $RUN_TIME
    make down
    sleep $BREAK_TIME
done

echo "Run test finished!"