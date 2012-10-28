#!/bin/bash
#
# Push a list of references to the exchange file
#

EXCHANGE=/tmp/.exchange_revs
LOCK=/tmp/.exchange.lock

REV=$1
(
    flock -x 200
    cat >> $EXCHANGE
) 200>> $LOCK

