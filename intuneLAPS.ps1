<#
AUTHOR: Suchi Radha
Version 1.0
Info: This script was written by Suchi Radha for our blog :- https://intunezone.blogspot.com/
#>

####### Script Notes ######
# This script is designed to retrieve the current LAPS password from Azure AD for single specific device.
# Enter Tenant ID , client ID and app secret
###########################

$tenantId = 'xxxxxx'
$clientId = 'xxxxxx'
$appSecret = 'xxxxx'

$resourceAppIdURI = 'https://graph.microsoft.com'

$oAuthUri = 'https://login.microsoftonline.com/{0}/oauth2/token'  -f $tenantId

$authBody = [ordered] @{
    'resource'      = $resourceAppIdURI
    'client_id'     = $clientId
    'client_secret' = $appSecret
    'grant_type'    = 'client_credentials'
}

try{

    $authResponse = Invoke-RestMethod -Method Post -Uri $oAuthUri -Body $authBody -ErrorAction Stop
    $token = $authResponse.access_token
    Write-Host "Authentication successful."

     $ID = Read-host "Enter Device Name"

     $headers = @{
        'Content-type'  = 'application/json'
        'Accept'        = 'application/json'
        'Authorization' = "Bearer $token"
    }

   
     $uri = "https://graph.microsoft.com/beta/deviceManagement/manageddevices?`$filter=deviceName eq '$ID'"
     $Devicelist = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
     $deviceid = ($Devicelist.value).azureADDeviceId
     

    $uri = "https://graph.microsoft.com/beta/deviceLocalCredentials/{0}?`$select=credentials"  -f   $deviceid
    $headers1 = @{ 
        'Authorization' = "Bearer $token"
        'Content-Type'='application/json'
        'User-agent'= 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'
    }

    $response = Invoke-WebRequest -Uri $uri -Headers $headers1 -Method Get -ErrorAction Stop
    $Values = $Response.content|ConvertFrom-Json
    $credentials = $values.credentials
    $a= $credentials.passwordBase64
    $b=($a -split '\n')[0]
    $b|%{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
    Write-Host "Retrieved LAPS password of device ID $ID"
}
catch {
    Write-Host "An error occurred"
}

