workflow Start_VMs_8pm-5am
{

######################################################################################
######################################################################################
##  created by:  austinM   Last Modified 6/14/2019
##
##  Purpose:  Start the list of VMs provided in the subscription (Script does not process Classic VMs)
##  
##  Note:  When you create the runbook you MUST select "PowerShell WorkFlow".   The name of the runbook must match
##         the name of the workflow on line 1. The Automation account needs to have a Runas Azure Automation account
## 
##  Update the variables below as desired
#$currentTime = Get-Date -Format "HH:mm"
#$start = "05:00" #Start Time in 24H
#$end = "06:00"   #End Time in 24H

#if (($currentTime -ge $start) -and ($currentTime -le $end))
#       {
#              Write-Output "This script is scheduled to run between $start & $end only"
#       }else {
#              exit
#       } 

$MyVMList = @("1vmuse2ppdbstg01","vmuse2ptdbstg01","vmwuse2ptdbqa01","vmlmststgwdb01","vmlmgtstgdb01","vmwstormqadb01")       # if you want all VMs use:    $MyVMList=@("*")

$ResourceGroups = @("ResourceGroupXYZ")  #  if specified will find all VMs in the resource group(s)  #    $ResourceGroups=@("ResourceGroupXYZ","MyNewResourceGroup1")

$ExludeList = @("hhxyVM2","xyxy")      # Optional.  You can specify VMs that should be excluded from the automation subscription
$AzureGov = $False                   # if you connect to Azure Government set this to   $True

$SecondsToPause = 1                  # If your VMs have a StartOrder tag of 1, 2, 3, or 4 they will be started in that order and pause between tag 1 and tag 2, ...

$TimeZone = 'Eastern Standard Time'  # You can get a list of TimeZones ID names by using something similar to the following  
                                     #
                                     # [System.TimeZoneInfo]::GetSystemTimeZones() | FT ID, DisplayName
                                     #
                                     #      Id                       DisplayName
                                     #      --                       -----------
                                     #      Pacific Standard Time    (UTC-08:00) Pacific Time (US & Canada)
                                     #      Mountain Standard Time   (UTC-07:00) Mountain Time (US & Canada)
                                     #      Central Standard Time    (UTC-06:00) Central Time (US & Canada)
                                     #      Eastern Standard Time    (UTC-05:00) Eastern Time (US & Canada)
                                     #      SA Western Standard Time (UTC-04:00) Georgetown, La Paz, Manaus, San Juan
                                     #      Romance Standard Time    (UTC+01:00) Brussels, Copenhagen, Madrid, Paris
                                     #      Syria Standard Time      (UTC+02:00) Damascus
                                     #      FLE Standard Time        (UTC+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius
                                     #      Israel Standard Time     (UTC+02:00) Jerusalem
                                     #      Arabian Standard Time    (UTC+04:00) Abu Dhabi, Muscat
                                     #      ...

##  Update the variables above as needed
##  
##  Azure Modules used/required, may require other modules be updated also:
##  
##    5.8.2    AzureRM.profile
##    5.9.1    AzureRM.Compute
##
##  You can check your Azure Modules version from the Azure portal under:  Home > Automation Accounts > AutomationAccountXYZ - Modules
##  If your Azure Modules are not up to date you can try clicking "Update Azure modules" to update all Azure modules.   If you 
##  are using Azure Government the best way to update the modules for the specific Automation account is to use the Powershell script 
##  located at:
##     Download Update-AutomationAzureModulesForAccount.ps1 runbook to update your Azure modules
##     https://github.com/Microsoft/AzureAutomation-Account-Modules-Update
##     Copy Raw and Create a runbook with the name:  Update-AutomationAzureModulesForAccount.  If using AzureUSGovernment update the 
##     line below as shown before running the script to update modules so that it is going to the AzureUSGovernment:
##          [string] $AzureEnvironment = 'AzureUSGovernment'
##
##  If you see the following you likely do not have the update Azure modules listed above:   
##     Cannot find the 'Connect-AzureRmAccount' command
##
##  Notes:
##    - You should confirm that this sample runbook is starting the Runbooks as desired.  If you have many VMs it may be necessary
##      to run the runbook from a Hybrid Runbook worker.  Runbooks that run in Azure have limits on the amount of resources
##      that they are allowed to use.  Alternatively you may want to use the marketplace "Start/Stop VMs during off-hours" 
##      solution which does not have the automation limits if you have hundreds of VMs to start and stop in a short duration.
##        Automation Limits:
##        https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#automation-limits
##    
##    - VMS often start before the script is informed the VM has started.  Same can occur on the portal.  Best confirmation is to 
##      RDP to the system to determine if it is trully running or not.
##
######################################################################################
######################################################################################

#$GLOBAL:DebugPreference = "Continue"   ## default value is SilentlyContinue  -- This line can significantly increase the output.

$Notes=@'
Notes:
- You should confirm that this sample runbook is starting the Runbooks as desired.  If you have many VMs it may be necessary
  to run the runbook from a Hybrid Runbook worker.  Runbooks that run in Azure have limits on the amount of resources
  that they are allowed to use.  Alternatively you may want to use the marketplace "Start/Stop VMs during off-hours" 
  solution which does not have the automation limits if you have hundreds of VMs to start and stop in a short duration.
    Automation Limits:
    https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits#automation-limits

- VMS often start before the script if informed the VM has started.  Same can occur on the portal.  Best confirmation is to 
  RDP to the system to determine if it is trully running or not.
'@

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
"  ApplicationId         : " + $Conn.ApplicationId
"  CertificateThumbprint : " + $Conn.CertificateThumbprint

If ($AzureGov) {$ConnectionInfo = Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint -EnvironmentName AzureUSGovernment}
else {$ConnectionInfo = Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint}
"  TenantId              : " + $ConnectionInfo.Context.Tenant.ID

$AzureContext = Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionID    ## or select a specific subscription 
"  Environment           : " + $AzureContext.Environment
"  Subscription          : " + $AzureContext.Subscription
"  SubscriptionName      : " + $AzureContext.Subscription.Name
""

If (!($AzureContext)) 
{"";"ERROR:  Something appears to have gone wrong.  Select-AzureRmSubscription appears to be empty."
    "        Confirm Azure RunAs Account is present and not expired:  Home > Automation Accounts > AutomationAccountXYZ - Run As Accounts";
    "        Confirm Azure Modules have been updated:   Home > Automation Accounts > AutomationAccountXYZ - Modules"
    Exit
}

$Notes

if ($resourceGroups) 
  {
  ForEach ($RG in $ResourceGroups) { $RGVMs += Get-AzureRmVM -ResourceGroupName  "$RG"  }
  ForEach ($RGVM in $RGVMs) { $MyVMList += ($RGVM.Name)  }
  }

$MyVMList = $MyVMList | sort -Unique
""
"VMs of interest: $MyVMList"
""

# Get VM instance view properties. Does not return the standard VM properties however it gets the reource group the VM is in
  $VMsWithStatus=@()
  $VMsWithStatus = Get-AzureRmVM -Status | select-object ResourceGroupName, Name, PowerState
  " - Total VMs:  " + $VMsWithStatus.Count

If ('*' -in $MyVMList) {$VMsToChange = $VMsWithStatus | ?{$_.PowerState -notlike "*running*"}}
else {$VMsToChange = $VMsWithStatus | ?{$_.PowerState -notlike "*running*" -and $_.Name -in $MyVMList}}
$VMsToChange = $VMsToChange | ?{$_.Name -NotIn $ExludeList}

" - VMs that need to be updated:" + $VMsToChange.Count    # does not display a number if the list only has one machine

# Create an array to store standard VMs properties that are running 
$VMs1 = @(); $VMs2 = @(); $VMs3 = @(); $VMs4 = @(); $VMsLast = @();
ForEach ($VMStatus in $VMsToChange) # Get the VM properties of each VM of interest
  {  
    $VM = @(Get-AzureRmVM -Name ($VMStatus.name) -ResourceGroupName ($VMStatus.ResourceGroupName))
    If ($VM.tags.StartOrder) 
      {
        If     ($VM.tags.StartOrder -eq "1") {$VMs1 += $VM}
        elseif ($VM.tags.StartOrder -eq "2") {$VMs2 += $VM}
        elseif ($VM.tags.StartOrder -eq "3") {$VMs3 += $VM}
        elseif ($VM.tags.StartOrder -eq "4") {$VMs4 += $VM}
      }
    else 
      {
        $VMsLast += $VM 
      }
  }

""
$DisplayPause=$False
for ($xx = 1; $xx -ile 6; $xx++) 
  { 
    $VMs=@()
    If     ($VMs1 -and $xx -eq 1)    {$VMs = $VMs1;$DisplayPause=$True}
    ElseIf ($VMs2 -and $xx -eq 2)    {$VMs = $VMs2;$DisplayPause=$True}
    ElseIf ($VMs3 -and $xx -eq 3)    {$VMs = $VMs3;$DisplayPause=$True}
    ElseIf ($VMs4 -and $xx -eq 4)    {$VMs = $VMs4;$DisplayPause=$True}
    ElseIf ($VMsLast -and $xx -eq 5) {$VMs = $VMsLast}
    
    if ($xx -gt 1 -and $VMs) {"";"== Pausing for $SecondsToPause Before continuing with the next batch of VM(s) to start";""; Start-Sleep -Seconds $SecondsToPause}

    Foreach -parallel -throttlelimit 15 ($VM in $VMs)
      {
         "Running:    start-AzureRmVm -Name " + $Vm.Name + "    -ResourceGroupName " + $Vm.ResourceGroupName
         $Status = start-AzureRmVm -Name $Vm.Name -ResourceGroupName $Vm.ResourceGroupName
         $StartTimeUTC = $Status.StartTime.ToUniversalTime().ToString('HH:mm')
         $StartTimeInTz = [System.TimeZoneInfo]::ConvertTimeFromUtc($StartTimeUTC, [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)) 
         $EndTimeUTC = $Status.EndTime.ToUniversalTime().ToString('HH:mm')
         $EndTimeInTz = [System.TimeZoneInfo]::ConvertTimeFromUtc($EndTimeUTC, [System.TimeZoneInfo]::FindSystemTimeZoneById($TimeZone)) 
         "Finished: " + $Vm.Name + " with " + $Status.Status + "   StartTime: $StartTimeInTz    EndTime: $EndTimeInTz   $TimeZone"
      }
  }
"";" -- Finished --"  
}
