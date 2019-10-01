## Test Azure Resource Group and Role Assignments
#auth
    #get the powershell automation credential asset
    $AutomationConnectionName = "AzureRunAsConnection"     
    # Get the credential asset with access to my Azure subscription
    $connection = Get-AutomationConnection -Name $AutomationConnectionName
    if(!$connection) {
        Throw "Could not find the AzureRunAsConnection. Make sure you have created one in this Automation Account."
    }

    # Authenticate to Azure Resource Manager
    $Account = Add-AzureRMAccount -ServicePrincipal -TenantId $connection.TenantID -ApplicationId $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint
    if(!$Account) {
        Throw "Could not authenticate to Azure using AzureRunAsConnection."
    }
	
#$hdiContributorGroupObjectId = Get-AutomationVariable -Name 'HDInsightContributorGroupObjectId'
#test variables
$lockerObjectId = "10f5dff5-0c61-4bde-9ebb-6561f7eb6424" #group objid matt sent me
$location = "eastus2"
$resourceGroupName = "vjomiTESTrg1"



    #Create Resource Group
    New-AzureRmResourceGroup -Location $location `
        -Name $resourceGroupName `
        -Force
Start-Sleep -s 30
    try
    {
        #Assign Owner role to resource lockers
        New-AzureRmRoleAssignment -ObjectId $lockerObjectId `
            -RoleDefinitionName "Owner" `
            -ResourceGroupName $resourceGroupName `
            -ErrorAction Stop -Debug
    }
    catch [Microsoft.Rest.Azure.CloudException]
    {
        Write-Output "Getting an error assigning role to resource group: $resourceGroupName"
		Write-Output "Please check Access control (IAM) of the resource group"
        Write-Output $_.Exception|format-list -force
    }

    try
    {
        #Assign Owner role to resource lockers
        Get-AzureRmRoleAssignment -ObjectId $lockerObjectId `
        -ResourceGroupName $resourceGroupName `
        -Debug
    }
    catch [Microsoft.Rest.Azure.CloudException]
    {
        Write-Output "Getting an error getting role to resource group: $resourceGroupName"
		Write-Output "Please check Access control (IAM) of the resource group"
        Write-Output $_.Exception|format-list -force
    }


