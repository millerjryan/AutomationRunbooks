## Child

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

$subscription = Get-AzureRmSubscription | where {$_.Name -like 'v-my*'} ## Insert Subscription Name

Select-AzureRMSubscription -SubscriptionName $subscription.Name | Set-AzureRmContext

$resources = Get-AzureRmResource 
$resourcegroups = Get-AzureRmResourceGroup -Name "vjomiLABrg"

ForEach ($resourcegroup in $resourcegroups) {

	If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
			Write-Output "---------------------------------------------"
			Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
			Write-Output "Tag: 6500002719"
			Write-Output "---------------------------------------------"
			$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="6500002719"}
			$rgcount = $rgcount + 1
	}
}

ForEach ($resource in $resources) {

	$resourceid = $resource.resourceId
	
	If ($resourceid -notlike "*scheduledqueryrules*") {
	
		$rgname = $resource.ResourceGroupName
		$RGTagCMDB_PAS = (Get-AzureRmResourceGroup -Name $rgname).Tags.cmdb_pas
		$resourcetagCMDB_PAS = $resource.Tags.cmdb_pas
		
		If ($resourcetagCMDB_PAS -ne $RGTagCMDB_PAS) {
			Write-Output "---------------------------------------------"
			Write-Output "Applying the following tag to resourceid: $($resourceid)" 
			Write-Output "Tag $($RGTagCMDB_PAS)"
			Write-Output "---------------------------------------------"
			$settag = Set-AzureRmResource -ResourceId $resourceid -Tag @{cmdb_pas=$RGTagCMDB_PAS} -Force	
			$count = $count + 1
		}		
	}
}

Write-Output "Completed..."