$TenantId = '************************************'
$ClientId = '************************************'
$Secretid = '************************************'


function Auth() {
    $ReqTokenBody = @{
        Grant_Type = 'client_credentials'
        client_id = $ClientId
        client_Secret = $Secretid
        Scope = 'https://graph.microsoft.com/.default'
    }
    $r = Invoke-RestMethod -Method "POST" -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $ReqTokenBody
    return $r
}




function Req($URL, $Auth){

$request = Invoke-RestMethod -Method "GET" -Uri $URL -Headers @{Authorization = "Bearer $($Auth.access_token)"}

return $request

}









$auth = Auth



$user = Get-Content -Path 'C:\Users\shivam.a.malik\OneDrive - 1\Desktop\TW.csv'

$url = 'https://graph.microsoft.com/beta/users?$top=999&$select=displayName,userPrincipalName,signInActivity'

$r = Req -URL $url -Auth $auth



$r.value | Where-Object {($_.userPrincipalName -in $user)} | Select displayName, userPrincipalName, @{Label="lastSignInDateTime";Expression={$_.signInActivity.lastSignInDateTime}}, @{Label="lastNonInteractiveSignInDateTime";Expression={$_.signInActivity.lastNonInteractiveSignInDateTime}} | Export-csv -Path "C:\Users\shivam.a.malik\OneDrive - 1\Desktop\TW2.csv" -notypeinformation -Append









$pages = $r.'@odata.nextLink'

For (;$pages -ne '';){

$url = $pages
$r = Req -URL $url -Auth $auth
$r.value | Where-Object {($_.userPrincipalName -in $user)} | Select displayName, userPrincipalName, @{Label="lastSignInDateTime";Expression={$_.signInActivity.lastSignInDateTime}}, @{Label="lastNonInteractiveSignInDateTime";Expression={$_.signInActivity.lastNonInteractiveSignInDateTime}} | Export-csv -Path "C:\Users\shivam.a.malik\OneDrive - 1\Desktop\TW2.csv" -notypeinformation -Append
$pages = $r.'@odata.nextLink'

}

