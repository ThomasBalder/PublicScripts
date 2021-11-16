<#
.SYNOPSIS
Script to set the user locale and timezone settings.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 

.REQUIREMENTS
- At least Powershell V5

.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
#>


# Set timezone & user locale to Dutch but with English interface
Set-WinSystemLocale -SystemLocale en-US
Set-WinUserLanguageList -LanguageList en-US -Force
Set-culture nl-NL
Set-WinHomeLocation -GeoId 176
Set-TimeZone -Name "W. Europe Standard Time"

# Set timezone & user locale to Swiss but with English interface
Set-WinSystemLocale -SystemLocale en-US
Set-WinUserLanguageList -LanguageList de-CH -Force
Set-culture de-CH
Set-WinHomeLocation -GeoId 223
Set-TimeZone -Name "W. Europe Standard Time"

# Set timezone & user locale to German but with English interface
Set-WinSystemLocale -SystemLocale en-US
Set-WinUserLanguageList -LanguageList de-DE -Force
Set-culture de-DE
Set-WinHomeLocation -GeoId 94
Set-TimeZone -Name "W. Europe Standard Time"

