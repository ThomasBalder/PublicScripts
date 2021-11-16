<#
.SYNOPSIS
Script to uninstall Chrome with powershell (unattended). 

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 
Original from https://community.spiceworks.com/topic/2329474-how-uninstall-google-chrome-using-command-line?page=1#entry-9262005 
Also input from other script elsewhere that I can't remember.

.DESCRIPTION 
Script to uninstall Chrome with powershell (unattended). Intune / MEM compatible
I had some issues with Chrome not being detected properly, especially the ones in Appdata, so there are multiple ways to detect and remove Chrome.

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
#>
Start-Transcript "c:\scripts\logs\Uninstall Google Chrome.log" -force

# If chrome is running then close the process
If (Get-Process chrome -ErrorAction Continue) {
    Write-Output "Chrome is running, attempting to stop it."
    # Stop chrome process
    Stop-Process -Name chrome -Force
}

#Identify version and GUID of Google Chrome
Write-Output "Identifying Google Chrome location..."
$AppInfo = Get-WmiObject Win32_Product -Filter "Name Like 'Google Chrome'"
# $chromever = $AppInfo.Version
$GUID = $AppInfo.IdentifyingNumber
Write-Output "Google Chrome is installed as version:" *
Write-Output "Google Chrome has GUID of:" $GUID

#Uninstall using MSIEXEC
Write-Output "Attempting uninstall using MSIEXEC..."
& ${env:WINDIR}\System32\msiexec /x $GUID /Quiet /Passive /NoRestart

#region appdata
#Uninstall using Setup.exe uninstaller in users appdata
Write-Output "Checking if Chrome is installed in AppData, and if so: try to remove it."
$users = Get-ChildItem C:\Users | Where-Object { $_.name -notlike '*Default*' -and $_.name -notlike '*Public*' -and $_.name -notlike '*.NET*' }
foreach ($user in $users) {
    Write-Output $user.name
    #Test-Path -Path c:\users\$user\AppData\Local\Google\Chrome\Application\*\Installer\setup.exe}
    If (Test-Path -Path c:\users\$user\AppData\Local\Google\Chrome\Application\*\Installer\setup.exe) {
        Write-Output "Google Chrome is installed in AppData. Will try to remove it."
        & start-process c:\users\$user\AppData\Local\Google\Chrome\Application\*\Installer\setup.exe -ArgumentList '--uninstall', '--multi-install', '--chrome', '--system-level', '--force-uninstall'
    }
}
#endregion

#region all users (program files)
Write-Output "Checking if Chrome is installed in Program Files, and if so: try to remove it."
If (Test-Path -Path C:\Progra~1\Google\Chrome\Application\*\Installer\) {
    Write-Output "Google Chrome is installed as 64-bit program. Will try to remove it."
    & C:\Progra~1\Google\Chrome\Application\*\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
}
If (Test-Path -Path C:\Progra~2\Google\Chrome\Application\*\Installer\) {
    Write-Output "Google Chrome is installed as 32-bit program. Will try to remove it."
    & C:\Progra~2\Google\Chrome\Application\*\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
}
#endregion

#Uninstall using WMIC
Write-Output "Attempting uninstall using WMIC..."
wmic product where "name like 'Google Chrome'" call uninstall /nointeractive

#Look for Google Chrome in HKEY_CLASSES_ROOT\Installer\Products\
Write-Output "Deleting Google Chrome folder from HKLM:\Software\Classes\Installer\Products\"
$RegPath = "HKLM:\Software\Classes\Installer\Products\"

$ChromeRegKey = Get-ChildItem -Path $RegPath | Get-ItemProperty | Where-Object { $_.ProductName -match "Google Chrome" }
    
Write-Output "Product name found:" $ChromeRegKey.ProductName
Write-Output "Folder name found:" $ChromeRegKey.PSChildName

If (!$ChromeRegKey.PSChildName) {
    Write-Output "Google Chrome not found in HKEY_CLASSES_ROOT\Installer\Products\"
}
If ($ChromeRegKey.PSChildName) {
    $ChromeDirToDelete = "HKLM:\Software\Classes\Installer\Products\" + $ChromeRegKey.PSChildName
    Write-Output "Google Chrome directory to delete:" $ChromeDirToDelete
    Remove-Item -Path $ChromeDirToDelete -Force -Recurse
}

