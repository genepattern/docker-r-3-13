#!/bin/sh

TASKLIB=$PWD/src
INPUT_FILE_DIRECTORIES=$PWD/data
CONTAINER_OVERRIDE_MEMORY=5100
JOB_DEFINITION_NAME="R313_Generic"
JOB_ID=gp_job_R313_$1
JOB_QUEUE=TedTest
S3_ROOT=s3://moduleiotest
WORKING_DIR=$PWD/job_52345

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore $TASKLIB/run_gp_affyst_efc.R $TASKLIB --input.file=$INPUT_FILE_DIRECTORIES/inputFileList.txt --normalize=yes --background.correct=no --qc.plot.format=skip --annotate.rows=yes --output.file.base=tedsOutputFile"

RLIB=$TEST_ROOT/containers/R313_cli/tests/rlib
DOCKER_CONTAINER=genepattern/docker-r-3-13


