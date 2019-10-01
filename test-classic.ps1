################################################################################
# This script is responsible for gathering current instance counts from
# current production, and writing that info to a variable so in case we have 
# an outage, we can use that number to scale the DR environment to the same
# number of instances. In addition, this script gathers the database Edition
# information so the scale script can ensure the right scale for the database as 
# well.
################################################################################

#Variables
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"
#$ClassicConnection = Get-AutomationConnection -Name "AzureClassicRunAsConnection"
#$CertificateAssetName = $ClassicConnection.CertificateAssetName
#$AzureCert = Get-AutomationCertificate -Name "ManagementCertificate"
$SubscriptionId = Get-AutomationVariable -Name "automationSubscriptionId"
$SourceCloudServiceName = Get-AutomationVariable -Name "sourceCloudServiceName"
$SourceCloudServiceServicesName = Get-AutomationVariable -Name "sourceCloudServiceServicesName"
$automationAccountName = "vjomiLABauto" #Get-AutomationVariable -Name 'automationAccountName'
$ResourceGroupName = "vjomiLABrg" #Get-AutomationVariable -Name "resourceGroupName"
$SourceSqlServer = Get-AutomationVariable -Name 'sourceSqlServer'
$sourceResourceGroupName = Get-AutomationVariable -Name "sourceSqlServerResourceGroup"
$databaseName = Get-AutomationVariable -Name "sourceSqlServerDbName"

#Login Classic
#Set-AzureSubscription -SubscriptionName $ClassicConnection.SubscriptionName -SubscriptionId $ClassicConnection.SubscriptionID -Certificate $AzureCert
#Select-AzureSubscription -SubscriptionId $ClassicConnection.SubscriptionID
Write-Output "---Classic Login Succeeded (not)---"

#Login RM
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint 
Write-Output "---Login Succeeded ---"
#Set the instance count for the primary service
#$roles = Get-AzureRole -ServiceName $SourceCloudServiceName -Slot "Production"
$roles
New-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "ServiceInstanceCount" -Encrypted $False -Value $roles -ResourceGroupName $ResourceGroupName -erroraction 'silentlycontinue'
Set-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "ServiceInstanceCount" -Encrypted $False -Value $roles -ResourceGroupName $ResourceGroupName
 
#Set the instance count for the DB Service
$roles2 = Get-AzureRole -ServiceName $SourceCloudServiceServicesName -Slot "Production"
New-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "DBServiceInstanceCount" -Encrypted $False -Value $roles.InstanceCount -ResourceGroupName $ResourceGroupName -erroraction 'silentlycontinue'
Set-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "DBServiceInstanceCount" -Encrypted $False -Value $roles.InstanceCount -ResourceGroupName $ResourceGroupName

#TODO: What is the API service? There is one in production, but not in any other environment
 
#Now, get the DB size so if needed we can scale that as well
$dbInfo = Get-AzureRmSqlDatabase -ResourceGroupName $sourceResourceGroupName -ServerName $SourceSqlServer -DatabaseName $databaseName
New-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "DatabaseEditition" -Encrypted $False -Value $dbInfo.Edition -ResourceGroupName $ResourceGroupName -erroraction 'silentlycontinue'
Set-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "DatabaseEditition" -Encrypted $False -Value $dbInfo.Edition -ResourceGroupName $ResourceGroupName
New-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "ServiceObjectiveName" -Encrypted $False -Value $dbInfo.RequestedServiceObjectiveName -ResourceGroupName $ResourceGroupName -erroraction 'silentlycontinue'
Set-AzureRmAutomationVariable -AutomationAccountName $automationAccountName -Name "ServiceObjectiveName" -Encrypted $False -Value $dbInfo.RequestedServiceObjectiveName -ResourceGroupName $ResourceGroupName


