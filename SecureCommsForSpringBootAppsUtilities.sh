#!/bin/bash
# Author: Mark A. Heckler

# Monitoring/kill/cleanup scripts

## Configure defaults so the az client can selectively ignore provided command line parameters
## Example: Creating CosmosDB MongoDB instance
## Again, better to avoid overriding someone's defaults & potentilly affecting their corporate config
az configure --defaults group=$ASC_RESOURCE_GROUP location=$ASC_LOCATION spring-cloud=$ASC_SPRING_CLOUD

## Logs
### Tailing
az spring-cloud app logs -n $APP_EXT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD -f
az spring-cloud app logs -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD -f

### See more
az spring-cloud app logs -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD --lines 200

## List keys for CosmosDB account
az cosmosdb keys list -n $COSMOSDB_ACCOUNT -g $ASC_RESOURCE_GROUP

## List all apps in this ASC instance
az spring-cloud app list -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD

## List all databases in Azure Database for MySQL "server"
az mysql db list -g $ASC_RESOURCE_GROUP -s $MYSQL

## App delete
az spring-cloud app delete -n $APP_INT_ID -g $ASC_RESOURCE_GROUP -s $ASC_SPRING_CLOUD

## List resource groups for this account
az group list | jq -r '.[].name'
or
az group list --query "[].name" --output tsv

## Burn it to the ground
az group delete -g $ASC_RESOURCE_GROUP --subscription $ASC_SUBSCRIPTION -y

## Azure Spring cloud stop (pause, deep freeze, save for later)
az spring-cloud stop -n $ASC_SPRING_CLOUD -g $ASC_RESOURCE_GROUP

## Create/deploy script runner, timer, logger
time <script> | tee deployoutput.txt