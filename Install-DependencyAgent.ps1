# Set the parameters 
$SMFileName = "InstallDependencyAgent-Windows.exe" 
$OMSFolder = 'C:\Source' 
$SMFile = $OMSFolder + "\" + $SMFileName 
 
# Start logging the actions 
Start-Transcript -Path C:\temp\OMSAgentInstallLog.txt -NoClobber 
 
# Check if folder exists, if not, create it 
 if (Test-Path $OMSFolder){ 
 Write-Host "The folder $OMSFolder already exists." 
 }  
 else  
 { 
 Write-Host "The folder $OMSFolder does not exist, creating..." -NoNewline 
 New-Item $OMSFolder -type Directory | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 } 
 
# Change the location to the specified folder 
Set-Location $OMSFolder 
 
# Check if Service Map Agent exists, if not, download it 
 if (Test-Path $SMFileName){ 
 Write-Host "The file $SMFileName already exists." 
 } 
 else 
 { 
 Write-Host "The file $SMFileName does not exist, downloading..." -NoNewline 
 $URL = "https://aka.ms/dependencyagentwindows" 
 Invoke-WebRequest -Uri $URl -OutFile $SMFile | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 }  
 
# Install the Service Map Agent 
Write-Host "Installing Service Map Agent.." -nonewline 
$ArgumentList = '/C:"InstallDependencyAgent-Windows.exe /S /AcceptEndUserLicenseAgreement:1"' 
Start-Process $SMFileName -ArgumentList $ArgumentList -ErrorAction Stop -Wait | Out-Null 
Write-Host "done!" -ForegroundColor Green 
 
# Change the location to C: to remove the created folder 
Set-Location -Path "C:\" 
 
<# 
# Remove the folder with the agent files 
 if (-not (Test-Path $OMSFolder)) { 
 Write-Host "The folder $OMSFolder does not exist." 
 }  
 else  
 { 
 Write-Host "Removing the folder $OMSFolder ..." -NoNewline 
 Remove-Item $OMSFolder -Force -Recurse | Out-Null 
 Write-Host "done!" -ForegroundColor Green 
 } 
#> 
 
Stop-Transcript

