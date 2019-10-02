#Brian's Notes for setup and demo

#STEP 1 - Set up backend

#NOTE: Code in https://github.com/jaydestro/app30-docs should be moved to https://github.com/microsoft/ignite-learning-paths/tree/master/apps/apps30
#NOTE: error if you use your own subscription - The client 'bbenz@microsoft.com' with object id '70114126-ddd5-4779-bd2b-e47d75a9cfb5' does not have authorization to perform action 'Microsoft.Resources/subscriptions/resourcegroups/write' over scope '/subscriptions/14318ef1-1b03-4cb1-b842-0864d99c875f/resourcegroups/bbigniteapps30' or the scope is invalid. If access was recently granted, please refresh your credentials.
#NOTE: change the names of the Cosmos and SQL DBs - Operation failed with status: 'BadRequest'. Details: DatabaseAccount name 'apps30twtnosql' already exists.
#ActivityId: 875b2218-e16b-11e9-8dea-0a580af4b722, Microsoft.Azure.Documents.Common/2.7.0
#NOTE: list-connection-strings will be deprected.  
#Changed 
#az cosmosdb list-connection-strings --name $cosmosdbname  --resource-group $azureResourceGroup --query connectionStrings[0].connectionString -o tsv --subscription $subname 
#to
#az cosmosdb keys list --name $cosmosdbname  --resource-group $azureResourceGroup --query connectionStrings[0].connectionString --type connection-strings -o tsv

#create-db.sh with subscriptions removed and cosmosdb connection string query update: 

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

cosmosConnectionString=$(az cosmosdb keys list --name $cosmosdbname  --resource-group $azureResourceGroup --query connectionStrings[0].connectionString --type connection-strings -o tsv)

# Create Azure SQL Insance
az sql server create --location $location --resource-group $azureResourceGroup --name $sqldbname --admin-user $adminUser --admin-password $adminPassword 
az sql server firewall-rule create --resource-group $azureResourceGroup --server $sqldbname --name azure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 
az sql db create --resource-group $azureResourceGroup --server $sqldbname --name tailwind 
sqlConnectionString=$(az sql db show-connection-string --server $sqldbname --name tailwind -c ado.net )


echo $cosmosConnectionString
echo $sqlConnectionString

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

cosmosConnectionString=$(az cosmosdb keys list --name $cosmosdbname  --resource-group $azureResourceGroup --query connectionStrings[0].connectionString --type connection-strings -o tsv)

# Create Azure SQL Insance
az sql server create --location $location --resource-group $azureResourceGroup --name $sqldbname --admin-user $adminUser --admin-password $adminPassword 
az sql server firewall-rule create --resource-group $azureResourceGroup --server $sqldbname --name azure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 
az sql db create --resource-group $azureResourceGroup --server $sqldbname --name tailwind 
sqlConnectionString=$(az sql db show-connection-string --server $sqldbname --name tailwind -c ado.net )


echo $cosmosConnectionString
echo $sqlConnectionString
#Go to https://github.com/jaydestro/app30-docs

#Fork and clone to cloud shell
git clone https://github.com/bbenz/app30-docs.git
cd app30-docs
bash create-db.sh


Save the vars:
mongodb://bbapps30twtnosql:1B1uiKa3O4PwUcGgQG1b74i2xn9UmrwFbYoMJ12iBC1hjjvMEgAyq1DIsjHFUmSUetySDw3wU8xvnOebxACvEA==@bbapps30twtnosql.documents.azure.com:10255/?ssl=true&replicaSet=globaldb
"Server=tcp:bbapps30twtsql.database.windows.net,1433;Database=tailwind;User ID=<username>;Password=<password>;Encrypt=true;Connection Timeout=30;"


#STEP 2 - Set up front end

#NOTE: Better to use the previous resource group?
#If so, no need to set up (az group create --name $azureResourceGroup --location $location)

#In cloud shell
#Set env vars
azureResourceGroup=bbapps30
adminUser=twtadmin
adminPassword=twtapps30pD
location=eastus2
cosmosdbname=bbapps30twtnosql
sqldbname=bbapps30twtsql

vnetname=bbigniteapps30vnet
acrname=bbigniteapps30acr
applanname=bbigniteapps30plan
webappname=bbtwtwebapp30

#Added this a few steps earlier (originally after acr create) - Best to do this before session starts

mkdir igniteapps30
git clone https://github.com/anthonychu/TailwindTraders-Website.git igniteapps30/ 
cd igniteapps30/Source/Tailwind.Traders.Web
git checkout monolith 

#Code with --subscription removed and env vars added

az network vnet create --name $vnetname --resource-group $azureResourceGroup --subnet-name default
az acr create --resource-group $azureResourceGroup --name $acrname --sku Basic --admin-enabled true
az acr build --registry $acrname --image twtapp:v1 .

# set password for ACR in env vars
acrpw=$(az acr credential show -n $acrname | jq -r .passwords[0].value)

#While the build runs, in a separate WSL Window:

#Set env vars again
azureResourceGroup=bbapps30
adminUser=twtadmin
adminPassword=twtapps30pD
location=eastus2
cosmosdbname=bbapps30twtnosql
sqldbname=bbapps30twtsql
vnetname=bbigniteapps30vnet
acrname=bbigniteapps30acr
acrimagename=twtapp:v1
applanname=bbigniteapps30plan
webappname=bbtwtwebapp30
randomstring=b76brte23876

#Set up app service
az appservice plan create --name $applanname --resource-group $azureResourceGroup --sku B1 --is-linux 

#Check for ACR build
#Deploy to Web App

az webapp create --resource-group $azureResourceGroup --plan $applanname --name $webappname --deployment-container-image-name ${acrname}.azurecr.io/${acrimagename}

# multi container instance

```bash
# replace values in yaml file with sed (on bsd/macOS, omit '' on gnu/Linux)
cp deploy-aci-example.yaml deploy-aci.yaml
sed -i "s/\$image/${acrname}.azurecr.io\/${acrimagename}/" deploy-aci.yaml
sed -i "s/\$dnsNameLabel/aci${randomstring}/" deploy-aci.yaml
sed -i "s/\$server/${acrname}.azurecr.io/" deploy-aci.yaml
sed -i "s/\$username/$acrname/" deploy-aci.yaml
sed -i "s?\$password?${acrpw}?" deploy-aci.yaml
cat deploy-aci.yaml

# create multi-container instance
az container create --resource-group $azureResourceGroup --name aci${randomstring} --file deploy-aci.yaml

# test

```bash

CONTAINER_INSTANCE_IP_FQDN=$(az container show -g $azureResourceGroup -n aci${randomstring} | jq -r .ipAddress.fqdn)

CONTAINER_INSTANCE_IP_FQDN=$(az container show -g $azureResourceGroup -n aci${randomstring} | jq -r .ipAddress.ip)

# curl application
curl "${CONTAINER_INSTANCE_IP_FQDN}:8080"

# open application
echo "http://${CONTAINER_INSTANCE_IP_FQDN}:8080"

```
# show container events
az container show -g $azureResourceGroup -n aci${randomstring} | jq .containers[0].instanceView.events[]
# show container logs
az container logs --resource-group $azureResourceGroup --name aci${randomstring} --container-name application



