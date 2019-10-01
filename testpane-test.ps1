param(
        [Parameter(Mandatory=$true)]
        [int] $workItemId,
        [Parameter(Mandatory=$true)]
        [string] $environment
    )
    
$script:CDCred = (Get-AutomationPSCredential -Name 'svc-dbacd')
. ./RedgateContinuousDeployment.ps1

#$releaseObject = createReleaseObject -workItemId $workItemId -environment $environment
#$releaseObject = New-Object PSObject -Property @{
#       WorkItemId              = "09876"
#}
#write-output "$($releaseObject | ConvertTo-Json)"
$location = get-location
write-output "test"
write-output $location