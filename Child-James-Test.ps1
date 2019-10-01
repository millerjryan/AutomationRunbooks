param(
        [Parameter(Mandatory=$true)]
        [object] $subscriptionObj
    )

    #login to azure
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    Select-AzureRMSubscription -SubscriptionName $subscriptionObj.Name | Set-AzureRmContext

	#List all Resources within the Subscription
	$resources = Get-AzureRmResource
	
	#List all Resource Groups within the Subscription
	$resourcegroups = Get-AzureRmResourceGroup

	If ($subscriptionObj.Name -eq "JH-GP") {
		
		ForEach ($resource in $resources) {
		
			$resourceid = $resource.resourceId
			
			If ($resourceid -notlike "*scheduledqueryrules*") { 
			
				$RGTagCMDB_PAS = (Get-AzureRmResourceGroup -Name $resource.ResourceGroupName).Tags.cmdb_pas
				$resourcetagCMDB_PAS = $resource.Tags.cmdb_pas
				$RGTagCostAllocation = (Get-AzureRmResourceGroup -Name $resource.ResourceGroupName).Tags.CostAllocation
			
				If ($RGTagCostAllocation -ne $null -And $RGTagCostAllocation -ne "") {
					If ($resourcetagCMDB_PAS -ne $RGTagCostAllocation) {
						Write-Output "---------------------------------------------"
						Write-Output "Applying the following tag to resourceid: $($resourceid)"
						Write-Output "Tag: $($RGTagCostAllocation)"
						Write-Output "---------------------------------------------"
						$settag = Set-AzureRmResource -ResourceId $resourceid -Tag @{cmdb_pas=$RGTagCostAllocation} -Force	
						$count = $count + 1
					}
				}
				
				ElseIf (($RGTagCMDB_PAS -ne $null -And $RGTagCMDB_PAS -ne "") -And ($resourcetagCMDB_PAS -ne $RGTagCMDB_PAS)) {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resourceid: $($resourceid)" 
					Write-Output "Tag: $($RGTagCMDB_PAS)"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResource -ResourceId $resourceid -Tag @{cmdb_pas=$RGTagCMDB_PAS} -Force
					$count = $count + 1
				}
			}
		}
	}
	
	ElseIf ($subscriptionObj.Name -eq "JH-SWS") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 4500200075"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="4500200075"}
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
	}
	
	ElseIf ($subscriptionObj.Name -eq "JH-MALONECENTER") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 4500170012"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="4500170012"}
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
	}

	ElseIf ($subscriptionObj.Name -eq "JH-SOM-DOM") {
		
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 80022733"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="80022733"}
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
	}

	ElseIf ($subscriptionObj.Name -eq "JH-ACH-MARCOM") {
	
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
	}
	
	ElseIf ($subscriptionObj.Name -eq "JH-GENOMICS") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 80012307"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="80012307"}
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
	}

<#
	ElseIf ($subscriptionObj.Name -eq "JH-ANSWERALS") {

		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: ?"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="?"}
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
	}
#>

	ElseIf ($subscriptionObj.Name -eq "JH-TIC") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 5502044000"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="5502044000"}
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
	}
	
	ElseIf ($subscriptionObj.Name -eq "JH-KSAS") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 80024436"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="80024436"}
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
	}

	ElseIf ($subscriptionObj.Name -eq "JH-RADIOLOGY") {
	
		ForEach ($resourcegroup in $resourcegroups) {
		
			If ($resourcegroup.Tags.cmdb_pas -eq $null -Or $resourcegroup.Tags.cmdb_pas -eq "") {
					Write-Output "---------------------------------------------"
					Write-Output "Applying the following tag to resource group: $($resourcegroup.ResourceGroupName)"
					Write-Output "Tag: 4500150180"
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResourceGroup -Name $resourcegroup.ResourceGroupName -Tag @{cmdb_pas="4500150180"}
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
	}
	
	Else {
		ForEach ($resource in $resources) {
		
			$resourceid = $resource.resourceId
			
			If ($resourceid -notlike "*scheduledqueryrules*") {

				$rgname = $resource.ResourceGroupName
				$RGTagCMDB_PAS = (Get-AzureRmResourceGroup -Name $rgname).Tags.cmdb_pas
				$resourcetagCMDB_PAS = $resource.Tags.cmdb_pas

				If (($RGTagCMDB_PAS -ne $null -And $RGTagCMDB_PAS -ne "") -And ($resourcetagCMDB_PAS -ne $RGTagCMDB_PAS)) {
					Write-Output "---------------------------------------------"
					Write-Output "[final else] Applying the following tag to $($resourceid)" $RGTagCMDB_PAS
					Write-Output "---------------------------------------------"
					$settag = Set-AzureRmResource -ResourceId $resourceid -Tag @{cmdb_pas=$RGTagCMDB_PAS} -Force
					$count = $count + 1				
				}
				If (($RGTagCMDB_PAS -ne $null -And $RGTagCMDB_PAS -ne "") -And ($resourcetagCMDB_PAS -ne $RGTagCMDB_PAS)) {
					$resourceput = Get-AzureRmResource -resourceid $resourceid
					Write-Output "---------------------------------------------"
					Write-Output "[final else] Applying (w/ the put method) the following tag to $($resourceid)"
					Write-Output "Tag: $($RGTagCMDB_PAS)"
					Write-Output "---------------------------------------------"
					$resourceput | Set-AzureRmResource -Tag @{cmdb_pas=$RGTagCMDB_PAS} -Force
				}				
			}
		}
	}