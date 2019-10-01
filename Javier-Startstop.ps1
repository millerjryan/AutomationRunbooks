workflow Javier-Startstop
{
    #$Mycredential = Get-AutomationPSCredential -Name 'MSCredential'
    #Add-AzureRmAccount -Credential $Mycredential

    
    #Select-AzureRmSubscription -SubscriptionName "Mercantil Seguros Panama" 
  
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

    $currentTime = (Get-Date).ToUniversalTime()
    Write-Output "Inicio de Runbook"
    Write-Output "Hora UTC/GMT Actual [$($currentTime.ToString("dddd, yyyy MMM dd HH:mm:ss"))] sera chequeado contra la agenda"

    $day = (Get-Date).DayOfWeek
    if ($day -eq 'Saturday' -or $day -eq 'Sunday'){
        Write-Output "Maquinas virtuales fuera de Horario laboral, por lo tanto no seran encendidas"
        exit
    }

    Write-Output "Encendido de maquinas virtuales QA SirWeb"
    
    ##Iniciar servidores de QA##
    Write-Output "Iniciar Servidores SirWeb QA"
    Start-AzureRmVM -ResourceGroupName "vjomiLABrg" -Name "WIN-VM1-VJOMI" # BD Oracle #
    Start-Sleep -s 480  #Espero 8 min#
    Start-AzureRmVM -ResourceGroupName "vjomiLABrg" -Name "WIN-VM2-VJOMI" # Webfly #
    Start-AzureRmVM -ResourceGroupName "vjomiLABrg" -Name "WINSVR-VM1-VJOMI" # Webfly #

    $currentTime = (Get-Date).ToUniversalTime()
    Write-Output "Fin de Runbook"
    Write-Output "Hora UTC/GMT Actual [$($currentTime.ToString("dddd, yyyy MMM dd HH:mm:ss"))]"    
}