<#
.SYNOPSIS
Script to remove words in a file shorter than given length.

.AUTHOR 
Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V5


.INSTRUCTIONS
- Run script in an elevated (administrator) Powershell prompt;
#>

$words = get-content "C:\Temp\EN-words.txt"
foreach ($line in $words) {
    if (($line.length -ge 4) -and ($line -cmatch "^[a-z]*$")) {
        $line | out-file -FilePath "C:\Temp\EN-words_4-6.txt" -Append
    }
}