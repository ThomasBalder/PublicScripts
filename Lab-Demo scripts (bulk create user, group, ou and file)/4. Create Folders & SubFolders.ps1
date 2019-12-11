#======= Begin script ======
# Place the script and csv in root directory where you want to create the folders i.e. e:\data
# rename csv to FoldersNames.csv and check if it corresponds with the variable called $Folders in line 6
# Usage: from powershell cli navigate to script location i.e. e:\data
# Usage: then '.\4. Create Folders & SubFolders.ps1'
# This will create an array of objects which have the Name and Type properties as defined in the CSV.

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