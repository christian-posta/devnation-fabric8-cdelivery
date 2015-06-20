#!/usr/bin/env bash

mvn clean install
mkdir -p target/temp

cd target/temp

git clone git@github.com:christian-posta/default-jenkins-dsl.git

git clone https://github.com/jenkinsci/job-dsl-plugin.git

cd job-dsl-plugin
./gradlew :job-dsl-core:oneJar

export DSL_JAR=$(find job-dsl-core -name '*standalone.jar'|tail -1)
export JENKINS_GOGS_USER=gogsadmin
export JENKINS_GOGS_PASSWORD=RedHat$1
export GOGS_SERVICE_HOST=gogs.vagrant.local
export GOGS_SERVICE_PORT=80
export DOCKER_HOST=tcp://vagrant.local:2375
export KUBERNETES_NAMESPACE=default
export KUBERNETES_MASTER=https://172.28.128.4:8443
export KUBERNETES_DOMAIN=vagrant.local
export KUBERNETES_TRUST_CERT="true"

java -cp ../../lib/*:job-dsl-core/build/one-jar-build/lib/*:job-dsl-core/build/one-jar-build/main/main.jar javaposse.jobdsl.Run ../default-jenkins-dsl/seedBuilds.groovy

# /Users/chmoulli/Temp/job-dsl-plugin
# java -cp /Users/chmoulli/Fuse/Fuse-projects/fabric8/fabric8-forked/components/gitrepo-resteasy/target/lib/*:/Users/chmoulli/Fuse/Fuse-projects/fabric8/fabric8-forked/components/gitrepo-resteasy/target/gitrepo-resteasy-2.3-SNAPSHOT.jar:job-dsl-core/build/one-jar-build/lib/*:job-dsl-core/build/one-jar-build/main/main.jar javaposse.jobdsl.Run ../default-jenkins-dsl/seedBuilds.groovy