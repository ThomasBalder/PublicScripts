<#
.SYNOPSIS
"Simple" script to import a csv file with devices for autopilit to your CSP customer.
Added one-time steps to make it work, but because I'm not a powershell ninja (yet), I don't know how to built a "check if installed, if so continue otherwise install and continue"
function, so you'll have to do those manual. Though most PS commands are there, so you just have to run those by hand. 

.Prerequisites
- Azure AD  module 
- CSP partner center module
- WindowsautopilotPartnerCenter module
- Consent tokens
- AAD Partner center web app
- Proper permissions on your (clients) tenant
- The one time configruation steps mentioned below
#>

<# one-time setup steps
#install proper powershell modules (this needs to be done for each user that is going to upload the csv)
Install-Module AzureAD –force
Install-Module PartnerCenter –force
Install-Module WindowsAutopilotPartnerCenter –force

#Find install location
Import-Module WindowsAutopilotPartnerCenter
Get-Module WindowsAutopilotPartnerCenter | format-list
sample output
Name              : WindowsAutopilotPartnerCenter
Path              : C:\Program Files\WindowsPowerShell\Modules\WindowsAutopilotPartnerCenter\1.1\WindowsAutopilotPartnerCenter.psm1
Description       : Sample module to manage AutoPilot devices 

#install Partner center AAD APP (Microsoft's script to do this is invalid, so until they fix it you have to do it by hand)
1.	Log in to the Partner Central, and go to the dashboard. 
2.	We need to get to the “account settings”. According to the documentation from Microsoft, when you go to dashboard, you should see app management, but at the time of writing that was not the case for me. So I’ll give you the way I did it:
    a.	Click on the cogwheel, and then select either option highlighted.
    b.	Next, click on “App management”
3.	Click on “add  a new web app”. The Web-app should now be created. It should look something like this (screenshot sanitized for obvious reasons).
    a.	Save everything you see in the screenshot (app, account, commerce id and especially the key!!) to a save place for later use.
4.	Log in (in a new tab) into your Azure tenant (not your clients!), and navigate to Azure Active directory.
a.	Scroll down to “app registrations”, and search for the created “Partner center web app”.
5.	Go to your created Partner center app, and navigate to the “api permissions” blade, and confirm that the status is Green / granted.
    a.	If the status is not green / say “granted for [your tenant name]”, press the “Grant admin consent for [tenant name]”, and follow the instructions for that (I believe you only need to press a button that you accept / consent).
 6.	Now navigate to the “authentication blade” of your app, and add the following url
    a.	http://localhost:8400
7.	Now scroll down to “Default client type”, and set the “Treat application as a public client.” to yes.

#Ceate authentication tokens (this needs to be done for each user that is going to upload the csv)
1. Open the PartnerCenter.xml (most likely in C:\Program Files\WindowsPowerShell\Modules\WindowsAutopilotPartnerCenter\1.1\) with notepad or alike
Change the AppId, AppSecret and PartnerTenantId to your own values, as created in step 3.3.a.
Sample xml	
<!-- Partner-specific settings, must be updated before using the module -->
	<AppID>a0c73c16-a7e3-4564-9a95-2bdf47383716</AppID>
	<AppSecret>Rf+SCRGwKWoroHqWWMQ9C71/hlDSl1dKivy6VRRD+XU=</AppSecret>
	<PartnerTenantID>a0c73c16-a7e3-4564-9a95-2bdf47383716</PartnerTenantID>

2.	In a (preferably elevated) PowerShell session, run the following commands:
    a.	$credential = Get-Credential 
        i.	Enter your AppId as username, and AppSecret as password.
    b.	New-PartnerAccessToken -ApplicationId ‘[yourazureadapplicationid]' -Scopes 'https://api.partnercenter.microsoft.com/user_impersonation' -ServicePrincipal -Credential $credential -Tenant ‘[yourtenantid]' -UseAuthorizationCode
        i.	This should open a webbrowser, and prompt another login page. This time, login with your Azure AD administrator or Partner center credentials.
        ii.	If succeeded, the message on the webpage should read: “Authentication complete. You can return to the application. Feel free to close this browser tab.” 
        iii.	If not, check the beginning your browser URL if that’s http://localhost:8400/. If it’s something else, change the URI redirection from step 3.6. They should match.
        iv.	Close the tab, and return to your Powershell session. You should now see the generated tokens. Save these somewhere save for future use. Microsoft recommends the Azure Key vault.
