@description('Builtin\\Administrator account\'s name for the Virtual Machines. This is not a domain account.')
param DefaultUserName string = 'svradmin'

@description('Password for the Builtin Administrator account. Default is \'H@ppytimes!\'')
@secure()
param DefaultPassword string = 'H@ppytimes123!'

@description('Provide the workspace name for your Network Diagnostic logs')
param DiagnosticsWorkspaceName string = '<WorkspaceName>'

@description('Provide the workspace subscription GUID for your Network Diagnostic logs')
param DiagnosticsWorkspaceSubscription string = '<WorkspaceSubscriptionID>'

@description('Provide the workspace resourcegroupname for your Network Diagnostic logs')
param DiagnosticsWorkspaceResourceGroup string = '<ResourceGroupName>'

@description('Allowing the ability to enable or disable DDoS on deployment, false is disable, true is enable')
@allowed([
  true
  false
])
param DDOSProtectionConfiguration bool = false

param location string = resourceGroup().location

var VN_Name1 = 'VN-HUB'
var VN_Name2 = 'VN-SPOKE1'
var VN_Name3 = 'VN-SPOKE2'
var VN_Name1Prefix = '10.0.25.0/24'
var VN_Name1Subnet1Name = 'AGWAFSubnet'
var VN_Name1Subnet1Prefix = '10.0.25.64/26'
var VN_Name1Subnet2Name = 'AzureFirewallSubnet'
var VN_Name1Subnet2Prefix = '10.0.25.0/26'
var VN_Name2Prefix = '10.0.27.0/24'
var VN_Name2Subnet1Name = 'SPOKE1-SUBNET1'
var VN_Name2Subnet1Prefix = '10.0.27.0/26'
var VN_Name2Subnet2Name = 'SPOKE1-SUBNET2'
var VN_Name2Subnet2Prefix = '10.0.27.64/26'
var VN_Name3Prefix = '10.0.28.0/24'
var VN_Name3Subnet1Name = 'SPOKE2-SUBNET1'
var VN_Name3Subnet1Prefix = '10.0.28.0/26'
var VN_Name3Subnet2Name = 'SPOKE2-SUBNET2'
var VN_Name3Subnet2Prefix = '10.0.28.64/26'
var Subnet_serviceEndpoints = [
  {
    service: 'Microsoft.Web'
  }
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.Sql'
  }
  {
    service: 'Microsoft.ServiceBus'
  }
  {
    service: 'Microsoft.KeyVault'
  }
  {
    service: 'Microsoft.AzureActiveDirectory'
  }
]
var publicIpAddressName1 = 'SOCNSFWPIP'
var publicIpAddressName2 = 'SOCNSAGPIP'
var fw_name = 'SOC-NS-FW'
var firewallPolicyName = 'SOC-NS-FWPolicy'
var AppGatewayPolicyName = 'SOC-NS-AGPolicy'
var FrontdoorPolicyName = 'SOCNSFDPolicy'
var AG_Name = 'SOC-NS-AG-WAFv2'
var AppGateway_IPAddress = '10.0.25.70'
//var applicationGatewayId = resourceId('Microsoft.Network/applicationGateways', AG_Name)
var FrontDoorName = 'Demowasp-${uniqueString(resourceGroup().id)}'
var RT_Name1 = 'SOC-NS-DEFAULT-ROUTE'
var NSG_Name1 = 'SOC-NS-NSG-SPOKE1'
var NSG_Name2 = 'SOC-NS-NSG-SPOKE2'
var Site_Name1 = 'owaspdirect-${uniqueString(resourceGroup().id)}'
var Site_HPN_var = 'OWASP-ASP'
var NIC_Name1 = 'Nic1'
var NIC_Name2 = 'Nic2'
var NIC_Name3 = 'Nic3'
var NIC_Name1Ipaddress = '10.0.27.4'
var NIC_Name2Ipaddress = '10.0.27.68'
var NIC_Name3Ipaddress = '10.0.28.4'
var DDoSPlanName = 'SOCNSDDOSPLAN'
var VM_Name1 = 'VM-Win11'
var VM_Name2 = 'VM-Kali'
var VM_Name3 = 'VM-Win2019'
var workspaceid = '/subscriptions/${DiagnosticsWorkspaceSubscription}/resourcegroups/${DiagnosticsWorkspaceResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${DiagnosticsWorkspaceName}'

