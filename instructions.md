# Demo scenario

Here is the description/presentation of the steps to be followed in order to setup the environment and run the demo

* Verify that the  `/etc/hosts` file contains a mapping btween the IP address of the VM and these hostnames

```
172.28.128.4	fabric8.local gogs.local vagrant.local docker-registry.vagrant.local fabric8-master.vagrant.local fabric8.vagrant.local gogs.vagrant.local jenkins.vagrant.local kibana.vagrant.local nexus.vagrant.local router.vagrant.local gerrit-ssh.vagrant.local gerrit.vagrant.local gerrit.vagrant.local gerrit-http.vagrant.local sonarqube.vagrant.local letschat.vagrant.local orion.vagrant.local taiga.vagrant.local quickstart-camelservlet.vagrant.local quickstart-rest.vagrant.local
```

* Add the routes used by the macos x machine to access the Pods/Docker containers

```
sudo route -n delete 172.0.0.0/8
sudo route -n add 172.0.0.0/8  172.28.128.4
```

* Install the Openshift Client on your MacosX machine 

# Clone fabric8-installer

Clone the Fabric8-installer project and move to the vagrant/openshift-latest directory. Checkout this id
as the latest commit (19/06/2015) is not working anymore 

```
git clone https://github.com/fabric8io/fabric8-installer
git checkout 09d2005
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
* Next run these instructions to create directories 
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
cd /Users/chmoulli/MyProjects/MyConferences/devnation-2015/demo/devnation-fabric8-cdelivery
./scripts/copy-keys-vagrant.sh /Users/chmoulli/Fuse/projects/fabric8/fabric8-installer/vagrant/openshift-atest/.vagrant/machines/default/virtualbox/private_key
```

# Compile quickstarts app


* Ope a terminal and change to quickstart fabric8 project
* Check that you use maven 3.2.5 to do the build
* Depending of the version used by the project, build accordingly the project (2.2.0, ...)

```
mvn clean install -Papps -DskipTests=true
```
# Set the env variables required to access Kubernetes & OS

```
./scripts/set_kubenertes_env.sh
```

# Deploy the group of the cdelivery Kube applications on OSv3

 
```
vn clean install -Pcdelievry
```

* Control that the Fabric8 Pods & Services have been created
```
oc get pods
oc get services

 oc get svc
NAME              LABELS                                     SELECTOR                                   IP(S)            PORT(S)
docker-registry   docker-registry=default                    docker-registry=default                    172.30.136.53    5000/TCP
elasticsearch     component=elasticsearch,provider=fabric8   component=elasticsearch,provider=fabric8   172.30.74.191    9200/TCP
fabric8           component=console,provider=fabric8         component=console,provider=fabric8         172.30.218.102   80/TCP
fabric8-forge     component=fabric8Forge,provider=fabric8    component=fabric8Forge,provider=fabric8    172.30.127.171   80/TCP
gerrit            component=gerrit,provider=fabric8          component=gerrit,provider=fabric8          172.30.153.170   80/TCP
gerrit-ssh        component=gerrit,provider=fabric8          component=gerrit,provider=fabric8          172.30.128.61    29418/TCP
gogs              component=gogs,provider=fabric8            component=gogs,provider=fabric8            172.30.209.199   80/TCP
gogs-ssh          component=gogs,provider=fabric8            component=gogs,provider=fabric8            172.30.255.164   22/TCP
jenkins           component=jenkins,provider=fabric8         component=jenkins,provider=fabric8         172.30.119.13    80/TCP
kibana            component=kibana,provider=fabric8          component=kibana,provider=fabric8          172.30.16.216    80/TCP
kubernetes        component=apiserver,provider=kubernetes    <none>                                     172.30.0.2       443/TCP
kubernetes-ro     component=apiserver,provider=kubernetes    <none>                                     172.30.0.1       80/TCP
nexus             component=nexus,provider=fabric8           component=nexus,provider=fabric8           172.30.126.22    80/TCP
router            router=router                              router=router                              172.30.165.182   80/TCP


oc get pods
NAME                      READY     REASON    RESTARTS   AGE
docker-registry-1-rr459   1/1       Running   0          44m
elasticsearch-mb3fv       2/2       Running   0          22m
fabric8-0upsk             1/1       Running   0          22m
fabric8-forge-2ma9j       1/1       Running   0          22m
gerrit-ctobk              1/1       Running   0          22m
gogs-148m9                1/1       Running   0          22m
jenkins-29e5i             1/1       Running   0          22m
kibana-zfgyf              1/1       Running   0          22m
nexus-1fsnz               1/1       Running   0          22m
router-1-9us2r            1/1       Running   0          44m
```

