
# Variable block
let "randomIdentifier=$RANDOM*$RANDOM"
location="southcentralus"
resourceGroup="rg-panda-scus1"
tag="create-function-app-premium-plan"
storage="pandapocsa$randomIdentifier"
premiumPlan="panda-prem-plan-scus-$randomIdentifier"
functionApp="panda-fap-scus-$randomIdentifier"
skuStorage="Standard_LRS"
skuPlan="EP1"
functionsVersion="4"

# Create a resource group
echo "Creating resource group $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tags $tag

# Create an Azure storage account for Function APP.
echo "Creating storage account $storage for Function APP"
az storage account create --name $storage --location "$location" --resource-group $resourceGroup --sku $skuStorage


# Create an Azure storage account in the resource group.
echo "Creating Storage Account pandapocfapsa0317"
az storage account create --name pandapocfapsa0317 --location "$location" --resource-group $resourceGroup --enable-hierarchical-namespace true --sku Standard_GRS

# Create a Premium plan
echo "Creating Function Premium Plan $premiumPlan"
az functionapp plan create --name $premiumPlan --resource-group $resourceGroup --location "$location" --is-linux=true --sku $skuPlan

# Create a Function App
echo "Creating Function App $functionApp"
az functionapp create --name $functionApp --storage-account $storage --plan $premiumPlan --resource-group $resourceGroup --runtime dotnet --runtime-version 6.0  --functions-version $functionsVersion 

# sleep for 30 Seconds
sleep 30

# Deploy code to Function APP
func azure functionapp publish $functionApp


# Clean up Resource Group
# az group delete --name $resourceGroup


# Delete Blobs in the Container
# az storage blob delete-batch -s testcontainer --pattern *.txt --account-name sapandapocdl 

