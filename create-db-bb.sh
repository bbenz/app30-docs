#!/bin/bash
set -e

# Credentials and DB name
azureResourceGroup=mittapps30bbenz
adminUser=twtadmin
adminPassword=twtapps30pD
location=eastus2
cosmosdbname=mittapps30nosql
sqldbname=mittapps30sql

# Create Resource Group
az group create --name $azureResourceGroup --location $location

# Create Azure Cosmos DB
az cosmosdb create --name $cosmosdbname --resource-group $azureResourceGroup --kind MongoDB 

cosmosConnectionString=$(az cosmosdb key list --name $cosmosdbname  --resource-group $azureResourceGroup --query connectionStrings[0].connectionString --type connection-strings -o tsv)

# Create Azure SQL Insance
az sql server create --location $location --resource-group $azureResourceGroup --name $sqldbname --admin-user $adminUser --admin-password $adminPassword 
az sql server firewall-rule create --resource-group $azureResourceGroup --server $sqldbname --name azure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 
az sql db create --resource-group $azureResourceGroup --server $sqldbname --name tailwind 
sqlConnectionString=$(az sql db show-connection-string --server $sqldbname --name tailwind -c ado.net )


echo $cosmosConnectionString
echo $sqlConnectionString