* If the gerrit service is not there, then check that its json file contains the service. IF this is not the case, then rebuild it

```
mvn clean fabric8:json install
```

* As it seems that the routes are not created by default, we have to recreate them
  So run ths script and check that the routes are created
    
```
./scripts/rebuildroutes.sh

oc get routes
NAME                    HOST/PORT                       PATH      SERVICE           LABELS
docker-registry         docker-registry.vagrant.local             docker-registry   
docker-registry-route   docker-registry.vagrant.local             docker-registry 
  
elasticsearch           elasticsearch.vagrant.local               elasticsearch    
 
fabric8                 fabric8.vagrant.local                     fabric8           
fabric8-forge           fabric8-forge.vagrant.local               fabric8-forge     
gogs                    gogs.vagrant.local                        gogs              
gogs-ssh                gogs-ssh.vagrant.local                    gogs-ssh          
jenkins                 jenkins.vagrant.local                     jenkins           
kibana                  kibana.vagrant.local                      kibana            
nexus                   nexus.vagrant.local                       nexus             
router                  router.vagrant.local                      router 
```   

* We can verify now that nexus, gerrit, gogs & jenkins servers are running.
  So open a web browser with these addresses
  
```
chrome http://gogs.vagrant.local 
chrome http://jenkins.vagrant.local
chrome http://nexus.vagrant.local
chrome http://gerrit.vagrant.local
chrome http://fabric8.vagrant.local 
```  
# Create a CD/CI project
    
* Open the Fabric8 Web console and select the "Projects" tab

  add image 
  
* From this view, click on the button "create project", a new screen will be displayed where
  you can encode the name of the project (= name of the git repo, jenkins dsl pipeline, ...), the package name & version to be used
  Remark : The build system can't be changed for the moment and is maven like the type "From Archetype catalog" 
  
  add image 
  
* Click on execute and within the next screen, you will be able to select from the maven catalog the archerype to be used "io.fabric8.archetypes:java-camel-cdi-archetype:2.2.0"
  using the catalog of "fabric8". Click on execute to request the creation of the seed, jobs & git repos
  
  add image   
  
* Review what has been created in jenkins, gogs, gerrit & fabric8
  
  add image 
  add image 
  add image 
  
# Clone the project in a terminal to make a change & start a review process
```    
   git clone http://gogs.vagrant.local/gogsadmin/devnation.git
   cd devnation
```  
# Add Gerrit Review hook to the project
      
  Run the script and pass as parameter the directory name of the project to be created locally on your machine and the gerrit git repository (should be by example : devnation)
```  
  /scripts/review.sh devnnation      
```    
     
# Delete the Fabric8 App

```
oc delete rc -l provider=fabric8
oc delete pods -l provider=fabric8
oc delete svc -l provider=fabric8
oc delete oauthclients fabric8
oc delete oauthclients gogs

oc get pods -l provider=fabric8
oc get rc -l provider=fabric8
oc get oauthclients | grep fabric8
oc get oauthclients | grep gogs
```

# Delete the containers & images

```
docker rm $(docker ps -a | grep fabric8)
docker rmi $(docker images | grep fabric8)
```
Remark : If location of vagrant changes, update also the IDENTITY env var to get the private_key of vagrant within the script

# Gerrit

```
git clone http://admin@gerrit.vagrant.local/demo2
cd demo2
git review -s
echo "1111" > README.md
git checkout -b mycoolfeature
git add README.md
git commit -m "Commit : 1" -a
git review
```

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