resource VN_1 'Microsoft.Network/virtualNetworks@2020-03-01' = {
  name: VN_Name1
  location: location
  tags: {
    displayName: VN_Name1
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        VN_Name1Prefix
      ]
    }
    enableDdosProtection: DDOSProtectionConfiguration
    enableVmProtection: false
    // ddosProtectionPlan: {
    //   id: DDoSPlan.id
    // }
  }
}

resource VN_Name1_VN_Name1Subnet1 'Microsoft.Network/virtualNetworks/subnets@2020-03-01' = {
  parent: VN_1
  //location: location
  name: '${VN_Name1Subnet1Name}'
  properties: {
    addressPrefix: VN_Name1Subnet1Prefix
    serviceEndpoints: Subnet_serviceEndpoints
  }
}

resource VN_Name1_VN_Name1Subnet2 'Microsoft.Network/virtualNetworks/subnets@2020-03-01' = {
  parent: VN_1
  //location: location
  name: '${VN_Name1Subnet2Name}'
  properties: {
    addressPrefix: VN_Name1Subnet2Prefix
    serviceEndpoints: Subnet_serviceEndpoints
  }
  dependsOn: [

    VN_Name1_VN_Name1Subnet1
  ]
}

// resource VN_Name1_microsoft_insights_VN1Diagnostics 'Microsoft.Network/virtualNetworks/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${VN_Name1}/microsoft.insights/VN1Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'VMProtectionAlerts'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     VN_1
//   ]
// }

resource VN_2 'Microsoft.Network/virtualNetworks@2020-03-01' = {
  name: VN_Name2
  location: location
  tags: {
    displayName: VN_Name2
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        VN_Name2Prefix
      ]
    }
    subnets: [
      {
        name: VN_Name2Subnet1Name
        properties: {
          addressPrefix: VN_Name2Subnet1Prefix
          networkSecurityGroup: {
            id: NSG_1.id
          }
          routeTable: {
            id: RT_1.id
          }
          serviceEndpoints: Subnet_serviceEndpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: VN_Name2Subnet2Name
        properties: {
          addressPrefix: VN_Name2Subnet2Prefix
          networkSecurityGroup: {
            id: NSG_1.id
          }
          routeTable: {
            id: RT_1.id
          }
          serviceEndpoints: Subnet_serviceEndpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// resource VN_Name2_microsoft_insights_VN2Diagnostics 'Microsoft.Network/virtualNetworks/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${VN_Name2}/microsoft.insights/VN2Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'VMProtectionAlerts'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     VN_2
//   ]
// }

resource VN_3 'Microsoft.Network/virtualNetworks@2020-03-01' = {
  name: VN_Name3
  location: location
  tags: {
    displayName: VN_Name3
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        VN_Name3Prefix
      ]
    }
    subnets: [
      {
        name: VN_Name3Subnet1Name
        properties: {
          addressPrefix: VN_Name3Subnet1Prefix
          networkSecurityGroup: {
            id: NSG_2.id
          }
          routeTable: {
            id: RT_1.id
          }
          serviceEndpoints: Subnet_serviceEndpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: VN_Name3Subnet2Name
        properties: {
          addressPrefix: VN_Name3Subnet2Prefix
          networkSecurityGroup: {
            id: NSG_2.id
          }
          routeTable: {
            id: RT_1.id
          }
          serviceEndpoints: Subnet_serviceEndpoints
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// resource VN_Name3_microsoft_insights_VN3Diagnostics 'Microsoft.Network/virtualNetworks/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${VN_Name3}/microsoft.insights/VN3Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'VMProtectionAlerts'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     VN_3
//   ]
// }

resource VN_Name1_VN_Name1_Peering_To_VN_NAME2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: VN_1
  name: '${VN_Name1}-Peering-To-${VN_Name2}'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: VN_2.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        VN_Name2Prefix
      ]
    }
  }
  dependsOn: [

    VN_3
    VN_Name1_VN_Name1Subnet1
    VN_Name1_VN_Name1Subnet2
  ]
}

resource VN_Name1_VN_Name1_Peering_To_VN_NAME3 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: VN_1
  name: '${VN_Name1}-Peering-To-${VN_Name3}'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: VN_3.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        VN_Name3Prefix
      ]
    }
  }
  dependsOn: [

    VN_2

    VN_Name1_VN_Name1Subnet1
    VN_Name1_VN_Name1Subnet2
  ]
}

