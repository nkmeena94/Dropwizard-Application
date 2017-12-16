#! /bin/bash

P1=9000
P2=9100
P3=15555

export PROD_MODE=$1
[ -z ${PROD_MODE} ] && echo "Please specify Prod_Mode = true/false" && echo "Usage : " && echo "[In Production] - deploy.sh true" && echo "[In Staging   ] - deploy.sh false" && exit 1

if [ "$PROD_MODE" == "true" ];
then 
	export APP_XMX=1000
	export SYNCER_XMX=1500
else
	export APP_XMX=500
	export SYNCER_XMX=750

fi

echo PROD_MODE set to $PROD_MODE
cd $XENO_HOME
echo "stopping syncer"
export APP_PORT=$P3
export ADMIN_PORT=$((P3+1))
export DEBUG_PORT=$((P3+5))
$XENO_HOME/bin/startup.sh "stopSyncer"

echo
echo "restating APP1"

export APP_PORT=$P1
export ADMIN_PORT=$((P1+1))
export DEBUG_PORT=$((P1+5))
$XENO_HOME/bin/startup.sh restartApp 
[ ! "$?" == 0 ] && echo "Redeploy Failed" && exit 1

echo "APP1 at $APP_PORT started"
echo

if [ "$PROD_MODE" == "true" ];
then
	echo "restating APP2"

	export APP_PORT=$P2
	export ADMIN_PORT=$((P2+1))
	export DEBUG_PORT=$((P2+5))
	$XENO_HOME/bin/startup.sh restartApp

	[ ! "$?" == 0 ] && echo "Redeploy Failed" && exit 1
	echo "APP2 at $APP_PORT started"
	echo
fi
echo "Starting syncer"

export APP_PORT=$P3
export ADMIN_PORT=$((P3+1))
export DEBUG_PORT=$((P3+5))
$XENO_HOME/bin/startup.sh startSyncer
[ ! "$?" == 0 ] && echo "Redeploy Failed" && exit 1
echo "Syncer started"



