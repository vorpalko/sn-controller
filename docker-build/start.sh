#!/usr/bin/env sh

# collectd: modify hostname in config to include app name and timestamp
#           to make monitoring possible
appName="ktorbase"
timestamp=$(date +"%s")
random=$(tr -cd 0-9 </dev/urandom | head -c 3)
hostname="$appName-$timestamp-$random"
echo "Hostname: $hostname"
sed -i "s/{APP_NAME}/$hostname/g" /app/collectd.conf

# collectd: modify server ip in config as it is dependent on environment
echo "Collectd server: $COLLECTD_SERVER_IP"
sed -i "s/{SERVER_IP}/$COLLECTD_SERVER_IP/g" /app/collectd.conf

# collectd: run
collectd -C /app/collectd.conf

# java: run
# https://medium.com/adorsys/jvm-memory-settings-in-a-container-environment-64b0840e1d9e \
# https://blog.codecentric.de/2014/08/string-deduplication-ein-neues-feature-java-8-update-20/ \
java \
    -Dcom.sun.management.jmxremote \
    -Dcom.sun.management.jmxremote.port=3333 \
    -Dcom.sun.management.jmxremote.rmi.port=3333 \
    -Dcom.sun.management.jmxremote.ssl=false \
    -Dcom.sun.management.jmxremote.authenticate=false \
    -Xms1G \
    -Xmx1G \
    -server \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=100 \
    -jar backend-all.jar