#wait for uninstall process to finish
Write-Output "Give the machine a moment to finish the uninstall before resuming."
Start-Sleep -Seconds 30

#Check if uninstall was succesful, otherwise just delete the folder.
foreach ($user in $users) {
    Write-Output $user.name
    If (Test-Path -Path c:\users\$user\AppData\Local\Google\Chrome\Application\*\Installer\setup.exe) {
        Write-Output "Chrome is still present in Appdata, will continue to remove folder."
        Remove-Item -Path c:\users\$user\AppData\Local\Google\Chrome -Recurse -Force -ErrorAction Continue
    }
}

#region registry
Write-Output "Check if Chrome is still present in registry, and try deleting Google Chrome folder from HKU:\S-1-5-21*\Software\Microsoft\Windows\CurrentVersion\Uninstall\\"

#Check for HKey Users registry drive. Create if needed
New-PSDrive HKU Registry HKEY_USERS

# Set Registry paths for user installed chrome. (Users who are not logged on will not be checked)
$ChomeAddRemoveKey = "HKU:\S-1-5-21*\Software\Microsoft\Windows\CurrentVersion\Uninstall\"
$ChromeKey = "HKU:\S-1-5-21*\Software\"

# Find and remove all user specific chrome installs from the registry.
foreach ($user in $users) {
    Write-Output $user.name
    Get-ChildItem $ChromeAddRemoveKey -ErrorAction SilentlyContinue -recurse | Where-Object { ($_.PSChildName -eq 'Google Chrome') -or ($_.PSChildName -eq 'Chrome') } | Remove-Item -Recurse -Force -ErrorAction Continue
    Get-ChildItem $ChromeKey -ErrorAction SilentlyContinue -recurse | Where-Object { ($_.PSChildName -eq 'Google Chrome') -or ($_.PSChildName -eq 'Chrome') } | Remove-Item -Recurse -Force -ErrorAction Continue
} 
#endregion registry

#region leftovers
#program files x86
Write-Output "Checking for leftovers and removing them."

If (Test-Path -Path C:\Progra~2\Google\Chrome\Application\*\Installer\) {
    Write-Output "Google Chrome folder is still present in Program Files (x86). Removing folder."
    Remove-Item -Path C:\Progra~2\Google\Chrome\ -Force -Recurse -ErrorAction Continue
}
If (Test-Path C:\Progra~2\Google\Chrome\Application\chrome.exe) {
    Write-Output "Chrome is present in Program Files (x86). Something went wrong."
}
else { 
    Write-Output "Chrome folder in Program Files (x86) succesfully removed, so Chrome is no longer present. Hooray!" 
}
# program files
If (Test-Path -Path C:\Progra~1\Google\Chrome\Application\*\Installer\) {
    Write-Output "Google Chrome folder is still present in Program Files. Removing folder."
    Remove-Item -Path C:\Progra~1\Google\Chrome\ -Force -Recurse -ErrorAction Continue 
}
If (Test-Path C:\Progra~1\Google\Chrome\Application\chrome.exe) {
    Write-Output "Chrome is present in Program Files. Something went wrong!"
}
else { 
    Write-Output "Chrome folder in Program Files succesfully removed, so Chrome is no longer present. Hooray!"
}
#appdata
If (Test-Path -Path c:\users\$user\AppData\Local\Google\Chrome\Application\*\Installer\setup.exe) {
    Write-Output "Chrome is still present in Appdata, will continue to remove folder."
    Remove-Item -Path c:\users\$user\AppData\Local\Google\Chrome -Recurse -Force -ErrorAction Continue
}
else {
    Write-Output "Chrome is not present in appdata. Hooray!" 
}

If (Test-Path -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk") {
    Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" -Force -ErrorAction Continue
}

If (Test-Path -Path "c:\users\public\desktop\Google Chrome.lnk") {
    Remove-Item -Path "c:\users\public\desktop\Google Chrome.lnk" -Force -ErrorAction Continue 
}

ForEach ($User in $users) {
    If (Test-Path -Path "c:\users\$user\desktop\Google Chrome.lnk") {
        Remove-Item -Path "c:\users\$user\desktop\Google Chrome.lnk" -Force -ErrorAction Continue 
    }
}

#endregion leftovers

Write-Output "Uninstall operations have all completed." 

Stop-Transcript