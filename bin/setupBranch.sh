#!/bin/bash
BRANCH=$1
[ -z "$BRANCH" ] && echo "branch name is required" && exit 1
. ~/.profile
cd $XENO_HOME
git checkout $BRANCH
git pull origin $BRANCH
[ ! $? == 0 ] && echo "Code Checkout From $BRANCH Branch Failed Unexpectdly. Deployment is Halted" && exit 1
gradle disttar --no-daemon
[ ! $? == 0 ] && exit 1
echo "Build Success: Continue with deployment"
cd bin
./startup.sh restart

