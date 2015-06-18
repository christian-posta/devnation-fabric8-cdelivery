#!/bin/sh

# Usage: ./review.sh <project_director> <repo_name>
# where <project_directory> is the location of a freshly checked out project from gogs
# ideally, we'd automate the project import into gerrit, but this works fine for now

PROJ_DIR=$1

cd $PROJ_DIR
git config user.name "Administrator"
git config user.email "admin@company.com"
git config remote.review.url  http://admin@gerrit.vagrant.local/$2
git push review
git config remote.review.push HEAD:refs/for/master
curl -Lo .git/hooks/commit-msg http://gerrit.vagrant.local/tools/hooks/commit-msg
chmod +x .git/hooks/commit-msg
