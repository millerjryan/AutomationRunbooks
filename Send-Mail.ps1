$to = "jomiller@microsoft.com"
# Load automation credential
$AutomationCreds = Get-AutomationPSCredential -Name 'emailcreds'
Write-Output "Credential Loaded"
$CredUsername = $AutomationCreds.UserName 
Write-Output "-------------------------------------------------------------------------" 
Write-Output "Credential Properties: " 
Write-Output "Username: $CredUsername" 
Write-Output "-------------------------------------------------------------------------" 
Write-Output "Sending to: $to"
Send-MailMessage -To 'jdeluca2@buffalo.edu' -Subject 'Automation Test' -Body 'This is a test' -UseSsl -Port 587 -SmtpServer 'smtp.office365.com' -From 'msol.DMVCPowershell@ubuffalo.onmicrosoft.com' -Credential $AutomationCreds
Write-Output "end"
