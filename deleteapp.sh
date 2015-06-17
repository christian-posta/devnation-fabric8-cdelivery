#!/bin/sh


osc get rc | grep fabric8 | awk '{print $1}' | xargs osc delete rc {}
osc get service | grep fabric8 | awk '{print $1}' | xargs osc delete service {}
