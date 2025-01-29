#!/bin/bash -e

SIMULATE=$(snapctl get simulate)

# Store the first argument in a var, and then remove it from $@ by doing a shift
COMMAND=$1; shift;

if [ -z "${SIMULATE}" ]; then
  # not simulating, call binary directly
  echo "Not simulating"
  exec $COMMAND "$@"
else
  echo "export LD_PRELOAD=$SNAP/linuxptp-testsuite/clknetsim/clknetsim.so"
  echo "$@"
  export LD_PRELOAD=$SNAP/linuxptp-testsuite/clknetsim/clknetsim.so
  exec $COMMAND "$@"
fi