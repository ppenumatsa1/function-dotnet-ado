
# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="northcentralus"
resourceGroup="rg-panda-ncus"
tag="create-function-app-premium-plan"
storage="pandapocsa$randomIdentifier"
premiumPlan="panda-prem-plan-ncus-$randomIdentifier"
functionApp="panda-fap-ncus-$randomIdentifier"
skuStorage="Standard_LRS"
skuStoragepoc="Standard_GZRS"
skuPlan="EP1"
functionsVersion="4"

# Create a resource group
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tags $tag

# Create an Azure storage account in the resource group.
echo "Creating $storage"
az storage account create --name $storage --location "$location" --resource-group $resourceGroup --sku $skuStorage

# Create a Premium plan
echo "Creating $premiumPlan"
az functionapp plan create --name $premiumPlan --resource-group $resourceGroup --location "$location" --is-linux=true --sku $skuPlan

# Create a Function App
echo "Creating $functionApp"
az functionapp create --name $functionApp --storage-account $storage --plan $premiumPlan --resource-group $resourceGroup --runtime dotnet --runtime-version 6.0 --disable-app-insights --functions-version $functionsVersion 

# sleep for 30 Seconds
echo "Sleeping for 30 Seconds"
sleep 30

# Deploy code to Function APP
func azure functionapp publish $functionApp


# Clean up Resource Group
# az group delete --name $resourceGroup

# delete blobs in a container -- add auth or account-key 
az storage blob delete-batch -s testcontainer --pattern *.txt --account-name sapandapocdl

