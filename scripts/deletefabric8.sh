#!/bin/sh

oc delete all -l provider=fabric8
. ./scripts/./sdeleteroutes.sh
