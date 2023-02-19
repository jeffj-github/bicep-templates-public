// Purpose: Create a Virtual Network with a single subnet and an NSG with default rules, then attach the NSG to subnet 1.
// Author: Jeff Johnson

param lockRg bool

param virtualNetworkName string = 'VNet1'

param subnet1Name string = 'Subnet1'

param vnetAddressSpace string = '10.0.0.0/16'

param subnet1AddressSpace string = '10.0.0.0/24'

param nsgName string = 'NSG1'

param rgFunction string

param rgSystemOwner string

param rgDataOwner string

@allowed([
  'Prod'
  'Test'
  'Dev'
  'QA'
])
param rgEnvironment string

@allowed([
  '1'
  '2'
  '3'
  '4'
  '5'
])
param rgCriticality string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: resourceGroup().location
  properties: {
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualNetworkName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1AddressSpace
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }

  resource subnet1 'subnets' existing = {
    name: subnet1Name
  }
}

resource rgTags 'Microsoft.Resources/tags@2022-09-01' = {
  name: 'default'
  scope: resourceGroup()
  properties: {
    tags: {
      Environment: rgEnvironment
      Criticality: rgCriticality
      SystemOwner: rgSystemOwner
      DataOwner: rgDataOwner
      Function: rgFunction
    }
  }
}

resource rgLock 'Microsoft.Authorization/locks@2020-05-01' = if (lockRg) {
  name: '${resourceGroup().name}-Lock'
  scope: resourceGroup()
  properties: {
    level: 'CanNotDelete'
  }
}
