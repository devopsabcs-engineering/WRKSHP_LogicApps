# create resource group
$resourceGroupName = "rg-logicapp-001"
$location = "Canada Central"
$deploymentName = "logicapp-001"
$templateFilePath = "./src/logic-app-as2-send-receive/main.bicep"

az group create --name $resourceGroupName --location "$location"

az deployment group create --resource-group $resourceGroupName `
    --name $deploymentName `
    --template-file $templateFilePath