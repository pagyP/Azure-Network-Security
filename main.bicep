param location string = 'uksouth'
module virtualNetworks './modules/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: '${uniqueString(deployment().name, location)}-test-nvnmin'
  params: {
    // Required parameters
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: '<<namePrefix>>nvnmin001'
    location: location
    // Non-required parameters
    enableDefaultTelemetry: false
  }
}
