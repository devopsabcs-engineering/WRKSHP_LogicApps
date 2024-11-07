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
    $subscriptionId = "64c3d212-40ed-4c6d-a825-6adfbdf25dad",
    [Parameter()]
    [string]
    $workflowName = "Stateful-Workflow"
)

az account show                      
# get logic app name
$logicAppName = az deployment group show --resource-group $resourceGroupName `
    --name $deploymentName `
    --query properties.outputs.logicAppName.value `
    -o tsv
Write-Host "logic app name: $logicAppName"

# get workflow url
Write-Host "getting workflow url"
#$workflowName = "Stateful-Workflow"

# Set your subscription ID and resource group name
#$subscriptionId = "64c3d212-40ed-4c6d-a825-6adfbdf25dad"

# # Select the subscription
# Select-AzSubscription -SubscriptionId $subscriptionId

# # List all workflows in the specified Logic App Standard
# $workflows = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType 'Microsoft.Logic/workflows'

# # Display the workflows
# $workflows | ForEach-Object {
#     Write-Output $_.Name
# }

# # show website
# az webapp show --name $logicAppName --resource-group $resourceGroupName

# # show logic app
# az logicapp list -o table

# # show logic app workflow
# az logicapp show --name $logicAppName --resource-group $resourceGroupName

#do this call
#GET https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Web/sites/$logicAppName/workflows/Stateful-Workflow?api-version=2018-11-01&$expand=connections.json,parameters.json

$uri = "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${logicAppName}/workflows/${workflowName}?api-version=2018-11-01&`$expand=connections.json,parameters.json"
Write-Host "uri: $uri"

# get auth token
$token = az account get-access-token --query accessToken -o tsv

# get workflow
$response = Invoke-RestMethod -Uri $uri -Headers @{Authorization = "Bearer $token" } -Method Get
$response | ConvertTo-Json -Depth 100



$uri = "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${logicAppName}/hostruntime/runtime/webhooks/workflow/api/management/workflows/${workflowName}/triggers?api-version=2024-04-01"
Write-Host "uri: $uri"

# get workflow
$response = Invoke-RestMethod -Uri $uri -Headers @{Authorization = "Bearer $token" } -Method Get
$response | ConvertTo-Json -Depth 100

#https://logic-vvihbnryoetdu.azurewebsites.net:443/api/Stateful-Workflow/triggers/When_a_HTTP_request_is_received/invoke?api-version=2022-05-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=q3hzEo6RkeG2IQF1JmcYkNokOdIzZ_dFAEtmIgIDwt0


# list callback url
$triggerName = "When_a_HTTP_request_is_received"
$uri = "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/sites/${logicAppName}/hostruntime/runtime/webhooks/workflow/api/management/workflows/${workflowName}/triggers/${triggerName}/listCallbackUrl?api-version=2024-04-01"
Write-Host "uri: $uri"

# get workflow
$response = Invoke-RestMethod -Uri $uri `
    -Headers @{Authorization = "Bearer $token" } `
    -Method Post -Body "{}" `
    -ContentType "application/json"

$workflowUrl = $response.value
$response | ConvertTo-Json -Depth 100

Write-Host "workflow url: $workflowUrl"

# test workflow
$uri = $workflowUrl
Write-Host "uri: $uri"

# get workflow
$response = Invoke-RestMethod -Uri $uri `
    -Method Get

$response | ConvertTo-Json -Depth 100

# verify was successful
if ($response.status -eq "Running") {
    Write-Host "Workflow is running"
}
else {
    Write-Host "Workflow is not running"
}