resource VN_Name2_VN_Name2_Peering_To_VN_NAME1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: VN_2
  name: '${VN_Name2}-Peering-To-${VN_Name1}'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: VN_1.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        VN_Name1Prefix
      ]
    }
  }
  dependsOn: [

    VN_3
    VN_Name1_VN_Name1Subnet1
    VN_Name1_VN_Name1Subnet2
  ]
}

resource VN_Name3_VN_Name3_Peering_To_VN_NAME1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-04-01' = {
  parent: VN_3
  name: '${VN_Name3}-Peering-To-${VN_Name1}'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: VN_1.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        VN_Name1Prefix
      ]
    }
  }
  dependsOn: [

    VN_2

    VN_Name1_VN_Name1Subnet1
    VN_Name1_VN_Name1Subnet2
  ]
}

resource publicIpAddress1 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName1
  location: location
  tags: {
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

// resource publicIpAddressName1_microsoft_insights_PIP1Diagnostics 'Microsoft.Network/publicIpAddresses/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${publicIpAddressName1}/microsoft.insights/PIP1Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'DDoSProtectionNotifications'
//         enabled: true
//       }
//       {
//         category: 'DDoSMitigationFlowLogs'
//         enabled: true
//       }
//       {
//         category: 'DDoSMitigationReports'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     publicIpAddress1
//   ]
// }

resource publicIpAddress2 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName2
  location: location
  tags: {
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

// resource publicIpAddressName2_microsoft_insights_PIP2Diagnostics 'Microsoft.Network/publicIpAddresses/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${publicIpAddressName2}/microsoft.insights/PIP2Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'DDoSProtectionNotifications'
//         enabled: true
//       }
//       {
//         category: 'DDoSMitigationFlowLogs'
//         enabled: true
//       }
//       {
//         category: 'DDoSMitigationReports'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     publicIpAddress2
//   ]
// }

resource FW_name 'Microsoft.Network/azureFirewalls@2019-11-01' = {
  name: fw_name
  location: location
  tags: {
  }
  properties: {
    threatIntelMode: 'Deny'
    ipConfigurations: [
      {
        name: publicIpAddressName1
        properties: {
          subnet: {
            id: VN_Name1_VN_Name1Subnet2.id
          }
          publicIPAddress: {
            id: publicIpAddress1.id
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.id
    }
  }
  dependsOn: [

    AG
  ]
}

// resource FW_name_microsoft_insights_FirewallDiagnostics 'Microsoft.Network/azureFirewalls/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${fw_name}/microsoft.insights/FirewallDiagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'AzureFirewallApplicationRule'
//         enabled: true
//         retentionPolicy: {
//           days: 10
//           enabled: false
//         }
//       }
//       {
//         category: 'AzureFirewallNetworkRule'
//         enabled: true
//         retentionPolicy: {
//           days: 10
//           enabled: false
//         }
//       }
//     ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//         retentionPolicy: {
//           enabled: false
//           days: 0
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     FW_name
//   ]
// }

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2019-06-01' = {
  name: firewallPolicyName
  location: location
  tags: {
  }
  properties: {
    threatIntelMode: 'Deny'
  }
  dependsOn: []
}

resource firewallPolicyName_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: firewallPolicy
  name: 'DefaultDnatRuleCollectionGroup'
  //: location
  properties: {
    priority: 100
    rules: [
      {
        name: 'APPGW-WEBAPP'
        priority: 100
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'Dnat'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '443'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            publicIpAddress1.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: AppGateway_IPAddress
        translatedPort: '443'
      }
      {
        name: VM_Name1
        priority: 101
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'Dnat'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33891'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            publicIpAddress1.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name1Ipaddress
        translatedPort: '3389'
      }
      {
        name: 'Kali-SSH'
        priority: 102
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'Dnat'
        }
        ruleCondition: {
          name: 'SSH-DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '22'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            publicIpAddress1.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name2Ipaddress
        translatedPort: '22'
      }
      {
        name: 'Kali-RDP'
        priority: 103
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'Dnat'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33892'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            publicIpAddress1.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name2Ipaddress
        translatedPort: '3389'
      }
      {
        name: VM_Name3
        priority: 104
        ruleType: 'FirewallPolicyNatRule'
        action: {
          type: 'Dnat'
        }
        ruleCondition: {
          name: 'DNATRule'
          ipProtocols: [
            'TCP'
          ]
          destinationPorts: [
            '33890'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            publicIpAddress1.properties.ipAddress
          ]
          ruleConditionType: 'NetworkRuleCondition'
        }
        translatedAddress: NIC_Name3Ipaddress
        translatedPort: '3389'
      }
    ]
  }
}

resource firewallPolicyName_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  //location: location
  properties: {
    priority: 200
    rules: [
      {
        name: 'IntraVNETandHTTPOutAccess'
        priority: 100
        ruleType: 'FirewallPolicyFilterRule'
        action: {
          type: 'Allow'
        }
        ruleConditions: [
          {
            name: 'SMB'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '445'
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
              NIC_Name3Ipaddress
              NIC_Name1Ipaddress
            ]
            destinationAddresses: [
              NIC_Name2Ipaddress
              NIC_Name3Ipaddress
              NIC_Name1Ipaddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          {
            name: 'RDP'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '3389'
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
              NIC_Name3Ipaddress
              NIC_Name1Ipaddress
            ]
            destinationAddresses: [
              NIC_Name2Ipaddress
              NIC_Name3Ipaddress
              NIC_Name1Ipaddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          {
            name: 'SSH'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '22'
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
              NIC_Name3Ipaddress
            ]
            destinationAddresses: [
              NIC_Name1Ipaddress
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
          {
            name: 'Kali-HTTP'
            ipProtocols: [
              'TCP'
            ]
            destinationPorts: [
              '80'
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
            ]
            destinationAddresses: [
              '*'
            ]
            ruleConditionType: 'NetworkRuleCondition'
          }
        ]
      }
    ]
  }
  dependsOn: [
    firewallPolicyName_DefaultDnatRuleCollectionGroup

  ]
}

resource firewallPolicyName_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleGroups@2019-06-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  //location: location
  properties: {
    priority: 300
    rules: [
      {
        name: 'Internet-Access'
        priority: 100
        ruleType: 'FirewallPolicyFilterRule'
        action: {
          type: 'Allow'
        }
        ruleConditions: [
          {
            name: 'SearchEngineAccess'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              '*'
            ]
            targetFqdns: [
              'www.google.com'
              'www.bing.com'
              'google.com'
              'bing.com'
            ]
            fqdnTags: []
            ruleConditionType: 'ApplicationRuleCondition'
          }
          {
            name: 'Kali-InternetAccess'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: [
              NIC_Name2Ipaddress
            ]
            targetFqdns: [
              '*'
            ]
            fqdnTags: []
            ruleConditionType: 'ApplicationRuleCondition'
          }
        ]
      }
    ]
  }
  dependsOn: [
    firewallPolicyName_DefaultNetworkRuleCollectionGroup

  ]
}

resource AG 'Microsoft.Network/applicationGateways@2020-04-01' = {
  name: AG_Name
  location: location
  tags: {
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: VN_Name1_VN_Name1Subnet1.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: publicIpAddress2.id
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        properties: {
          subnet: {
            id: VN_Name1_VN_Name1Subnet1.id
          }
          privateIPAddress: AppGateway_IPAddress
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_8080'
        properties: {
          port: 8080
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'PAAS-APP'
        properties: {
          backendAddresses: [
            {
              fqdn: '${Site_Name1}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'Default'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          hostName: '${Site_Name1}.azurewebsites.net'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'Public-HTTP'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', AG_Name, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', AG_Name, 'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'PublicIPRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', AG_Name, 'Public-HTTP')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', AG_Name, 'PAAS-APP')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', AG_Name, 'Default')
          }
        }
      }
    ]
    enableHttp2: false
    firewallPolicy: {
      id: AppGatewayPolicy.id
    }
  }
  dependsOn: [
    publicIpAddress1

  ]
}

// resource AG_Name_microsoft_insights_AppGatewayDiagnostics 'Microsoft.Network/applicationGateways/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${AG_Name}/microsoft.insights/AppGatewayDiagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'ApplicationGatewayAccessLog'
//         enabled: true
//       }
//       {
//         category: 'ApplicationGatewayPerformanceLog'
//         enabled: true
//       }
//       {
//         category: 'ApplicationGatewayFirewallLog'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     AG
//   ]
// }

resource AppGatewayPolicy 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2019-09-01' = {
  name: AppGatewayPolicyName
  location: location
  tags: {
  }
  properties: {
    customRules: [
      {
        name: 'SentinelBlockIP'
        priority: 10
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'IPMatch'
            negationConditon: false
            matchValues: [
              '104.210.223.108'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'BlockGeoLocationChina'
        priority: 20
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RemoteAddr'
              }
            ]
            operator: 'GeoMatch'
            negationConditon: false
            matchValues: [
              'CN'
            ]
            transforms: []
          }
        ]
      }
      {
        name: 'BlockInternetExplorer11'
        priority: 30
        ruleType: 'MatchRule'
        action: 'Block'
        matchConditions: [
          {
            matchVariables: [
              {
                variableName: 'RequestHeaders'
                selector: 'User-Agent'
              }
            ]
            operator: 'Contains'
            negationConditon: false
            matchValues: [
              'rv:11.0'
            ]
            transforms: []
          }
        ]
      }
    ]
    policySettings: {
      fileUploadLimitInMb: 100
      maxRequestBodySizeInKb: 128
      mode: 'Prevention'
      requestBodyCheck: true
      state: 'Enabled'
    }
    managedRules: {
      exclusions: []
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920350'
                  state: 'Disabled'
                }
                {
                  ruleId: '920320'
                  state: 'Disabled'
                }
              ]
            }
          ]
        }
      ]
    }
  }
  dependsOn: []
}

