#!/bin/bash --login

#
# MIT License
#
# Copyright (c) 2022 LiGuo <bingyang136@163.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#

APP_NAME=ws-fast

PROG_NAME=$0
ACTION=$1
APP_START_TIMEOUT=45
APP_PORT=20130
HEALTH_CHECK_URL=http://127.0.0.1:${APP_PORT}/warmup
APP_HOME=/usr/app/${APP_NAME}
JAR_NAME=door-god-api-1.0-SNAPSHOT.jar
JAR_PATH=${APP_HOME}/target/${JAR_NAME}
APP_LOG_DIR=/usr/app/logs/${APP_NAME}
JAVA_OUT=${APP_LOG_DIR}/start-${APP_NAME}.log
RESOURCES_PATH=${APP_HOME}/target/resources/
LIVENESS_DELAY_SEC=60
LIVENESS_TIMEOUT_SEC=5
LIVENESS_FAIL=3
LIVENESS_ENV=prd
USR_DEPLOY_FILE=/usr/app/deploy.sh
#Trace 配置
TRACE_REPORT_TOKEN=iol3nshb81@464037b5b8359d5_iol3nshb81@53df7ad2afe8301
TRACE_REPORT_ADDRESS=http://tracing-analysis-dc-sz-internal.aliyuncs.com:8090
TRACE_REPORT_AGENT_FILE=/usr/app/opentelemetry-javaagent.jar
TRACE_REPORT_LOG_FILE=/usr/app/logs/${APP_NAME}/opentelemetry.log

if [ ! -d "${APP_HOME}" ]; then
  mkdir -p ${APP_HOME}
fi

if [ ! -d "${APP_LOG_DIR}" ]; then
  mkdir -p ${APP_LOG_DIR}
fi

#
JAVA_OPT="${JAVA_OPT} --add-opens java.base/java.lang=ALL-UNNAMED"
JAVA_OPT="${JAVA_OPT} -server -Xms5000m -Xmx5000m -Xmn1600m"
JAVA_OPT="${JAVA_OPT} -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${APP_LOG_DIR}/ -XX:ErrorFile=${APP_LOG_DIR}/jvm_error_%p.log"
JAVA_OPT="${JAVA_OPT} -Xlog:gc*:file=${APP_LOG_DIR}/gc.log:time,tags:filecount=10,filesize=30M"
JAVA_OPT="${JAVA_OPT} -Dserver.max-http-header-size=524288"
JAVA_OPT="${JAVA_OPT} -Dreactor.netty.pool.leasingStrategy=lifo"
JAVA_OPT="${JAVA_OPT} -DLOG_DIR=${APP_LOG_DIR}"

if [ -f "${TRACE_REPORT_AGENT_FILE}" ]; then
  JAVA_OPT="${JAVA_OPT} -javaagent:${TRACE_REPORT_AGENT_FILE}"
  JAVA_OPT="${JAVA_OPT} -Dotel.traces.sampler=parentbased_traceidratio"
  JAVA_OPT="${JAVA_OPT} -Dotel.traces.sampler.arg=0.3"
  JAVA_OPT="${JAVA_OPT} -Dotel.javaagent.exclude-classes=com.alibaba.nacos.*"
  JAVA_OPT="${JAVA_OPT} -Dotel.resource.attributes=service.name=${LIVENESS_ENV}-${APP_NAME}"
  JAVA_OPT="${JAVA_OPT} -Dotel.exporter.otlp.headers=Authentication=${TRACE_REPORT_TOKEN}"
  JAVA_OPT="${JAVA_OPT} -Dotel.exporter.otlp.endpoint=${TRACE_REPORT_ADDRESS}"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.logFile=${TRACE_REPORT_LOG_FILE}"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.defaultLogLevel=error"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.dateTimeFormat=YYYY-MM-dd_HH:mm:ss.SSS"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.showDateTime=true"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.showShortLogName=true"
  JAVA_OPT="${JAVA_OPT} -Dio.opentelemetry.javaagent.slf4j.simpleLogger.levelInBrackets=true"
fi

JAVA_AFTER_OPT="${JAVA_AFTER_OPT} --spring.config.location=${RESOURCES_PATH}"

if [ ! -f "${USR_DEPLOY_FILE}" ]; then
  ln -s ${APP_HOME}/target/deploy.sh ${USR_DEPLOY_FILE}
fi


if [ -z "${JAVA_HOME}" ]; then
  JAVA=/usr/local/jdk-11.0.17/bin/java
else
  JAVA=${JAVA_HOME}/bin/java
fi

usage() {
    echo "Usage: $PROG_NAME {start|stop|restart}"
    exit 2
}

