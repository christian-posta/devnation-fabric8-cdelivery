#!/bin/sh

oc delete all -l provider=fabric8
. ./deleteroutes.sh
