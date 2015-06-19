# Demo scenario

Here is the description/presentation of the steps to be followed in order to setup the environment and run the demo

# Clone fabric8-installer

Clone the Fabric8-installer project and move to the vagrant/openshift-latest directory

```
git clone https://github.com/fabric8io/fabric8-installer
cd fabric8-installer/vagrant/openshift-latest
```

# Create the Vagrant VM machine

```
vagrant up
```

# Import SSH Keys

In order to use gerrit, we have to import the ssh-keys of the admin and jenkins/gogs/sonar users. The private/public keys of the admin user are mandatory
while optional for the others

* First ssh to the vagrant machine
```
vagrant ssh
```
* Next run these instrustions to create directories 
```
sudo mkdir -p /home/gerrit/site
sudo mkdir -p /home/gerrit/admin-ssh-key/
sudo chown -R vagrant /home/gerrit/
mkdir -p /home/gerrit/ssh-keys/
sudo chown -R vagrant /home/gerrit/ssh-keys/
```    
* You can exit from the vagrant machine

# Copy ssh keys

Pass as parameter the location of the vagrant private key

```
cd /Users/chmoulli/MyProjects/MyConferences/devnation-2015/demo/devnation-fabri8-cdelivery
./copy-keys-vagrant.sh /Users/chmoulli/Fuse/projects/fabric8/fabric8-installer/vagrant/openshift-latest/.vagrant/machines/default/virtualbox/private_key
```

    
    
    
    
# Delete the Fabric8 App

oc delete rc -l provider=fabric8
oc delete pods -l provider=fabric8
oc delete svc -l provider=fabric8
oc delete svc sonarqube
oc delete rc sonarqube
oc delete oauthclients fabric8
oc delete oauthclients gogs

oc get pods -l provider=fabric8
oc get rc -l provider=fabric8
oc get rc sonarqube
oc get svc sonarqube
oc get oauthclients | grep fabric8
oc get oauthclients | grep gogs

# Delete the containers & images

docker rm $(docker ps -a | grep fabric8)
docker rmi $(docker images | grep fabric8)

Remark : If location of vagrant changes, update also the IDENTITY env var to get the private_key of vagrant within the script

# Gerrit

git clone http://admin@gerrit.vagrant.local/demo2
cd demo2
git review -s
echo "1111" > README.md
git checkout -b mycoolfeature
git add README.md
git commit -m "Commit : 1" -a
git review

# Jenkins

Run a DSL Script locally
Before you push a new DSL script to jenkins, it's helpful to run it locally and eyeball the resulting XML. To do this follow these steps:

git clone https://github.com/jenkinsci/job-dsl-plugin.git
cd job-dsl-plugin
./gradlew :job-dsl-core:oneJar
DSL_JAR=$(find job-dsl-core -name '*standalone.jar'|tail -1)
java -jar $DSL_JAR sample.dsl.groovy

java -cp /Users/chmoulli/Fuse/projects/fabric8/default-jenkins-dsl/lib/*:job-dsl-core/build/one-jar-build/lib/*:job-dsl-core/build/one-jar-build/main/main.jar javaposse.jobdsl.Run /Users/chmoulli/Fuse/projects/fabric8/default-jenkins-dsl/seedBuilds.groovy 

# Create gerrit repo 

http --auth-type digest --verbose -a admin:secret PUT http://gerrit.vagrant.local/a/projects/devnation

# Sync Gogs repo with Gerrit
rm -rf devnation/
git clone http://gogs.vagrant.local/root/devnation.git
cd devnation/
git config user.name "Administrator"
git config user.email "admin@fabric8.io"
git config remote.review.url  http://admin@gerrit.vagrant.local/devnation
git config remote.review.push HEAD:refs/for/master
curl -Lo .git/hooks/commit-msg http://gerrit.vagrant.local/tools/hooks/commit-msg
chmod +x .git/hooks/commit-msg
echo "First step to devnation" >> README.md
git add README.md
git commit -m "first commit"
git push review
cd ..

# Get a pull of a review

git pull http://admin@gerrit.vagrant.local/devnation refs/changes/02/2/1

# Delete a gerrit project

http --auth-type digest -a admin:secret DELETE http://gerrit.vagrant.local/a/projects/devnation

# Access a docker container (bash)

docker exec -it $(docker ps | grep 'gerrit:latest' | cut -f1 -d" ") bash

# Regenerate a new json file of gerrit kube app

mvn fabric8:json -Dfabric8.envproperties=something.properties

# Stop a docker container

docker stop $(docker ps | grep 'fabric8/gerrit' | cut -f1 -d" ")

# Setup the env var to access Docker & Kubernetes

unset DOCKER_CERT_PATH
unset DOCKER_TLS_VERIFY
export DOCKER_HOST=tcp://vagrant.local:2375
export KUBERNETES_NAMESPACE=default
export KUBERNETES_MASTER=https://172.28.128.4:8443
export KUBERNETES_DOMAIN=vagrant.local
export KUBERNETES_TRUST_CERT="true"

oc project default
oc login -u admin -p admin https://172.28.128.4:8443  


# Install Base or CDelivery

oc process -v DOMAIN='vagrant.local' -f http://central.maven.org/maven2/io/fabric8/apps/base/2.1.11/base-2.1.11-kubernetes.json | oc create -f -

oc process -v DOMAIN='vagrant.local' -f http://central.maven.org/maven2/io/fabric8/apps/cdelivery-core/2.1.11/cdelivery-core-2.1.11-kubernetes.json | oc create -f -

oc process -v DOMAIN='vagrant.local' -f /Users/chmoulli/Fuse/Fuse-projects/fabric8/quickstarts-forked/app-groups/cdelivery-core/target/classes/kubernetes.json | oc create -f -

oc process -v DOMAIN='vagrant.local' -f /Users/chmoulli/Fuse/Fuse-projects/fabric8/quickstarts-forked/apps/fabric8-forge/target/classes/kubernetes.json | oc create -f -

# Test Fabric8 Maven plugin to create a gerrit repo

mvn io.fabric8:fabric8-maven-plugin:2.3-SNAPSHOT:create-gitrepo -DgerritAdminUsername="admin" -DgerritAdminPassword="secret" -Drepo="demo"
mvnDebug io.fabric8:fabric8-maven-plugin:2.3-SNAPSHOT:create-gitrepo -DgerritAdminUsername="admin" -DgerritAdminPassword="secret" -Drepo="demo"


# Compile & Deploy a project

mvn clean fabric8:json compile 
mvn fabric8:apply -Dfabric8.recreate=true -Dfabric8.domain=vagrant.local


# Gerrit maven plugin to be used to create a gerrit repo

mvn io.fabric8:fabric8-maven-plugin:2.3-SNAPSHOT:create-gitrepo -Drepo="demo" -DgerritAdminUsername="admin" -DgerritAdminPassword="secret" -Dempty_commit="false"

# Git Review

References : 
- http://localhost:8080/Documentation/intro-quick.html
- http://localhost:8080/Documentation/intro-project-owner.html
- http://localhost:8080/Documentation/user-review-ui.html

- http://docs.openstack.org/infra/git-review/usage.html
- https://www.mediawiki.org/wiki/Gerrit/Advanced_usage

# Get Approval infos

git fetch origin refs/notes/review:refs/notes/review
git log --notes=review


