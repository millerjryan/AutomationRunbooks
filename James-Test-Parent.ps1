## Parent

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

$account = "vjomiLABauto"
$rgname = "vjomiLABrg"

$count = 0
$rgcount = 0

Start-AzureRmAutomationRunbook -Name "James-Test-Child" -AutomationAccountName $account -ResourceGroupName $rgname
<#Start-AzureAutomationRunbook -Name "Child-JH-ANSWERALS" -AutomationAccountName $account
 need to create
Start-AzureAutomationRunbook -Name "Child-JH-CITRIX" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-CLOUD" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-EES" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-EMMS" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-ESG" -AutomationAccountName $account

Start-AzureAutomationRunbook -Name "Child-JH-GENOMICS" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-GP" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-KSAS" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-MALONECENTER" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-RADIOLOGY" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-SOM-DOM" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-SWS" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-TEST" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-TIC" -AutomationAccountName $account
Start-AzureAutomationRunbook -Name "Child-JH-TRAINING" -AutomationAccountName $account #>

Write-Output "$($count) resource tags applied."
Write-Output "$($rgcount) resource group tags applied."

"End time is $(get-date)."
" "