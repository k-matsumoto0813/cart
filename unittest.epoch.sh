#!/bin/sh
http_proxy_host=$(echo $HTTP_PROXY | sed -e 's|^.*://||' -e 's|[:/].*$||')
http_proxy_port=$(echo $HTTP_PROXY | sed -n -e 's|^.*://||' -e 's|/.*$||' -e 's|^.*:\([0-9][0-9]*\)$|\1|p')
https_proxy_host=$(echo $HTTPS_PROXY | sed -e 's|^.*://||' -e 's|[:/].*$||')
https_proxy_port=$(echo $HTTPS_PROXY | sed -n -e 's|^.*://||' -e 's|/.*$||' -e 's|^.*:\([0-9][0-9]*\)$|\1|p')

mkdir /root/.m2
if [ -d "./.m2" ]; then \
    cp -r ./.m2/* /root/.m2/.; \
fi

/usr/local/bin/mvn-entrypoint.sh mvn -q test \
    -Dmaven.wagon.http.ssl.insecure=true \
    -Dmaven.wagon.http.ssl.allowall=true \
    -Dmaven.wagon.http.ssl.ignore.validity.dates=true \
    -Dhttp.proxyHost=${http_proxy_host} \
    -Dhttp.proxyPort=${http_proxy_port} \
    -Dhttps.proxyHost=${https_proxy_host} \
    -Dhttps.proxyPort=${https_proxy_port}

RESULT=$?
if [ $RESULT -ne 0 ]; then
    exit $RESULT
fi

echo "##################################################"
echo " Unit Test coverage"
echo "##################################################"
cat ./target/site/jacoco/jacoco.csv

exit 0
