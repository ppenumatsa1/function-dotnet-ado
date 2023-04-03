
# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="southcentralus"
resourceGroup="rg-panda-scus"
tag="create-function-app-premium-plan"
storage="pandapocsa$randomIdentifier"
premiumPlan="panda-prem-plan-scus-$randomIdentifier"
functionApp="panda-fap-scus-$randomIdentifier"
keyValutName="kvfuncmsisc$randomIdentifier"
secretName="sapandapocconn"
skuStorage="Standard_LRS"
skuPlan="EP1"
functionsVersion="4"

# Create a resource group
echo "Creating resource group $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tags $tag

# Create an Azure storage account for Function APP.
echo "Creating storage account $storage for Function APP"
az storage account create --name $storage --location "$location" --resource-group $resourceGroup --sku $skuStorage


# Create an Azure storage account for the POC
echo "Creating Storage Account pandapocfapsa0317"
az storage account create --name pandapocfapsa0317 --location "$location" --resource-group $resourceGroup --enable-hierarchical-namespace true --sku Standard_GRS
saconnString=$(az storage account show-connection-string --name pandapocfapsa0317 --resource-group $resourceGroup -o tsv)


# Create a Premium plan
echo "Creating Function Premium Plan $premiumPlan"
az functionapp plan create --name $premiumPlan --resource-group $resourceGroup --location "$location" --is-linux=true --sku $skuPlan

# Create a Function App
echo "Creating Function App $functionApp"
az functionapp create --name $functionApp --storage-account $storage --plan $premiumPlan --resource-group $resourceGroup --runtime dotnet --runtime-version 6.0 --assign-identity --functions-version $functionsVersion 
principalId=$(az functionapp identity show -n $functionApp -g $resourceGroup --query principalId -o tsv)


# Create Key Vault to Store Secrets
echo "Creating Key Vault $keyValutName"
az keyvault create -n $keyValutName -g $resourceGroup


# Save Secret in Key Vault, Grant Permission to KeyVault from MSI , update Function APP with Secret Reference
echo "Saving Secret in KeyValut $keyValutName"
az keyvault secret set -n $secretName --vault-name $keyValutName --value $saconnString
secretId=$(az keyvault secret show -n $secretName --vault-name $keyValutName --query "id" -o tsv)
az keyvault set-policy -n $keyValutName -g $resourceGroup --object-id $principalId --secret-permissions get
az functionapp config appsettings set -n $functionApp -g $resourceGroup --settings "$secretName=@Microsoft.KeyVault(SecretUri=$secretId)"


# Deploy code to Function APP
echo "Deploying functionapp $functionApp"
func azure functionapp publish $functionApp


# Clean up Resource Group
# az group delete --name $resourceGroup


# Delete Blobs in the Container
# az storage blob delete-batch -s testcontainer --pattern *.txt --account-name sapandapocdl 

