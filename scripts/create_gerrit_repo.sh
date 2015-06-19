#!/usr/bin/env bash

HOSTNAME=$1
REPO=$2

http --auth-type digest --verbose -a admin:secret PUT http://$HOSTNAME/a/projects/$REPO