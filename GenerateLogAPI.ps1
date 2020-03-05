# Replace with your Workspace ID
$CustomerId = "5b7892fa-f9a9-4cca-a8c6-f3b46c06fa9f"  

# Replace with your Primary Key
$SharedKey = "ceWajXdrF/2bXE7Y/DcgWZcQDo3TataeFMpdXIV083f88I4I9BoSziFPwQ9RNwH/SUPDL+66wG8aqdPUwp85BA=="

# Specify the name of the record type that you'll be creating
$LogType = "PowerShellLogAPI"

# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = "DateValue"

#Variables for Data Generation
$GenGuid1 = [System.Guid]::NewGuid()

$GenGuid2 = [System.Guid]::NewGuid()

$GenGuid3 = [System.Guid]::NewGuid()

$jobIDnum = $PSPrivateMetadata.JobId.Guid

$timestamp = Get-Date -Format s | ForEach-Object { $_ -replace ":", "." }


# Create two records with the same set of properties to create
$json = @"
[{  "Information": "Entry #1",
    "JobIDnum": $jobIDnum,
    "BooleanValue": true,
    "DateValue": $timestamp + "Z",
    "GenGUIDValue": $GenGuid1
},
{  "Information": "This is Number 2",
    "JobIDnum": $jobIDnum,
    "BooleanValue": true,
    "DateValue": $timestamp + "Z",
    "GenGUIDValue": $GenGuid2
},
{  "Information": "This is number 3",
    "JobIDnum": $jobIDnum,
    "BooleanValue": true,
    "DateValue": $timestamp + "Z",
    "GenGUIDValue": $GenGuid3
}]
"@

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
    $xHeaders = "x-ms-date:" + $date
    $stringToHash = $method + "`n" + $contentLength + "`n" + $contentType + "`n" + $xHeaders + "`n" + $resource

    $bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
    $keyBytes = [Convert]::FromBase64String($sharedKey)

    $sha256 = New-Object System.Security.Cryptography.HMACSHA256
    $sha256.Key = $keyBytes
    $calculatedHash = $sha256.ComputeHash($bytesToHash)
    $encodedHash = [Convert]::ToBase64String($calculatedHash)
    $authorization = 'SharedKey {0}:{1}' -f $customerId,$encodedHash
    return $authorization
}


# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}

# Submit the data to the API endpoint
Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
