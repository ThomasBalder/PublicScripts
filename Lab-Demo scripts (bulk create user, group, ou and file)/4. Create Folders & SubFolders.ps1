<#
.SYNOPSIS
Script to create folders & subolders from a csv file.

.AUTHOR 
Someone @ StackExchange: https://superuser.com/questions/808704/create-multiple-folders-and-sub-folders

Thomas Balder (inspired by others)
https://github.com/ThomasBalder/PublicScripts 

.DESCRIPTION 


.REQUIREMENTS
- At least Powershell V4

.INSTRUCTIONS
- Place the script and csv in root directory where you want to create the folders i.e. e:\data
- Rename csv to FoldersNames.csv and check if it matches the variable called $Folders below
- Run script in an elevated (administrator) Powershell prompt on a fileserver from the script location i.e. e:\data
- Example: PS E:\data> '.\4. Create Folders & SubFolders.ps1'
- This will create an array of objects which have the Name and Type properties as defined in the CSV.
#>

$Folders=Import-Csv .\FolderNames.csv";

# Filter $Folders down to just objects with a Type value of 'Folder'.
# ? is a built-in alias for Where-Object.

$Folders|?{$_.Type-eq'Folder'}|

# Send the filtered objects into a ForEach-Object loop.
# % is a built-in alias for ForEach-Object.
%{
    # Store the current object's Name in $ParentName.

    $ParentName=$_.Name;

    # Create a new directory named $ParentName.

    New-Item "$ParentName" -ItemType Directory;

    # Filter $Folders down to just objects with a Type value of 'Subfolder'.

    $Folders|?{$_.Type-eq'Subfolder'}|

    # Send the filtered objects into a ForEach-Object loop.
    %{
        # Store the current object's Name in $ChildName.

        $ChildName=$_.Name;

        # Create a new subfolder in $ParentName called $ChildName.

        New-Item "$ParentName\$ChildName" -ItemType Directory
    }
}