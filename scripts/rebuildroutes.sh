#!/bin/sh

. ./scripts/deleteroutes.sh
mvn io.fabric8:fabric8-maven-plugin:2.2.0:create-routes
