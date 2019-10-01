# Parameters 
    Param( 
        [Parameter (Mandatory= $true)] 
        [string]$DBName, 
 
        [Parameter (Mandatory =$true)] 
        [string]$ResourceGroupName,
        
        [Parameter (Mandatory =$true)] 
        [string]$ServerName,  
        
        [Parameter (Mandatory =$true)] 
        [int32]$Vcore, 

        [Parameter (Mandatory =$true)] 
        [string]$ComputerGeneration,

        [Parameter (Mandatory =$true)] 
        [string]$Edition

       ) 


################
# Auth with Azure

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
# End of Auth
################

# Get DB first

$db = Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DBName

#debug finding resource
Write-Output "Printing the DB data:::"
Write-Output "Before Change:"
Write-Output $db
# Change EPOOL 
Write-Output "After Change:"
$dbChanges = Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $ServerName -DatabaseName $DBName -Edition $Edition -VCore $Vcore -ComputeGeneration $ComputerGeneration  #-Dtu $DTU -DatabaseDtuMax $DatabaseDTUMax -DatabaseDtuMin $DatabaseDTUMin
Write-Output $dbChanges
