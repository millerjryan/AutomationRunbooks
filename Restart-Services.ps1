param(
	[parameter(Mandatory=$true)]
	[string[]]$ComputerName = "['machine1','machine2','machine3']",
	
	[parameter(Mandatory=$true)]
	[string]$ServiceName
)

    	foreach($Computer in $ComputerName) {
		
		Write-Output "Working on $Computer"
		if(Test-Connection -ComputerName $Computer -Count 1 -ea 0) {
            Write-Output "--------------------------------"
            Write-Output "$Computer is online"
			try {
				$ServiceObj = Get-Service -Name $ServiceName -ComputerName $Computer -ErrorAction Stop
				Restart-Service -InputObj $ServiceObj -erroraction stop
				Write-Output "Successfully restarted $Service on $Computer"
				
			} catch {
				Write-Output "Failed to restart $Service on $Computer. Error: $_"
			}
			
			
		}
		else {
			Write-Output "$Computer is not reachable"
			$IsOnline = $false
			
		}
		
	}
Write-Output "--------------------------------"
Write-Output "Completed Service Restarts"
