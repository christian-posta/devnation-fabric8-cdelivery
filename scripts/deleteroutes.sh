#!/bin/sh

oc delete route taiga
oc delete route orion
oc delete route nexus
oc delete route letschat
oc delete route kibana
oc delete route jenkins
oc delete route gogs-ssh
oc delete route gogs
oc delete route gerrit-ssh
oc delete route gerrit-http
oc delete route fabric8-forge
oc delete route elasticsearch
oc delete route fabric8
oc delete route sonarqube
