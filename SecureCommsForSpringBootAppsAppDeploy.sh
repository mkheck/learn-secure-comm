#!/bin/bash
# Author: Mark A. Heckler

# REQUIREMENTS
## git clone <repo with both SB apps, including .jar files>
## Azure CLI (az)
## Azure CLI Spring Cloud plugin/module

# Build and deploy apps to Azure Spring Cloud
cd $APP_EXT_ID
mvn clean package -DskipTests
cd ..
echo '>> az spring-cloud app deploy -n $APP_EXT_ID'
az spring-cloud app deploy -n $APP_EXT_ID \
    -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD \
    --artifact-path ${EXTERNAL_SERVICE_JAR} \
    --jvm-options='-Xms2048m -Xmx2048m'

cd $APP_INT_ID
mvn clean package -DskipTests
cd ..
echo '>> az spring-cloud app deploy -n $APP_INT_ID'
az spring-cloud app deploy -n $APP_INT_ID \
    -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD \
    --artifact-path ${INTERNAL_SERVICE_JAR} \
    --jvm-options='-Xms2048m -Xmx2048m'