// resource FrontDoor 'Microsoft.Network/frontdoors@2019-04-01' = {
//   name: FrontDoorName
//   location: 'global'
//   tags: {
//   }
//   properties: {
//     friendlyName: FrontDoorName
//     enabledState: 'Enabled'
//     healthProbeSettings: [
//       {
//         name: 'healthProbeSettings1'
//         properties: {
//           path: '/'
//           protocol: 'Http'
//           intervalInSeconds: 30
//         }
//       }
//     ]
//     loadBalancingSettings: [
//       {
//         name: 'loadBalancingSettings1'
//         properties: {
//           sampleSize: 4
//           successfulSamplesRequired: 2
//         }
//       }
//     ]
//     frontendEndpoints: [
//       {
//         id: '${FrontDoor.id}/FrontendEndpoints/${FrontDoorName}-azurefd-net'
//         name: '${FrontDoorName}-azurefd-net'
//         properties: {
//           hostName: '${FrontDoorName}.azurefd.net'
//           sessionAffinityEnabledState: 'Disabled'
//           sessionAffinityTtlSeconds: 0
//           webApplicationFirewallPolicyLink: {
//             id: '${resourceGroup().id}/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies/${FrontdoorPolicyName}'
//           }
//           resourceState: 'Enabled'
//         }
//       }
//     ]
//     backendPools: [
//       {
//         name: 'OWASP'
//         properties: {
//           backends: [
//             {
//               address: publicIpAddress2.properties.ipAddress
//               enabledState: 'Enabled'
//               httpPort: 80
//               httpsPort: 443
//               priority: 1
//               weight: 50
//               backendHostHeader: publicIpAddress2.properties.ipAddress
//             }
//           ]
//           loadBalancingSettings: {
//             id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', FrontDoorName, 'loadBalancingSettings1')
//           }
//           healthProbeSettings: {
//             id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', FrontDoorName, 'healthProbeSettings1')
//           }
//         }
//       }
//     ]
//     routingRules: [
//       {
//         name: 'AppGW'
//         properties: {
//           frontendEndpoints: [
//             {
//               id: '${FrontDoor.id}/frontendEndpoints/${FrontDoorName}-azurefd-net'
//             }
//           ]
//           acceptedProtocols: [
//             'Http'
//             'Https'
//           ]
//           patternsToMatch: [
//             '/*'
//           ]
//           enabledState: 'Enabled'
//           routeConfiguration: {
//             '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
//             forwardingProtocol: 'HttpOnly'
//             backendPool: {
//               id: resourceId('Microsoft.Network/frontDoors/backendPools', FrontDoorName, 'OWASP')
//             }
//           }
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     '${resourceGroup().id}/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies/${FrontdoorPolicyName}'
//   ]
// }

