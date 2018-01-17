
# Change Values in these Variables to match your environment!!!!!
$IL5MissionOwnerRGName='IL5MissionOwner1RG'
$location='usdodeast'
$SCCAinfrastructureRGname='SCCAinfrastructureRG'
$SCCAinfrastructureVNetName='VDSS_VNet'
$F5_Ext_Trust_RouteTableName='F5_Ext_Trust_RouteTable'
$IPS_Trust_RouteTableName='IPS_Trust_RouteTable'
$Internal_Subnets_RouteTableName='Internal_Subnets_RouteTable'
$IPSUntrustedIP='192.168.2.5'
$F5IntUntrustedIP='192.168.4.5'
$F5IntTrustedIP='192.168.5.5'
$IL5MissionOwnerVNetName='IL5MissionOwner1VNet'
$IL5MissionOwnerVNetPrefix='10.0.0.0/22'
$IL5MissionOwnerSubnet1Name='ProductionSubnet'
$IL5MissionOwnerSubnet1Prefix='10.0.0.0/24'
$RouteToIL5MissionOwnerName='ToIL5MissionOwner'

# These Variables will be used in the deployment tasks below... Don't change!!!
$SCCAvnet= Get-AzureRmVirtualNetwork -ResourceGroupName $SCCAinfrastructureRGname -Name $SCCAinfrastructureVNetName
$F5extTrustRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $F5_Ext_Trust_RouteTableName
$IPSTrustRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $IPS_Trust_RouteTableName
$InternalSubnetsRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $Internal_Subnets_RouteTableName

# Create the MissionOwner resource group.
New-AzureRmResourceGroup -Name $IL5MissionOwnerRGName  -Location $location

# Create IL5 VNet.
New-AzureRmVirtualNetwork -ResourceGroupName $IL5MissionOwnerRGName -Name $IL5MissionOwnerVNetName -AddressPrefix $IL5MissionOwnerVNetPrefix -Location $location

#Set IL5 VNet Variable
$IL5vNet = Get-AzureRmVirtualNetwork -ResourceGroupName $IL5MissionOwnerRGName -Name $IL5MissionOwnerVNetName

#Create Subnet in IL5 VNet and assign Internal_Subnets_RouteTable
Add-AzureRmVirtualNetworkSubnetConfig -Name $IL5MissionOwnerSubnet1Name -VirtualNetwork $IL5vNet -AddressPrefix $IL5MissionOwnerSubnet1Prefix -RouteTable $InternalSubnetsRouteTable
Set-AzureRMVirtualNetwork -VirtualNetwork $IL5vNet

# Peer VNet1 to VNet2.
Add-AzureRmVirtualNetworkPeering -Name 'VDSStoIL5MissionOWner' -VirtualNetwork $SCCAvnet -RemoteVirtualNetworkId $IL5vNet.Id

# Peer VNet2 to VNet1.
Add-AzureRmVirtualNetworkPeering -Name 'IL5MissionOwnerToVDSS' -VirtualNetwork $IL5vNet -RemoteVirtualNetworkId $SCCAvnet.Id

#Add IL5MO Route to F5_Ext_Trust_RouteTable
Add-AzureRmRouteConfig -Name $RouteToIL5MissionOwnerName -RouteTable $F5extTrustRouteTable  -AddressPrefix $IL5MissionOwnerVNetPrefix  -NextHopType VirtualAppliance -NextHopIpAddress $IPSUntrustedIP | Set-AzureRmRouteTable

#Add IL5MO Route to IPS_Trust_RouteTable
Add-AzureRmRouteConfig -Name $RouteToIL5MissionOwnerName -RouteTable $IPSTrustRouteTable  -AddressPrefix $IL5MissionOwnerVNetPrefix  -NextHopType VirtualAppliance -NextHopIpAddress $F5IntUntrustedIP | Set-AzureRmRouteTable

#Add IL5MO Route to Internal_Subnets_RouteTable
Add-AzureRmRouteConfig -Name $RouteToIL5MissionOwnerName -RouteTable $InternalSubnetsRouteTable  -AddressPrefix $IL5MissionOwnerVNetPrefix  -NextHopType VirtualAppliance -NextHopIpAddress $F5IntTrustedIP | Set-AzureRmRouteTable