c.	If everything is setup correctly, you should see something like this:
    RefreshToken            : OAQABAAAAAACQN9QBRU3jT6bcBQLZNUj7PFhHjke-e7KfKO3g6_DmjQR_n5JaaxBjW3HLy7wwMGJc1UgweT4yqYTvkwf2eMKcSfd0B9YKPaOi7u5S6ZC2H5uyMAqakPKIXgWfBX5js6963WMj
                            dHRwczovL2FwaS5wYXJ0bmVyY2VudGVyLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC85ZDgxMWNmNy0wNmJiLTQxYmQtOGRlNS0xNTU4MjQ1M2RiMmYvI
                            iwiaWF0IjoxNTc2NTgxMTk0LCJuYmYiOjE1NzY1ODExOTQsImV4cCI6MTU3NjU4NTA5NCwiYWNyIjoiMSIsImFpbyI6IkFWUUFxLzhOQUFBQWVzSnVFUU5lS1JPQ0Z3eFhQckJCRG5kb0hCc0
                            VielpoOWI0RGpnR2tWRFZ0SVBIdGVMRWtOK29GcjRmTEg5RkVvS2MySUV2YWdVUHFreE9URzJUYm5JRWZZak9Jd0lETTN4aXBWSFdRM0tzPSIsImFtciI6WyJwd2QiLCJtZmEiXSwiYXBwaWQ
                            iOiJiYzVmYWVhOC0yY2M2LTQ1MTktYWIzYi02OGM5YTVkYjVhOTkiLCJhcHBpZGFjciI6IjEiLCJmYW1pbHlfbmFtZSI6IkJhbGRlciIsImdpdmVuX25hbWUiOiJUaG9tYXMiLCJpbl9jb3Jw
                            IjoidHJ1ZSIsImlwYWRkciI6IjgwLjExMi4yMjcuNjEiLCJuYW1lIjoiQWRtaW4gVGhvbWFzIEJhbGRlciIsIm9pZCI6ImZlYmU3OWZiLWM4MDctNDhlYi1hNjE4LWZiMTNiNGUwMGRmNyIsI
                            8zATnJz52HUUIkvS1nKPsFSLe9H4nff6UXNTBPd0XuBQVWGZIOwyzyKGX2rkJs9mHoKaO82RZj9A2OD2UB_9guT7j1p5FwPTeQqA9WpKjVy3WpS8jH9dfoLDOmg85Bq01nNStLsLx4s2qIcMv
                            hDbq36UZiwAI5MH5cEGqPY3lia7B4I-i9XxYFIwaeINEShpcalyAjsGXeIOadgViAA
    AccessToken             : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkJCOENlRlZxeWFHckdOdWVoSklpTDRkZmp6dyIsImtpZCI6IkJCOENlRlZxeWFHckdOdWVoSklpTDRkZmp6dyJ9.eyJhdWQiOiJo
                            UwjWE6x7wcw_ecI7xaE1i-u8ZyBH-8HuS4wtVzUtvX05-Q22GO1XhWGIlOM9hPX_fGt4xk2TtEe8otk8jQk6Ll_RBmVj2afDvPb1S8r5XswhQEFBD-85FWc8DVQSsDGU7VCsrjICL0JfiD53b
                            tAikyvjgyPVu4mPLxg0WlMMpYIzurp4bZaxuW-PGORVfzNfXhC28zR5gNu8i4o580anSefcnUwRkEtzLDUV6JCRrAPBIPpvdXekl-GrqT6zfzwUO7J4zemYMX_b1wP8Xb-hXa9_yZPVWz4F1g
                            gmpTeJhox6IVNlq8HJ1P2FsHZ7a8AhUWsWRMrayr8FcSFsJlY--Ue4AY7QZ-tpe2-N9nNBaKcdzzF5NZHtKnEsYvbsE1YJ11dzuY-jyp0EC5omma2IbzuMM_CJypFKRUyIxwCN16SBsMssqeC
                            lXT-xsibkxaHvBZwEekL2bxmSv1aRsM_HauI74A9zKlpWmFqE5JZOOx-xr3kW5ZkQ0MiCxOmjKUiqBEj36JD2Aeocy-i7RG4S7ajbKeEoOj0gqQYNj13GMyEtTVIZC5GPgp9WtSu5F5Y3aiBK
                            ts610N9ag2yx98NJWOG_DcCxsNM-jrVSWucHXp9Cs99TBqDIj7gGn2U9_-sZ8nAzCzSo_4ICfwmcr9sDpDZ4-tCVHFiYsFmEmH1_AJtzwU-u5HUgnZ8JLcpg1w-EXGepOlGt6M2pTQw-OvUfi
                            m9ucHJlbV9zaWQiOiJTLTEtNS0yMS0zMzg1MTc0NzA4LTMxMjUwODM2NjMtMjg2MDkwMzk1LTE5ODM1IiwicHVpZCI6IjEwMDNCRkZEQUU1QzExRjYiLCJzY3AiOiJ1c2VyX2ltcGVyc29uYX
                            Rpb24iLCJzdWIiOiI2YWhCVUJxQS1idXcxWmtsSWZvS01xbE5BdnAya1hnN3ZfWXZDNWt2R1dJIiwidGVuYW50X3JlZ2lvbl9zY29wZSI6IkVVIiwidGlkIjoiOWQ4MTFjZjctMDZiYi00MWJ
                            kLThkZTUtMTU1ODI0NTNkYjJmIiwidW5pcXVlX25hbWUiOiJhZG1pbnRiYUBxbmgubmwiLCJ1cG4iOiJhZG1pbnRiYUBxbmgubmwiLCJ1dGkiOiJQRGdqM05fbnowcW9UZC1Cd2xoT0FBIiwi
                            dmVyIjoiMS4wIn0.Uf1rRKCostNOFUN_Y55oy99Ynk9Jv4dscNWzBRglFMb1Uy6b-o2Bf9E0GJ5uSvpuFWTlS490p_4ZIv2_ClOUcB9LKoIK-HG79Pb0V9RyC7czWqRLf7jtOUq3aPS09C2TY
                            4a7te7fLy_ECvkQZ3mPt-s-mMiPkQDPbwMPjKZYjWtQ3NMI9h3q1W3e9EMRxouy7H36VJWZGI2W2FHqcICboK5Jqjt1U7TTjSdIHjZfaUAw-6pQJmmblMr9HJE9l--WC17KgVmzGRBpxzppya
                            kknE9ABmSJ6UC3T0WU6UgPXJBLPZ4-hVy9CHtJc2YJSHuptQo4YGc-8XVhGghhRqmCqg
    IsExtendedLifeTimeToken : False
    UniqueId                : fb13b4e0-c807-48eb-a618-febe79fb0df7
    ExpiresOn               : 17-12-2019 12:18:13 +00:00
    ExtendedExpiresOn       : 17-12-2019 12:18:13 +00:00
    TenantId                : 9d811cf7-06bb-41bd-8de5-15582453db2f
    Account                 : Account username: youradmintaccount@yourdomain.com environment login.windows.net home account id: AccountId: fb13b4e0-c807-48eb-a618-febe79fb0df7.9d811cf7-06bb-41
                            bd-8de5-15582453db2f
    IdToken                 : eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IkJCOENlRlZxeWFHckdOdWVoSklpTDRkZmp6dyIsImtpZCI6IkJCOENlRlZxeWFHckdOdWVoSklpTDRkZmp6dyJ9.eyJhdWQiOiJo
                            UwjWE6x7wcw_ecI7xaE1i-u8ZyBH-8HuS4wtVzUtvX05-Q22GO1XhWGIlOM9hPX_fGt4xk2TtEe8otk8jQk6Ll_RBmVj2afDvPb1S8r5XswhQEFBD-85FWc8DVQSsDGU7VCsrjICL0JfiD53b
                            tAikyvjgyPVu4mPLxg0WlMMpYIzurp4bZaxuW-PGORVfzNfXhC28zR5gNu8i4o580anSefcnUwRkEtzLDUV6JCRrAPBIPpvdXekl-GrqT6zfzwUO7J4zemYMX_b1wP8Xb-hXa9_yZPVWz4F1g
                            gmpTeJhox6IVNlq8HJ1P2FsHZ7a8AhUWsWRMrayr8FcSFsJlY--Ue4AY7QZ-tpe2-N9nNBaKcdzzF5NZHtKnEsYvbsE1YJ11dzuY-jyp0EC5omma2IbzuMM_CJypFKRUyIxwCN16SBsMssqeC
                            lXT-xsibkxaHvBZwEekL2bxmSv1aRsM_HauI74A9zKlpWmFqE5JZOOx-xr3kW5ZkQ0MiCxOmjKUiqBEj36JD2Aeocy-i7RG4S7ajbKeEoOj0gqQYNj13GMyEtTVIZC5GPgp9WtSu5F5Y3aiBK
                            ts610N9ag2yx98NJWOG_DcCxsNM-jrVSWucHXp9Cs99TBqDIj7gGn2U9_-sZ8nAzCzSo_4ICfwmcr9sDpDZ4-tCVHFiYsFmEmH1_AJtzwU-u5HUgnZ8JLcpg1w-EXGepOlGt6M2pTQw-OvUfi
                            m9ucHJlbV9zaWQiOiJTLTEtNS0yMS0zMzg1MTc0NzA4LTMxMjUwODM2NjMtMjg2MDkwMzk1LTE5ODM1IiwicHVpZCI6IjEwMDNCRkZEQUU1QzExRjYiLCJzY3AiOiJ1c2VyX2ltcGVyc29uYX
                            Rpb24iLCJzdWIiOiI2YWhCVUJxQS1idXcxWmtsSWZvS01xbE5BdnAya1hnN3ZfWXZDNWt2R1dJIiwidGVuYW50X3JlZ2lvbl9zY29wZSI6IkVVIiwidGlkIjoiOWQ4MTFjZjctMDZiYi00MWJ
                            kLThkZTUtMTU1ODI0NTNkYjJmIiwidW5pcXVlX25hbWUiOiJhZG1pbnRiYUBxbmgubmwiLCJ1cG4iOiJhZG1pbnRiYUBxbmgubmwiLCJ1dGkiOiJQRGdqM05fbnowcW9UZC1Cd2xoT0FBIiwi
                            dmVyIjoiMS4wIn0.Uf1rRKCostNOFUN_Y55oy99Ynk9Jv4dscNWzBRglFMb1Uy6b-o2Bf9E0GJ5uSvpuFWTlS490p_4ZIv2_ClOUcB9LKoIK-HG79Pb0V9RyC7czWqRLf7jtOUq3aPS09C2TY
                            4a7te7fLy_ECvkQZ3mPt-s-mMiPkQDPbwMPjKZYjWtQ3NMI9h3q1W3e9EMRxouy7H36VJWZGI2W2FHqcICboK5Jqjt1U7TTjSdIHjZfaUAw-6pQJmmblMr9HJE9l--WC17KgVmzGRBpxzppya
                            kknE9ABmSJ6UC3T0WU6UgPXJBLPZ4-hVy9CHtJc2YJSHuptQo4YGc-8XVhGghhRqmCqg