// resource FrontdoorPolicy 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2019-10-01' = {
//   name: FrontdoorPolicyName
//   location: 'Global'
//   properties: {
//     policySettings: {
//       enabledState: 'Enabled'
//       mode: 'Prevention'
//       redirectUrl: 'https://www.microsoft.com/en-us/edge'
//       customBlockResponseStatusCode: 403
//       customBlockResponseBody: 'QmxvY2tlZCBieSBmcm9udCBkb29yIFdBRg=='
//     }
//     customRules: {
//       rules: [
//         {
//           name: 'BlockGeoLocationChina'
//           enabledState: 'Enabled'
//           priority: 10
//           ruleType: 'MatchRule'
//           rateLimitDurationInMinutes: 1
//           rateLimitThreshold: 100
//           matchConditions: [
//             {
//               matchVariable: 'RemoteAddr'
//               operator: 'GeoMatch'
//               negateCondition: false
//               matchValue: [
//                 'CN'
//               ]
//               transforms: []
//             }
//           ]
//           action: 'Block'
//         }
//         {
//           name: 'RedirectInternetExplorerUserAgent'
//           enabledState: 'Enabled'
//           priority: 20
//           ruleType: 'MatchRule'
//           rateLimitDurationInMinutes: 1
//           rateLimitThreshold: 100
//           matchConditions: [
//             {
//               matchVariable: 'RequestHeader'
//               selector: 'User-Agent'
//               operator: 'Contains'
//               negateCondition: false
//               matchValue: [
//                 'rv:11.0'
//               ]
//               transforms: []
//             }
//           ]
//           action: 'Redirect'
//         }
//         {
//           name: 'RateLimitRequest'
//           enabledState: 'Enabled'
//           priority: 30
//           ruleType: 'RateLimitRule'
//           rateLimitDurationInMinutes: 1
//           rateLimitThreshold: 1
//           matchConditions: [
//             {
//               matchVariable: 'RequestUri'
//               operator: 'Contains'
//               negateCondition: false
//               matchValue: [
//                 'search'
//               ]
//               transforms: []
//             }
//           ]
//           action: 'Block'
//         }
//       ]
//     }
//     managedRules: {
//       managedRuleSets: [
//         {
//           ruleSetType: 'DefaultRuleSet'
//           ruleSetVersion: '1.0'
//         }
//         {
//           ruleSetType: 'BotProtection'
//           ruleSetVersion: 'preview-0.1'
//         }
//       ]
//     }
//   }
// }

