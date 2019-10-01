param (
    # The list of servers to send a notification about
    [Parameter(Mandatory)]
    [string[]]$StringArray
)
#$StringArray = $StringtoArray.split(",")

Write-Output "Print array..."
Write-Output "=================="

#$getPatchingEngineParams = @{
    #ServerFQDNList = "$StringArray"
#}

foreach ($String in $StringArray) {
    Write-Output $String

}

#"params for aa"
#$getPatchingEngineParams