Now before we can continue with the actual import the devices, we need to know our clients CustomerID.
3.	In a (preferably elevated) PowerShell session, run the following commands:
    a.	Connect-AutopilotPartnerCenter [a browser (tab) should open to log you in with your Partner Center account. After that’s successful, Powershell should have succesuflly authenticated you.]
    b.	Get-PartnerCustomer 
        Sample output
        CustomerId                           Domain                                     Name
        ----------                           ------                                     ----
        95b64b6c-b12c-4d1d-b021-789520993763 customer1.onmicrosoft.com                  Customer 1
        c775ec94-1be2-4b8b-db3c-ce48095a1220 customer2.onmicrosoft.com                  Customer 2
    c.	Save or write down the CustomerID for your client. We’re going to need this later.

That's it for the one time steps.


#>


<# csv example
Autopilot/intune is very picky about the csv file format and content (especially the Manufacturer name), so here's an example:
#Microsoft example
    Device serial number,Windows product ID,Hardware hash,Manufacturer name,Device model
    R9-ZNP67,00329-00000-0003-AA606,T0FzAQEAHAAAAAoA6AOCOgEABgBgW7EdzorHH3g,,,

#realworld example
    Device serial number,Windows product ID,Hardware hash,Manufacturer name,Device model
    PF02NCT8,,,LENOVO,20B6008MMH
    PC0XDW8P,,,LENOVO,20L7001LMH