// resource FrontDoorName_microsoft_insights_FrontDoorDiagnostics 'Microsoft.Network/frontdoors/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${FrontDoorName}/microsoft.insights/FrontDoorDiagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'FrontdoorAccessLog'
//         enabled: true
//       }
//       {
//         category: 'FrontdoorWebApplicationFirewallLog'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     FrontDoor
//   ]
// }

resource RT_1 'Microsoft.Network/routeTables@2019-02-01' = {
  name: RT_Name1
  location: location
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'DefaultRoute'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.0.25.4'
        }
      }
    ]
  }
  dependsOn: []
}

resource NSG_1 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: NSG_Name1
  location: location
  tags: {
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Spoke2-VNET'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: VN_Name3Prefix
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-Spoke2-VNET-outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: VN_Name3Prefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

// resource NSG_Name1_microsoft_insights_NSG1Diagnostics 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${NSG_Name1}/microsoft.insights/NSG1Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'NetworkSecurityGroupEvent'
//         enabled: true
//       }
//       {
//         category: 'NetworkSecurityGroupRuleCounter'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     NSG_1
//   ]
// }

resource NSG_2 'Microsoft.Network/networkSecurityGroups@2020-04-01' = {
  name: NSG_Name2
  location: location
  tags: {
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-Spoke1-VNET-Inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: VN_Name2Prefix
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Allow-Spoke1-VNET-Outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: VN_Name2Prefix
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

// resource NSG_Name2_microsoft_insights_NSG2Diagnostics 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${NSG_Name2}/microsoft.insights/NSG2Diagnostics'
//   properties: {
//     name: 'DiagService'
//     workspaceId: workspaceid
//     logs: [
//       {
//         category: 'NetworkSecurityGroupEvent'
//         enabled: true
//       }
//       {
//         category: 'NetworkSecurityGroupRuleCounter'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     NSG_2
//   ]
// }

resource Site_1 'Microsoft.Web/sites@2018-11-01' = {
  name: Site_Name1
  location: location
  tags: {
  }
  properties: {
    //name: Site_Name1
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://index.docker.io'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|mohitkusecurity/juice-shop-updated'
      alwaysOn: true
    }
    //serverFarmId: resourceId('Microsoft.Web/serverfarms', Site_HPN_var)
    serverFarmId: Site_HPN.id
    clientAffinityEnabled: false
  }
  // dependsOn: [
  //   Site_HPN
  // ]
}

resource Site_HPN 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: Site_HPN_var
  location: location
  sku: {
    tier: 'PremiumV2'
    name: 'P1v2'
  }
  kind: 'linux'
  properties: {
    // name: Site_HPN_var
    // workerSize: 3
    // workerSizeId: 3
    // numberOfWorkers: 1
    reserved: true
  }
}
// Commenting  DDOS plan out because it's really expensive
// resource DDoSPlan 'Microsoft.Network/ddosProtectionPlans@2020-04-01' = {
//   name: DDoSPlanName
//   location: location
//   properties: {
//   }
// }

resource NIC_1 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: NIC_Name1
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: NIC_Name1Ipaddress
          subnet: {
            id: '${VN_2.id}/subnets/${VN_Name2Subnet1Name}'
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

resource NIC_2 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: NIC_Name2
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: NIC_Name2Ipaddress
          subnet: {
            id: '${VN_2.id}/subnets/${VN_Name2Subnet2Name}'
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

resource NIC_3 'Microsoft.Network/networkInterfaces@2019-07-01' = {
  name: NIC_Name3
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: NIC_Name3Ipaddress
          subnet: {
            id: '${VN_3.id}/subnets/${VN_Name3Subnet1Name}'
          }
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
  }
}

resource VM_1 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: VM_Name1
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_Name1}-datadisk1'
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-21h2-pro'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC_1.id
        }
      ]
    }
    osProfile: {
      computerName: VM_Name1
      adminUsername: DefaultUserName
      adminPassword: DefaultPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}

resource VM_2 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: VM_Name2
  location: location
  plan: {
    name: 'kali'
    publisher: 'kali-linux'
    product: 'kali'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_Name2}-datadisk1'
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'kali-linux'
        offer: 'kali'
        sku: 'kali'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC_2.id
        }
      ]
    }
    osProfile: {
      computerName: VM_Name2
      adminUsername: DefaultUserName
      adminPassword: DefaultPassword
    }
  }
}

resource VM_3 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: VM_Name3
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_Name3}-datadisk1'
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC_3.id
        }
      ]
    }
    osProfile: {
      computerName: VM_Name2
      adminUsername: DefaultUserName
      adminPassword: DefaultPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Server'
  }
}