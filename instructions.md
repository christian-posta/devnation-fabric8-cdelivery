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

Pass as parameter the location of the vagrant private key and run the bash script `/scripts/copy-keys-vagrant.sh`

```
cd /Users/chmoulli/MyProjects/MyConferences/devnation-2015/demo/devnation-fabric8-cdelivery
./scripts/copy-keys-vagrant.sh /Users/chmoulli/Fuse/projects/fabric8/fabric8-installer/vagrant/openshift-atest/.vagrant/machines/default/virtualbox/private_key
```

# Compile Kube Jenkins & Gerrit applications

* Open a terminal and move to the directory containing this project cloned (https://github.com/fabric8io/quickstarts)
* Check that you use maven 3.2.5 to do the build
* Move to the apps/jenkins directory and execute this maven command to build jenkins with our properties

```
mvn install -Dfabric8.templateParametersFile=/Users/chmoulli/MyProjects/MyConferences/devnation-2015/demo/devnation-fabric8-cdelivery/local-scripts/jenkins-params.properties
```
* If you would like to compile the kube apps of a project, execute this command at the root of the project

```
mvn clean install -Papps -DskipTests=true
```
# Set the env variables required to access Kubernetes & OS

```
./scripts/set_kubenertes_env.sh
```

# Deploy the group of the cdelivery Kube applications on OSv3

Now that the Kube applications for that demo are compiled and the Openshift/Docker virtual machine is running, we can deploy the application
part of that demo
 
```
mvn install -Pconsole -Pcdelivery
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
  /scripts/review.sh devnation devnation 
  
cd /Users/chmoulli/Temp/test-devnation
 /Users/chmoulli/MyProjects/MyConferences/devnation-2015/demo/devnation-fabric8-cdelivery/scripts/review.sh devnation devnation
   Counting objects: 24, done.
   Delta compression using up to 8 threads.
   Compressing objects: 100% (16/16), done.
   Writing objects: 100% (24/24), 6.11 KiB | 0 bytes/s, done.
   Total 24 (delta 2), reused 0 (delta 0)
   remote: Resolving deltas: 100% (2/2)
   remote: Processing changes: refs: 1, done
   To http://admin@gerrit.vagrant.local/devnation
    * [new branch]      master -> master
     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
   100  4360  100  4360    0     0    867      0  0:00:05  0:00:05 --:--:--  304k 
```   

# Commit a change

# Start the pipeline

# Create namespace

```   
oc create -f local-scripts/dev-namespace.json 
```