Get the model and Manufacturer on a test machine to check if your Manufacturer name is accurate:
1.	On a model you want to import, open up a CMD prompt and type:
	wmic computersystem get model,manufacturer
    Manufacturer  Model
    LENOVO        20L7001LMH

    To get the serialnumber type: 
    wmic bios get serialnumber
    SerialNumber
    PC0XDW8P

#>

#region actual start of script to connect to partnercenter and import CSV
# connect to partner center.
Write-host "First, lets connect to the partner center. A browser (tab) should open to log you in with your Partner Center account. 
After that’s successful, Powershell should have succesfully authenticated you." -Foregroundcolor Yellow
connect-partnercenter

Write-host "Enter the full filename of the csv you want to import (i.e. C:\temp\PartnerCenterBatch.csv)"  -ForegroundColor Yellow
$csvfile = Read-Host 

Write-host "Thank you. Now enter the customerid of the customer you want to import it for (i.e. 95b64b6c-b12c-4d1d-b021-789520993763)"  -ForegroundColor Yellow
$customerid = Read-Host 

#get customer list (optional)
#get-partnercustomer

Write-host "Thank you. Now enter a description for the import job in '""' (i.e. ""test batch"")"  -ForegroundColor Yellow
$BatchID = Read-Host 

Write-host "Thank you. Now we will import the csv file."  -ForegroundColor Green

#import devices
Import-AutoPilotPartnerCenterCSV -csvFile $csvFile -CustomerID $customerid -BatchID $BatchID

Write-host "Done. Review the import errors if there are any and edit the csv accordingly. 
I'm going to close the connection now."  -ForegroundColor Green

#disconnect / remove sessions
Write-Host "Get-PSSession | Remove-PSSession"
Get-PSSession | Remove-PSSession

#endregion & end of script.