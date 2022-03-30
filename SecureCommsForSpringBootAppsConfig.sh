#!/bin/bash
# Author: Mark A. Heckler

# REQUIREMENTS
## git clone <repo with both SB apps, including .jar files>
## Azure CLI (az)
## Azure CLI Spring Cloud plugin/module

# MH: Best to avoid for customers
# az configure --defaults group=$ASC_RESOURCE_GROUP location=$ASC_LOCATION spring-cloud=$ASC_SPRING_CLOUD

# Resource group config
echo '>> az group create -l $ASC_LOCATION -g $ASC_RESOURCE_GROUP --subscription $ASC_SUBSCRIPTION'
az group create -l $ASC_LOCATION -g $ASC_RESOURCE_GROUP --subscription $ASC_SUBSCRIPTION

# Azure Spring Cloud config
echo '>> az spring-cloud create -n $ASC_SPRING_CLOUD -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION'
az spring-cloud create -n $ASC_SPRING_CLOUD -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION

# Azure Key Vault config
echo '>> az keyvault create -n $KV_NAME -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION'
az keyvault create -n $KV_NAME -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION

export KEY_VAULT_URI=$(az keyvault show -n $KV_NAME -g $ASC_RESOURCE_GROUP --query properties.vaultUri --output tsv)

echo '>> az keyvault certificate create --vault-name ${KV_NAME} -n ${SERVER_SSL_CERTIFICATE_NAME} -p "$(az keyvault certificate get-default-policy)"'
az keyvault certificate create --vault-name ${KV_NAME} -n ${SERVER_SSL_CERTIFICATE_NAME} -p "$(az keyvault certificate get-default-policy)"

## MH: Skip config server configuration, not relevant to this Learn module
## MH: Skipping the section for "Create the gateway app" under "Create Apps in Azure Spring Cloud"

# Database (CosmosDB SQL variant)
# echo '>> az cosmosdb create -n $COSMOSDB_ACCOUNT -g $ASC_RESOURCE_GROUP'
# az cosmosdb create -n $COSMOSDB_ACCOUNT -g $ASC_RESOURCE_GROUP
# echo '>> az cosmosdb sql database create -a $COSMOSDB_ACCOUNT -n $COSMOSDB_NAME -g $ASC_RESOURCE_GROUP'
# az cosmosdb sql database create -a $COSMOSDB_ACCOUNT -n $COSMOSDB_NAME -g $ASC_RESOURCE_GROUP
# echo '>> az cosmosdb sql container create -a $COSMOSDB_ACCOUNT -d $COSMOSDB_NAME -n $COSMOS_CONTAINER -p $COSMOS_DATA_PART -g $ASC_RESOURCE_GROUP'
# az cosmosdb sql container create -a $COSMOSDB_ACCOUNT -d $COSMOSDB_NAME -n $COSMOS_CONTAINER -p $COSMOS_DATA_PART -g $ASC_RESOURCE_GROUP

# export COSMOS_KEY=$(az cosmosdb keys list -n $COSMOSDB_ACCOUNT -g $ASC_RESOURCE_GROUP --query primaryMasterKey --output tsv)
# export COSMOS_URL=$(az cosmosdb show -n $COSMOSDB_ACCOUNT -g $ASC_RESOURCE_GROUP --query documentEndpoint --output tsv)

# Database (Azure SQL Database, i.e. hosted SQL Server) - fails creating db in centralus
# echo "Creating $SQLSERVER in $ASC_LOCATION..."
# az sql server create -n $SQLSERVER -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION -u $SQLSERVER_ADMIN -p $SQLSERVER_PW

# echo "Creating $SQLSERVER_DB on $SQLSERVER..."
# az sql db create -n $SQLSERVER_DB -g $ASC_RESOURCE_GROUP -s $SQLSERVER

# Database (Azure for MySQL)
echo "Creating $MYSQL in $ASC_LOCATION..."
az mysql server create -n $MYSQL -g $ASC_RESOURCE_GROUP -l $ASC_LOCATION -u $MYSQL_USER -p $MYSQL_PW

