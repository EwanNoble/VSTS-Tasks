﻿param
(
    [String] [Parameter(Mandatory = $true)] $folder,
	[String] [Parameter(Mandatory = $true)] $archive,
    [String] [Parameter(Mandatory = $true)] $archiveformat,
    [String] $removeFolderAfterExtraction,
    [String] $additionalArguments
)

Write-Verbose "Entering script Extract.ps1"  -Verbose

Write-Verbose "folder = $folder" -Verbose 
Write-Verbose "archive = $archive" -Verbose 
Write-Verbose "removeFolderAfterExtraction = $removeFolderAfterExtraction" -Verbose 
Write-Verbose "ArchiveFormat = $archiveformat" -Verbose 

if ($archiveformat -eq "7z" -and -not $archive.toLower().EndsWith('.7z')) { throw "File extension should end with .7z when Archive Format is [7z]"}

if ($archiveformat -eq "zip" -and -not $archive.toLower().EndsWith('.zip')) { throw "File extension should end with .zip when Archive Format is [zip]"}


function Get7ZipExe()
{ 
      
   $sz = "$env:ProgramFiles\7-Zip\7z.exe"
   $szx86 = "$env:ProgramFiles (x86)\7-Zip\7z.exe"
   
   Write-Verbose "sz = $sz" -Verbose 
   Write-Verbose "szx86 = $szx86" -Verbose 
   
   if ((test-path $sz)) { return $sz}  

   if ((test-path $szx86)) {return $szx86}  

   throw "7-zip is not installed on this machine." 
}

function CreateZip($folderPath, $archivePath)
{
    $Tokens =  [management.automation.psparser]::Tokenize($additionalArguments,[ref]$null) | ForEach-Object { $_.Content }
 
    if ($archiveformat -eq "7z") { 
        Write-Verbose "Arguments = a -r $Tokens $archivePath $folderPath" -Verbose
        sz a -r $Tokens $archivePath $folderPath
    }
    elseif ($archiveformat -eq "zip") { 
        Write-Verbose "Arguments = a -tzip -r $Tokens $archivePath $folderPath" -Verbose
        sz a -tzip -r $Tokens $archivePath $folderPath
    }
}

function RemoveFolder($folder)
{ 
Write-Verbose "Removing = $folder" -Verbose 

start-Sleep -m 4000
If (Test-Path $folder){
	    Remove-Item $folder -Recurse -Force
    }
}

$sa = Get7ZipExe
set-alias sz $sa

#Create the zip file. 
CreateZip -archivePath $archive -folderPath $folder

#Remove the folder
If ([System.Convert]::ToBoolean($removeFolderAfterExtraction))
{
    RemoveFolder($folder)  
}