health_check() {
    exptime=0
    echo "checking ${HEALTH_CHECK_URL}"
    while true
        do
            status_code=`/usr/bin/curl -L -o /dev/null --connect-timeout 5 -s -w %{http_code} ${HEALTH_CHECK_URL}`
            if [ "$?" != "0" ]; then
               echo -n -e "\rapplication not started"
            else
                echo "code is $status_code"
                if [ $status_code = 200 ]; then
                    break
                fi
            fi
            sleep 1
            exptime=$(( $exptime+1 ))

            echo -e "application starting cost time: $exptime..."

            if [ $exptime -gt ${APP_START_TIMEOUT} ]; then
                echo "app start failed cost $exptime s"
                exit 2
            fi
        done
    echo "check ${HEALTH_CHECK_URL} success, application start ok cost `expr $exptime` s"
}

start_application() {
    echo "starting java process:"
    echo "${JAVA} $JAVA_OPT -jar ${JAR_PATH} ${JAVA_AFTER_OPT} > ${JAVA_OUT} 2>&1 &"
    nohup ${JAVA} $JAVA_OPT -jar ${JAR_PATH} ${JAVA_AFTER_OPT} > ${JAVA_OUT} 2>&1 &
    echo "started java process"
}

stop_application() {
   appjavapid=`ps -ef | grep java | grep ${JAR_NAME} | grep -v grep |grep -v 'deploy.sh'| awk '{print$2}'`

   if [ ! $appjavapid ]; then
      echo -e "\rno java process"
      return
   fi

   echo "stop the application ${JAR_NAME} pid is $appjavapid"

   times=60
   for e in $(seq 60)
   do
        COSTTIME=$(($times - $e ))
        appjavapid=`ps -ef | grep java | grep ${JAR_NAME} | grep -v grep |grep -v 'deploy.sh'| awk '{print$2}'`
        if [ -n "$appjavapid" ]; then
            kill $appjavapid
            echo -e  "\r        -- stopping java lasts `expr $COSTTIME` seconds."
        else
            echo -e "\rjava process has exited"
            break;
        fi
        sleep 1
   done
   if [ -n "$appjavapid" ]; then
      echo -e "java process ${JAR_NAME} timeout, now force kill."
      kill -9 $appjavapid
   fi
   if [ -n "$appjavapid" ]; then
      echo -e "\r${JAR_NAME} stop fail"
      exit 2
   fi
   echo -e "\r${JAR_NAME} stop success"
}

start() {
    JAVA_OPT="${JAVA_OPT} -Dspring.profiles.active=${1}"
    JAVA_OPT="${JAVA_OPT} -Dlog4j.configurationFile=file:${RESOURCES_PATH}log4j2-${1}.xml"
    JAVA_AFTER_OPT="${JAVA_AFTER_OPT} --logging.config=file:${RESOURCES_PATH}log4j2-${1}.xml"
    start_application
    health_check
}

stop() {
    stop_application
}

logs() {
   ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" | head -n 1`
   # shellcheck disable=SC2005
   echo "`date '+%Y-%m-%d %H:%M:%S.%N'` ERROR [$ip] [0] [shell-monitor-0] shell-monitor             :${JAR_NAME} liveness check fail will start" >> ${APP_LOG_DIR}/logstash.log
}

liveness() {
   appjavapid=`ps -ef | grep java | grep ${JAR_NAME} | grep -v grep |grep -v 'deploy.sh'| awk '{print$2}'`
   if [ ! $appjavapid ]; then
      echo -e "\rno java process ${JAR_NAME}"
      logs
      start $LIVENESS_ENV
      exit 0
   fi

   uptime=`ps -p $appjavapid -o etimes | awk '{print$1}' | tail -n 1`
   if [ $uptime -lt ${LIVENESS_DELAY_SEC} ]; then
      exit 0
   fi

   status_code=`/usr/bin/curl -L -o /dev/null --retry ${LIVENESS_FAIL} --connect-timeout ${LIVENESS_TIMEOUT_SEC} -s -w %{http_code} ${HEALTH_CHECK_URL}`
   if [ $status_code = 200 ]; then

      exit 0
   else
      logs
      # process deadlocked process
      kill -9 $appjavapid
      start $LIVENESS_ENV
      exit 0
   fi
}

case "$1" in
    start)
        start $2
    ;;
    stop)
        stop
    ;;
    restart)
        stop
        start $2
    ;;
    check)
        health
    ;;
    liveness)
        liveness
    ;;
   readiness)
        health_check
    ;;
    *)
        echo "start dev|uat|prd or stop or restart dev|uat|prd or liveness or readiness"
    ;;
esac