echo "Creating $MYSQL_DB on $MYSQL..."
az mysql db create -n $MYSQL_DB -g $ASC_RESOURCE_GROUP -s $MYSQL
# MH: Investigate/expand
# export MYSQL_URL=$(az mysql db show -n $MYSQL_DB -g $ASC_RESOURCE_GROUP --query documentEndpoint --output tsv)

# MH: Get Outbound IP addresses for ASC instance
# 20.109.209.218, 20.109.210.3
export MYSQL_IP1=$(az spring-cloud show -n $ASC_SPRING_CLOUD -g $ASC_RESOURCE_GROUP --query "properties.networkProfile.outboundIPs.publicIPs[0]" --output tsv)
export MYSQL_IP2=$(az spring-cloud show -n $ASC_SPRING_CLOUD -g $ASC_RESOURCE_GROUP --query "properties.networkProfile.outboundIPs.publicIPs[1]" --output tsv)
az mysql server firewall-rule create -n allowip1 -g $ASC_RESOURCE_GROUP -s $MYSQL --start-ip-address $MYSQL_IP1 --end-ip-address $MYSQL_IP1
az mysql server firewall-rule create -n allowip2 -g $ASC_RESOURCE_GROUP -s $MYSQL --start-ip-address $MYSQL_IP2 --end-ip-address $MYSQL_IP2

## Cosmos/Mongo option (awaiting capacity)
# az cosmosdb create -n mkheck-my-test-account -g $ASC_RESOURCE_GROUP --kind MongoDB --server-version 4.0
# az cosmosdb mongodb database create -a mkheck-my-test-account -n mkheck-my-test-db -g $ASC_RESOURCE_GROUP --verbose

# ==== Create the internal-service app ====
# az spring-cloud app delete -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD
echo '>> az spring-cloud app create -n $APP_INT_ID'
az spring-cloud app create -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD \
    --instance-count 1 \
    --memory 2Gi \
    --runtime-version Java_11 \
    --env KEY_VAULT_URI=$KEY_VAULT_URI \
          SERVER_SSL_CERTIFICATE_NAME=$SERVER_SSL_CERTIFICATE_NAME \
          APP_INT_ID=$APP_INT_ID \
          MYSQL_URL=$MYSQL_URL MYSQL_USERNAME=$MYSQL_USERNAME MYSQL_PW=$MYSQL_PW

echo '>> az spring-cloud app identity assign -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD'
az spring-cloud app identity assign -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD

export INTERNAL_SERVICE_IDENTITY=$(az spring-cloud app show -n $APP_INT_ID \
    -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD --query identity.principalId --output tsv)

echo '>> az keyvault set-policy -n $KV_NAME'
az keyvault set-policy -n $KV_NAME -g $ASC_RESOURCE_GROUP \
   --object-id $INTERNAL_SERVICE_IDENTITY  --certificate-permissions get list \
   --key-permissions get list --secret-permissions get list

# ==== Create the external-service app ====
# az spring-cloud app delete -n $APP_EXT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD
echo '>> az spring-cloud app create -n $APP_EXT_ID'
az spring-cloud app create -n $APP_EXT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD \
    --instance-count 1 \
    --memory 2Gi \
    --runtime-version Java_11 --assign-endpoint true \
    --env KEY_VAULT_URI=$KEY_VAULT_URI \
          SERVER_SSL_CERTIFICATE_NAME=$SERVER_SSL_CERTIFICATE_NAME
        #   EXTERNAL_SERVICE_PORT=$EXTERNAL_SERVICE_PORT

echo '>> az spring-cloud app identity assign -n $APP_EXT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD'
az spring-cloud app identity assign -n $APP_EXT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD
export EXTERNAL_SERVICE_IDENTITY=$(az spring-cloud app show -n $APP_EXT_ID \
    -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD --query identity.principalId --output tsv)

echo '>> az keyvault set-policy -n $KV_NAME'
az keyvault set-policy -n $KV_NAME -g $ASC_RESOURCE_GROUP \
   --object-id $EXTERNAL_SERVICE_IDENTITY --certificate-permissions get list \
   --key-permissions get list --secret-permissions get list

# Useful to know where to go to access the app without checking the portal
export EXTERNAL_URL=$(az spring-cloud app show -n $APP_EXT_ID \
    -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD --query properties.url --output tsv)
