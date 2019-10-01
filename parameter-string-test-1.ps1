param (
    # The list of servers to send a notification about
    [Parameter(Mandatory)]
    [string[]]$StringArray
)
#$StringArray = $StringtoArray.split(",")

Write-Output "Print array..."
Write-Output "=================="

$StringtoArray = $StringArray | convertto-csv



$parms = @{
    "StringArray" = 'vm1','vm2','vm3'
    #"StringArray" = $StringtoArray
    }

foreach ($String in $StringArray) {
    Write-Output $String

}

"Print CSV"
"++++++++++++++++++"
$StringtoArray

Start-AzAutomationRunbook -Name "parameter-string-test" -Parameters $parms -AutomationAccountName vjomiLABauto -ResourceGroupName vjomiLABrg