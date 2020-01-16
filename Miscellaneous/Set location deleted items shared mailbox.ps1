<#
.SYNOPSIS
Script to create a registry item to disable deleted items from a shared mailbox going into your own deleted items folder.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 
Creates a registry item to disable deleted items from a shared mailbox going into your own deleted items folder.
DWORD value:
    8 = Stores deleted items in your folder.
    4 = Stores deleted items in the mailbox owner's folder.

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Change DWORD value to suit your needs
- Run script in an elevated (administrator) Powershell prompt;
#>


$regPath = 'HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\General'
New-Item $regPath -Force | Out-Null
New-ItemProperty $regPath -Name DelegateWastebasketStyle -Value 4 -Force | Out-Null