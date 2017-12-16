. ~/.profile
cd $XENO_HOME
git checkout prod
git pull origin prod
[ ! $? == 0 ] && echo "Code Checkout From Prod Branch Failed Unexpectdly. Deployment is Halted" && exit 1
gradle disttar --no-daemon
[ ! $? == 0 ] && exit 1
echo "Build Success: Continue with deployment"
cd bin
./deploy.sh true

echo "deploying xenoweb"
cd $XENO_WEB_HOME
git fetch
git checkout prod
git merge origin/staging -m "merge from staging"
git push origin prod
