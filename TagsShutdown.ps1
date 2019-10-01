<#
    .DESCRIPTION
        A runbook which Shuts Down all running VM's tagged with custom tags matching the key and value outlined below,
        using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Christopher Scott
                Microsoft Premier Field Engineer
        LASTEDIT: December 20, 2017
#>


#If you used a custom RunAsConnection during the Automation Account setup this will need to reflect that.
$connectionName = "AzureRunAsConnection" 
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
<#
 Get all VMs in the subscription with the Tag Tier:2 and Shut them down if they are running
 In this section we are filtering our Get-AzureRMVM statement by selecting VM's that have a Key of Tier and Value of 2, We also have implemented an If statement to only
 run against VMs that are already running.
#>
                                            #This is where you would set your custom Tags Keys and Values
$VMs = Get-AzureRMVm  |  Where {$_.Tags.Keys -contains "POC" -and $_.Tags.Values -contains "POC"} | Select Name, ResourceGroupName, Tags
ForEach ($VM in $VMs)
{
     $VMStatus2 = Get-AzureRMVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Status

    $VMN=$VM.Name
    $VMRG=$VM.ResourceGroupName
    $VMPS=$VMStatus2.Statuses[1].DisplayStatus
        If ($VMPS = "VM Running") 
            {
                Stop-AzureRMVM -Name $VMN -ResourceGroupName $VMRG -force
                "$VMN is Shutdown and Deallocated"
            }
                   
}


<#
This next section is optional. Originally I used this runbook to shutdown VMs in a order so at the end of the Tier 2 Runbook
I would call the Tier 1 Runbook and finally the Tier 0 runbook. For Startup I would reverse the order to ensure services came up correctly.
By splitting the runbooks I ensured the next set of services did not start or stop until the previous set had finished.

$NextRunbook = <Fill in Next Runbook Name for this example our next Runbook would be "Blog_Shutdown_Tier1">
$AutomationAccountName = <Automation Account Name ours was "BlogAutomation">
$ResourceGroup = <Automation Account ResourceGroup ours was "AzureAutomation-Blog">

Start-AzureRmAutomationRunbook -Name $NextRunbook -AutomationAccountName $AutomationAccountName -ResourceGroupName $ResourceGroup 

#>
