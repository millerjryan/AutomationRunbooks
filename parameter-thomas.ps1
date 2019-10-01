[cmdletbinding()]
param (
    # The list of servers to send a notification about
    [Parameter(Mandatory)]
    [string[]]
    $ServerFQDNList,

    # The message to be included before the servers and their patches
    [Parameter()]
    [string]
    $OpeningMessage = @"
<h2>Scheduled Maintenance Window</h2>
<h3>Windows Patch Schedule</h3>
<p>Please be advised that patching is scheduled to occur on the following servers. Servers will be rebooted one or more times during this activity. Hyper-V hosts that have guests will be down during the host reboot.</p>
<p>Please contact <a href="mailto:hsse@microsoft.com">hsse@microsoft.com</a> if you have any questions or concerns.</p>
"@
)

# This loads the module needed to login, without loading all of the other AzureRM modules
Import-Module -Name AzureRM.OperationalInsights
Import-Module -Name AzureRm.Automation

# Connect to Azure with RunAs account
$servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'
$addAccountParams = @{
    'ServicePrincipal' = $true
    'TenantId' = $servicePrincipalConnection.TenantId
    'ApplicationId' = $servicePrincipalConnection.ApplicationId
    'CertificateThumbprint' = $servicePrincipalConnection.CertificateThumbprint
}
$null = Add-AzureRmAccount @addAccountParams
$null = Select-AzureRmSubscription -SubscriptionId $servicePrincipalConnection.SubscriptionID

$credName = 'hvasmtp' 
$cred = Get-AutomationPSCredential -Name $credName 
$sendMailParams = @{
    'Subject'    = "Server Patching Notification"  
    'UseSsl'     = $true
    'Port'       = 587
    'SmtpServer' = 'smtp.office365.com'
    'From'       = 'hvasmtp@microsoft.com'
    'BodyAsHtml' = $true
    'Credential' = $cred
}

$getPatchingEngineParams = @{
    ServerFQDNList = $ServerFQDNList
}

$outstandingPatchingQuery = @"
Update
| where TimeGenerated>ago(14h) and OSType!="Linux" and (Optional==false or Classification has "Critical" or Classification has "Security") and SourceComputerId in ((Heartbeat
| where TimeGenerated>ago(12h) and OSType=~"Windows" and notempty(Computer)
| summarize arg_max(TimeGenerated, Solutions) by SourceComputerId
| where Solutions has "updates"
| distinct SourceComputerId))
| summarize hint.strategy=partitioned arg_max(TimeGenerated, *) by Computer, SourceComputerId, UpdateID
| where UpdateState=~"Needed" and Approved!=false
"@

$first = $true
foreach ($server in $ServerFQDNList) {
    if ($first) {
        $outstandingPatchingQuery += " | where Computer =~ `"$server`""
        $first = $false
    }
    else {
        $outstandingPatchingQuery += " or Computer =~ `"$server`""
    }
}

$outstandingPatchingQuery += "| render table"

Write-Output "Query used:`r`n$outstandingPatchingQuery"

$queryWorkspaceID = 'cf3aca56-df1a-4db7-b406-bfbbbe46f092'
$queryResults = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $queryWorkspaceID -Query $outstandingPatchingQuery

# Support TLS only for sending email
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls,TLS11,TLS12'

# Retrieve the asset group information for the servers we were passed
$patchingEngineDBData = Start-AzureRmAutomationRunbook -AutomationAccountName 'UpdatesManagement' -Name "Get-PatchingEngineData" -Parameters $getPatchingEngineParams -ResourceGroupName 'UpdatesManagement' -Wait
$uniqueAssetPropertyGroups = ($patchingEngineDBData).AssetPropertyGroup | Select-Object -Unique

Write-Output "Unique property asset groups: $($uniqueAssetPropertyGroups -join ', ')"

foreach ($propertyGroup in $uniqueAssetPropertyGroups) {
    # Get the servers that belong to the property group we're looking at
    $propertyGroupServers = $patchingEngineDBData | Where-Object {$_.AssetPropertyGroup -eq $propertyGroup}
    $propertyGroupContact = $propertyGroupServers.AssetPropertyGroupEmail | Select-Object -Unique
    $patchingServers = $ServerFQDNList | Where-Object {$_.ToLower() -in $propertyGroupServers.assetFQDN.ToLower()}

    $message = $OpeningMessage
    $message += '<p>Server being patched:</p>'
    $message += '<ul>'
    foreach ($server in $patchingServers) {
        # Compile the list of patches for each server and append it to the message being send to this property group
        # but only if it has outstanding patches
        # It would be a better performance choice to run one query to get all the patches for all the interesting servers, 
        # but doing that sometimes causes the query to fail (when you try to get too many rows) - this should be fixed in the
        # future, but for now, we just run a bunch of queries
        Write-Output "Checking server $server"
        $outstanding = $queryResults.Results | Where-Object {$_.Computer -eq $server}
        if ($outstanding.Count -gt 0) {
            Write-Output "Found $($outstanding.Count) patches for $server"
            $message += "<li><b>{0}</b></li>" -f $server
            $message += '<ul>'
            foreach ($result in $outstanding) {
                $message += '<li>{0} - {1}</li>' -f $result.Classification, $result.Title
            }
            $message += '</ul>'
        }
        else {
            Write-Output "Found no patches for $server"
            $message += "<li><b>{0}</b></p></li>" -f $server
            $message += "<ul><li>No outstanding patches found</li></ul>"
        }
    }
    $message += '</ul>'
    $message += "<p>Thank you.</p>"

    Send-MailMessage @sendMailParams -To $propertyGroupContact -Body $message
}
