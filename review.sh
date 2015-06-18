#!/bin/sh

PROJ_DIR=$1

cd $PROJ_DIR
git config user.name "Administrator"
git config user.email "admin@company.com"
git config remote.review.url  http://admin@gerrit.vagrant.local/$2
git push review
git config remote.review.push HEAD:refs/for/master
curl -Lo .git/hooks/commit-msg http://gerrit.vagrant.local/tools/hooks/commit-msg
chmod +x .git/hooks/commit-msg
