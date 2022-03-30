#!/bin/bash
# Author: Mark A. Heckler

# REQUIREMENTS
## git clone <repo with both SB apps, including .jar files>
## Azure CLI (az)
## Azure CLI Spring Cloud plugin/module

# Establish seed for random naming
export RANDOMIZER=$RANDOM

# Azure Spring Cloud and (at times) EventHubs, Key Vault
# export ASC_SUBSCRIPTION='Visual Studio Enterprise Subscription'
export ASC_SUBSCRIPTION='ca-markheckler-demo-test'

# export ASC_RESOURCE_GROUP='mkheck-sceast-rg'
# export ASC_LOCATION='eastus'
# export ASC_SPRING_CLOUD='mkheck-sceast-asc'
export ASC_RESOURCE_GROUP='mkheck-'$RANDOMIZER'-rg'
export ASC_LOCATION='centralus'
export ASC_SPRING_CLOUD='mkheck-'$RANDOMIZER'-asc'

# MH: Best to avoid for customers
# az configure --defaults group=$ASC_RESOURCE_GROUP location=$ASC_LOCATION spring-cloud=$ASC_SPRING_CLOUD
# az account set --subscription $ASC_SUBSCRIPTION

# Key Vault
# export KV_NAME='mkheck-sceast-vault'
# export KV_BLOGSTORE='mkhecksceaststore'
export KV_NAME='mkheck-'$RANDOMIZER'-vault'
export KV_BLOGSTORE='mkheck'$RANDOMIZER'store'
export KEY_VAULT_URI=

export APP_EXT_ID='external-service'
export APP_INT_ID='minternal-service'

export EXTERNAL_SERVICE_PORT=443

export EXTERNAL_SERVICE_IDENTITY=
export INTERNAL_SERVICE_IDENTITY=

export EXTERNAL_URL=

export SERVER_SSL_CERTIFICATE_NAME='mkheck-ss-lmcert'

export EXTERNAL_SERVICE_JAR=./$APP_EXT_ID/target/$APP_EXT_ID-0.0.1-SNAPSHOT.jar
export INTERNAL_SERVICE_JAR=./$APP_INT_ID/target/$APP_INT_ID-0.0.1-SNAPSHOT.jar

# Database
# export COSMOSDB_ACCOUNT='mkheck-sceast-sqlacct'
# export COSMOSDB_NAME='mkheck-sceast-sqldb'

# export COSMOSDB_ACCOUNT='mkheck-'$RANDOMIZER'-sqlacct'
# export COSMOSDB_NAME='mkheck-'$RANDOMIZER'-sqldb'
# export COSMOS_CONTAINER='data'
# export COSMOS_DATA_PART='/name/last'
# export COSMOS_KEY=
# export COSMOS_URL=

# export SQLSERVER='mkheck-azuresql-server-'$RANDOMIZER
# export SQLSERVER_DB='msdocsazuresqldb'$RANDOMIZER
# export SQLSERVER_ADMIN='azureuser'
# export SQLSERVER_PW='Pa$$w0rD-'$RANDOMIZER

export MYSQL='mkheck-mysql-server-'$RANDOMIZER
export MYSQL_DB='mkheckmysqldb'$RANDOMIZER
export MYSQL_USER='mysqluser'
export MYSQL_USERNAME='mysqluser@'$MYSQL
export MYSQL_PW='Pa$$w0rD-'$RANDOMIZER
export MYSQL_URL='jdbc:mysql://'$MYSQL'.mysql.database.azure.com:3306/'$MYSQL_DB'?serverTimezone=UTC'
export MYSQL_IP1=
export MYSQL_IP2=
