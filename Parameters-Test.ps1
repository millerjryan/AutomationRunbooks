Param(
    [Parameter(mandatory=$true,
    HelpMessage="Enter one or more computer names separated by commas.")]
    [String[]]
    $ComputerName = "Test"
)

Get-AzureRmVm