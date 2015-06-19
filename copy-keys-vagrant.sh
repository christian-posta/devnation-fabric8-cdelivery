#!/usr/bin/env bash

# /Users/chmoulli/Fuse/projects/fabric8/fabric8-installer/vagrant/openshift-latest/.vagrant/machines/default/virtualbox/private_key
PATH_PRIVATE_KEY=$1

# Change these settings to match what you are wanting to do
ROOT='ssh-keys/'
FILE1=$ROOT/admin/id_rsa
FILE2=$ROOT/admin/id_rsa.pub
FILE3=$ROOT/users/id_jenkins_rsa.pub
FILE4=$ROOT/users/id_sonar_rsa.pub
FILE5=$ROOT/users/id_gogs_rsa.pub
PATH1='/home/gerrit/admin-ssh-key'
PATH2='/home/gerrit/ssh-keys'
SERVER='vagrant.local'
IDENTITY=$1

/usr/bin/scp -i $IDENTITY $FILE1 $FILE2 vagrant@172.28.128.4:$PATH1
/usr/bin/scp -i $IDENTITY $FILE3 $FILE4 $FILE5 vagrant@172.28.128.4:$PATH2