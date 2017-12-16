#!/usr/bin/env bash
checkIfStarted() {
    PORT=$1
    echo "checking for PORT $PORT"
    status=7
    count=0
    while [ ! "$status" == 0 -a $count -lt 100 ] 
    do
        printf "."
        sleep 1
        curl -X GET "http://localhost:${PORT}/api/xeno/v0/ping" > /dev/null 2>&1
        status=$?
        count=$((count+1))
    done
    if [ $status != 0 ]
    then
        echo "startup failed"
        exit 1
    fi
}

killprocess()
{
    PROCESS=${1}
    ignore=`basename $0`
    if [ ! -z "${PROCESS}" ]; then
        _processes=( `ps -fu$USER | ${GREP} ${PROCESS} | ${GREP} -v ${ignore} | grep -v "grep" | awk '{print $2}'` )
    else
        _processes=( `status -s | awk '{print $2}'` )
    fi
    for process in ${_processes[@]}
    do
        echo Stopping ${PROCESS} process with PID = ${process}
        kill $process
		while `ps -p $process >/dev/null`
		do
			printf "."
			sleep 1
		done
		echo Process Stopped
    done
}

startApp() {
	tar -xf $XENO_HOME/master/build/distributions/master-${project_ver}.tar
	cwd=`pwd`
	for jar in `ls master-${project_ver}/lib`
	do
		cp=$cp:$cwd/master-${project_ver}/lib/$jar
	done
    mkdir -p $XENO_HOME/logs
    cd $XENO_HOME/logs
    javaagent=newrelic.jar
    sed "s/--APP_NAME--/XenoServer:$APP_PORT/g" ${JAVA_AGENT_HOME}/newrelic.yml.template > ${JAVA_AGENT_HOME}/newrelic.yml
    export JAVA_OPTS="-Xms256m -Xmx${APP_XMX}m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT"
    [ -e "${JAVA_AGENT_HOME}/${javaagent}" -a ${PROD_MODE} == "true" ] && JAVA_AGENT="-javaagent:${JAVA_AGENT_HOME}/${javaagent}"
    [ ! -e "${JAVA_AGENT_HOME}/${javaagent}" -o ${PROD_MODE} == "false" ] && echo "JAVA AGENT Monitoring agent wont be enabled"
    echo > $XENO_HOME/logs/nohup.out
    nohup java `echo $JAVA_OPTS` `echo $JAVA_AGENT` -cp $cp com.xeno.fnd.server.XenoApp server $XENO_HOME/master/src/main/resources/properties.yml $PROD_MODE >> $XENO_HOME/logs/err.log 2>&1 &
	checkIfStarted $APP_PORT
}

startSyncer() {
	tar -xf $XENO_HOME/syncer/build/distributions/syncer-${project_ver}.tar
	cwd=`pwd`
	for jar in `ls syncer-${project_ver}/lib`
	do
		cp=$cp:$cwd/syncer-${project_ver}/lib/$jar
	done
    mkdir -p $XENO_HOME/logs
    cd $XENO_HOME/logs
    javaagent=newrelic.jar
    sed "s/--APP_NAME--/XenoSyncer/g" ${JAVA_AGENT_HOME}/newrelic.yml.template > ${JAVA_AGENT_HOME}/newrelic.yml
    export JAVA_OPTS="-Xms256m -Xmx${SYNCER_XMX}m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT"
    [ -e "${JAVA_AGENT_HOME}/${javaagent}" -a ${PROD_MODE} == "true" ] && JAVA_AGENT="-javaagent:${JAVA_AGENT_HOME}/${javaagent}"
    [ ! -e "${JAVA_AGENT_HOME}/${javaagent}" -o ${PROD_MODE} == "false" ] && echo "JAVA AGENT Monitoring agent wont be enabled"
    nohup java `echo $JAVA_OPTS` `echo $JAVA_AGENT` -cp $cp com.xeno.init.XenoSync server $XENO_HOME/syncer/src/main/resources/syncer_conf.yml $PROD_MODE  >> $XENO_HOME/logs/err.log 2>&1 &
	checkIfStarted $APP_PORT
}

