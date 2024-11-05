@description('The datacenter to use for the deployment.')
param location string
param logicAppSystemAssignedIdentityTenantId string
param logicAppSystemAssignedIdentityObjectId string
param sa_name string = 'sa'
param connections_azureblob_name string = 'azureblob'

var storageAccountName = '${toLower(sa_name)}${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    allowBlobPublicAccess: true
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }

  // blob services
  resource blobServices 'blobServices@2023-05-01' = {
    name: 'default'

    resource sa_default_blobs 'containers@2023-05-01' = {
      name: 'blobs'
      properties: {
        defaultEncryptionScope: '$account-encryption-key'
        denyEncryptionScopeOverride: false
        publicAccess: 'Container'
      }
    }
  }
}

resource connections_azureblob_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_azureblob_name
  location: location
  kind: 'V2'
  properties: {
    displayName: 'privatestorage'
    parameterValues: {
      accountName: storageAccountName
      accessKey: concat(listKeys(
        '${resourceGroup().id}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}',
        '2023-05-01'
      ).keys[0].value)
    }
    api: {
      //id: resourceId('Microsoft.Web/locations/managedApis', location, 'azureblob')
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
    }
  }
  dependsOn: [
    sa
  ]

  resource connections_azureblob_name_logicAppSystemAssignedIdentityObjectId 'accessPolicies@2016-06-01' = {
    //parent: connections_azureblob_name_resource
    name: logicAppSystemAssignedIdentityObjectId
    location: location
    properties: {
      principal: {
        type: 'ActiveDirectory'
        identity: {
          tenantId: logicAppSystemAssignedIdentityTenantId
          objectId: logicAppSystemAssignedIdentityObjectId
        }
      }
    }
  }
}

output blobendpointurl string = connections_azureblob_name_resource.properties.connectionRuntimeUrl
