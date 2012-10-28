#!/bin/bash

EXCHANGE=/tmp/.exchange_revs
LOCK=/tmp/.exchange.lock
BUILD_LOG=/tmp/.build_log
MAX_RUNNERS=1
RUN_DIR=/tmp

REPO=$1

if [ $# -lt 1 ];
then
    echo "Usage: runner.sh <Path to Repository>"
    exit -1
fi

if [ ! -d "$REPO" ];
then
    echo "$REPO is not a directory"
    exit -2
fi

while true
do
    touch $EXCHANGE
    FILE_EMPTY=$(head -n1 $EXCHANGE)
    if [ "$FILE_EMPTY" == "" ];
    then
        inotifywait -e modify $EXCHANGE &> /dev/null
    fi

    RUNNERS=$(ls $RUN_DIR/runner_* 2> /dev/null | wc -l)
    if [ $RUNNERS -lt $MAX_RUNNERS ]; then
        (
            flock -x 200
            REV=$(head -n1 $EXCHANGE)
            sed -i -e "1d" $EXCHANGE
            # set up test runner
            (
                RUN_FILE=$RUN_DIR/runner_$$
                >$RUN_FILE
                TMP=$(mktemp -d) 

                # trap exists
                trap 'rm -r $RUN_FILE $TMP' EXIT

                cd $TMP
                # checkout the revision without cloning everything
                git init
                git remote add origin $REPO
                git fetch origin
                git checkout $REV

                # run the test
                ./configure
                make test
                if [ $? -eq 0 ];
                then
                    echo $REV builds
                else
                    echo $REV fails
                fi >> $BUILD_LOG

                cd -

                rm -r $TMP $RUN_FILE
            ) &> /dev/null &
        ) 200>> $LOCK
    else
        echo "No runner available, sleeping for 10 seconds"
        sleep 10
    fi
done