startDev() {
	tar -xf $XENO_HOME/syncer/build/distributions/syncer-${project_ver}.tar
	cwd=`pwd`
	for jar in `ls syncer-${project_ver}/lib`
	do
		cp=$cp:$cwd/syncer-${project_ver}/lib/$jar
	done
    mkdir -p $XENO_HOME/logs
    cd $XENO_HOME/logs
    export JAVA_OPTS="-Xms256m -Xmx800m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT"
    nohup java `echo $JAVA_OPTS` -cp $cp com.xeno.init.XenoDev server $XENO_HOME/syncer/src/main/resources/syncer_conf.yml $XENO_HOME/master/src/main/resources/properties.yml >> $XENO_HOME/logs/err.log 2>&1 &
	checkIfStarted $APP_PORT
}

startJen() {
	killprocess "address=$DEBUG_PORT"
    tar -xf $XENO_HOME/syncer/build/distributions/syncer-${project_ver}.tar
    cwd=`pwd`
    for jar in `ls syncer-${project_ver}/lib`
    do
        cp=$cp:$cwd/syncer-${project_ver}/lib/$jar
    done
    mkdir -p $XENO_HOME/logs
    cd $XENO_HOME/logs
    export JAVA_OPTS="-Xms256m -Xmx800m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT"
    java `echo $JAVA_OPTS` -cp $cp com.xeno.init.XenoDev server $XENO_HOME/syncer/src/main/resources/syncer_conf.yml $XENO_HOME/master/src/main/resources/properties.yml > $XENO_HOME/logs/err.log 2>&1 &
	checkIfStarted $APP_PORT
}
startLoader() {
	echo "runnning loader"
	DEBUG_PORT=29997
    killprocess "address=$DEBUG_PORT"
	echo "runnning loader"
    tar -xvf $XENO_HOME/syncer/build/distributions/syncer-${project_ver}.tar
	echo "runnning loader"
    cwd=`pwd`
    for jar in `ls syncer-${project_ver}/lib`
    do
        cp=$cp:$cwd/syncer-${project_ver}/lib/$jar
    done
    mkdir -p $XENO_HOME/logs
    cd $XENO_HOME/logs
    export JAVA_OPTS="-Xms256m -Xmx1000m -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORT"
    java `echo $JAVA_OPTS` -cp $cp com.xeno.init.AdidasSync >> $XENO_HOME/logs/err.log 2>&1 &
}


usage() {
    echo 'startup.sh start|stop|restart'
}

export project_ver="1-SNAPSHOT"
export JAVA_AGENT_HOME=$XENO_HOME/bin/newrelic
export GREP="grep"
[ -z ${DEBUG_PORT} ] && export DEBUG_PORT=9999
[ -z ${SYNCER_PORT} ] && export SYNCER_PORT=15555
[ -z ${SYNCER_ADMIN_PORT} ] && export SYNCER_ADMIN_PORT=15556
[ -z ${PROD_MODE} ] && PROD_MODE=false
case "$1" in
    "start"     ) startDev ;;
    "startJen"     ) startJen ;;
    "load"     ) startLoader ;;
    "startprodapp"     ) startApp ;;
    "startSyncer"     ) startSyncer ;;
    "stop"      ) killprocess "address=$DEBUG_PORT" ;;
    "stopApp"      ) killprocess "address=$2" ;;
    "stopSyncer"      ) killprocess "address=$DEBUG_PORT" ;;
    "restart"   ) killprocess "address=$DEBUG_PORT" ;startDev ;;
    "restartApp"   ) killprocess "address=$DEBUG_PORT" ; startApp ;;
    "restartSyncer"   ) killprocess "address=$DEBUG_PORT" ; startSyncer ;;
    ""|*        ) usage ; exit 1 ;;
esac
