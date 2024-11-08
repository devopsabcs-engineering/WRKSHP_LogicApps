param (
    [Parameter()]
    [string]
    $instanceNumber = "006",
    [Parameter()]
    [string]
    $resourceGroupName = "rg-iac-pipeline-$instanceNumber",
    [Parameter()]
    [string]
    $deploymentName = "iac-deployment-$instanceNumber",
    [Parameter()]
    [string]
    $templateFilePath = "infra/main.bicep",
    [Parameter()]
    [string]
    $location = "canadacentral"
)

# echo parameters
Write-Output "instanceNumber: $instanceNumber"
Write-Output "resourceGroupName: $resourceGroupName"
Write-Output "deploymentName: $deploymentName"
Write-Output "templateFilePath: $templateFilePath"
Write-Output "location: $location"

az group create --name $resourceGroupName `
    --location "$location"

az deployment group create --resource-group $resourceGroupName `
    --name $deploymentName `
    --template-file $templateFilePath