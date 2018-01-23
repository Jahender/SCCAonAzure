
# Change Values in these Variables to match your environment!!!!!
$SCCAInfrastructurelocation='usdodeast'
$SCCAinfrastructureRGname='SCCA_Final_Sync'
$SCCAinfrastructureVNetName='VDSS_VNet'
$F5_Ext_Trust_RouteTableName='F5_Ext_Trust_RouteTable'
$IPS_Trust_RouteTableName='IPS_Trust_RouteTable'
$Internal_Subnets_RouteTableName='Internal_Subnets_RouteTable'
$IPSUntrustedIP='192.168.2.5'
$F5IntUntrustedIP='192.168.4.5'
$F5IntTrustedIP='192.168.5.5'
$ExtCloudMissionOwnerAddressPrefix='10.250.0.0/22'
$RouteToExtCloudMissionOwnerName='ToExtCloudMissionOwner'

# These Variables will be used in the deployment tasks below... Don't change!!!
$SCCAvnet= Get-AzureRmVirtualNetwork -ResourceGroupName $SCCAinfrastructureRGname -Name $SCCAinfrastructureVNetName
$F5extTrustRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $F5_Ext_Trust_RouteTableName
$IPSTrustRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $IPS_Trust_RouteTableName
$InternalSubnetsRouteTable= Get-AzureRmRouteTable -ResourceGroupName $SCCAinfrastructureRGname -Name $Internal_Subnets_RouteTableName


#Add IL4MO Route to F5_Ext_Trust_RouteTable
Add-AzureRmRouteConfig -Name $RouteToExtCloudMissionOwnerName -RouteTable $F5extTrustRouteTable  -AddressPrefix $ExtCloudMissionOwnerAddressPrefix -NextHopType VirtualAppliance -NextHopIpAddress $IPSUntrustedIP | Set-AzureRmRouteTable

#Add IL4MO Route to IPS_Trust_RouteTable
Add-AzureRmRouteConfig -Name $RouteToExtCloudMissionOwnerName -RouteTable $IPSTrustRouteTable  -AddressPrefix $ExtCloudMissionOwnerAddressPrefix  -NextHopType VirtualAppliance -NextHopIpAddress $F5IntUntrustedIP | Set-AzureRmRouteTable

#Add IL4MO Route to Internal_Subnets_RouteTable
Add-AzureRmRouteConfig -Name $RouteToExtCloudMissionOwnerName -RouteTable $InternalSubnetsRouteTable  -AddressPrefix $ExtCloudMissionOwnerAddressPrefix  -NextHopType VirtualAppliance -NextHopIpAddress $F5IntTrustedIP | Set-AzureRmRouteTable

