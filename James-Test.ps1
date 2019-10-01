"Start time is $(get-date)."

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

$subscriptions = Get-AzureRmSubscription

Write-Output "Entering ForEach subscription loop"

ForEach($subscription in $subscriptions) {

                Select-AzureRMSubscription -SubscriptionName $subscription.Name | Set-AzureRmContext

                #List all Resources within the Subscription
                $resources = Get-AzureRmResource
                
                #List all Resource Groups within the Subscription
                $resourcegroups = Get-AzureRmResourceGroup

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

}

"End time is $(get-date)."
