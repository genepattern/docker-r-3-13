#!/bin/bash

# strip off spaces if present
TASKLIB="$(echo -e "${1}" | tr -d '[:space:]')"
INPUT_FILES_DIR="$(echo -e "${2}" | tr -d '[:space:]')"
S3_ROOT="$(echo -e "${3}" | tr -d '[:space:]')"
WORKING_DIR="$(echo -e "${4}" | tr -d '[:space:]')"
EXECUTABLE=$5

: ${R_LIBS_S3=/genepattern-server/Rlibraries/R313/rlibs}
export R_LIBS=/usr/local/lib/R/site-library

#
# assign filenames for STDOUT and STDERR if not already set
#
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=$GP_METADATA_DIR/stdout.txt}
: ${STDERR_FILENAME=$GP_METADATA_DIR/stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# echo out params
echo working dir is  -$WORKING_DIR- 
echo Task dir is -$TASKLIB-
echo executable is -$5-
echo S3_ROOT is -$S3_ROOT-
echo input files location  is -$INPUT_FILES_DIR-

# copy the source over from tasklib
mkdir -p $TASKLIB
echo "0. AWS SYNC $S3_ROOT$TASKLIB $TASKLIB"
aws s3 sync $S3_ROOT$TASKLIB $TASKLIB --quiet
ls $TASKLIB

 
# copy the inputs
mkdir -p $INPUT_FILES_DIR
echo "1. PERFORMING aws s3 sync $S3_ROOT$INPUT_FILES_DIR $INPUT_FILES_DIR"
aws s3 sync $S3_ROOT$INPUT_FILES_DIR $INPUT_FILES_DIR --quiet
ls $INPUT_FILES_DIR

# switch to the working directory and sync it up
echo "2. PERFORMING aws s3 sync $S3_ROOT$WORKING_DIR $WORKING_DIR "
aws s3 sync $S3_ROOT$WORKING_DIR $WORKING_DIR --quiet
aws s3 sync $GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR --quiet
chmod a+rwx $GP_METADATA_DIR/*
echo "3. POST SYNC GP_METADATA_DIR contents are"
ls  $WORKING_DIR/.gp_metadata 



##################################################
# MODIFICATION FOR R PACKAGE INSTALLATION
##################################################
# mount pre-compiled libs from S3
echo "aws s3 sync $S3_ROOT$R_LIBS_S3 $R_LIBS --quiet"
aws s3 sync $S3_ROOT$R_LIBS_S3 $R_LIBS --quiet

if [ -f "$TASKLIB/r.package.info" ]
then
	#echo "$TASKLIB/r.package.info found."
	Rscript /build/source/installPackages.R $TASKLIB/r.package.info
else
	echo "$TASKLIB/r.package.info not found."
fi

cd $WORKING_DIR

# run the module
echo "4. PERFORMING $5"
$5 >$STDOUT_FILENAME 2>$STDERR_FILENAME
echo "{ \"exit_code\": $? }">$EXITCODE_FILENAME

# send the generated files back
echo "5. PERFORMING aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR"
aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR --quiet
echo "PERFORMING aws s3 sync $TASKLIB $S3_ROOT$TASKLIB"
aws s3 sync $TASKLIB $S3_ROOT$TASKLIB --quiet
echo "6. PERFORMING aws s3 sync $R_LIBS $S3_ROOT$R_LIBS_S3"
aws s3 sync $R_LIBS $S3_ROOT$R_LIBS_S3 --quiet
echo "7. performing sync of $GP_METADATA_DIR"
aws s3 sync $GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR --quiet

