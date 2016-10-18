#!/bin/bash
NODE_NAME=$1
NODE_NAME=${NODE_NAME:-"miner1"}
if [ $# -ge 2 ]
then
    ETHERBASE=${ETHERBASE:-"0x0000000000000000000000000000000000000001"}
fi
./runnode.sh $NODE_NAME --mine --minerthreads=1 --etherbase="$ETHERBASE"
