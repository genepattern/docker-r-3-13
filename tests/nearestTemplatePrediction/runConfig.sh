#!/bin/sh

TASKLIB=$PWD/src
INPUT_FILE_DIRECTORIES=$PWD/data
CONTAINER_OVERRIDE_MEMORY=5100
JOB_DEFINITION_NAME="R313_Generic"
JOB_ID=gp_job_R313_$1
JOB_QUEUE=TedTest
S3_ROOT=s3://moduleiotest
WORKING_DIR=$PWD/job_42345

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore $TASKLIB/NTPez.R $INPUT_FILE_DIRECTORIES/Train_Liver.gct $INPUT_FILE_DIRECTORIES/Hoshida_Survival_signature.txt NTP cosine T 1000 F 7392854"


RLIB=$TEST_ROOT/containers/R313_cli/tests/rlib
DOCKER_CONTAINER=genepattern/docker-r-3-13


