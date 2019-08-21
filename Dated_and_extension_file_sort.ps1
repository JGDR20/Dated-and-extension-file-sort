### CHANGE DEFAULTS in $defaultVals hashtable below!!!
## Parameters for $daysOldest, $daysNewest (counting back from now)
## $description name (allows blank/null)
## $source and $destination directories
## $include extension filter e.g. *.jpg, *.avi as an array with one extension per element
##	# example: include[0]: *.jpg - include[1]: *.avi
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)][AllowNull()][int]$daysOldest,
	[Parameter(Mandatory=$True)][AllowNull()][int]$daysNewest,
	[Parameter(Mandatory=$True)][AllowEmptyString()][string]$description,
	[Parameter(Mandatory=$True)][AllowEmptyString()][string]$source,
	[Parameter(Mandatory=$True)][AllowEmptyString()][string]$destination,
	[Parameter(Mandatory=$True)][AllowEmptyCollection()][array]$include
)

## Stop running the script if any errors occur
$ErrorActionPreference = "Stop"

## Default Values hashtable
## CHANGE ME ##
$defaultVals = @{
	"daysOldest" = 0;
	"daysNewest" = 0;
	"description" = "";
	"source" = "D:\User\Documents\Some\Source";
	"destination" = "D:\User\Documents\Some\Destination";
	"include" = @(
		"*"
	)
}

## Running Values hashtable
$runningVals = @{
	"daysOldest" = $daysOldest;
	"daysNewest" = $daysNewest;
	"description" = $description;
	"source" = $source;
	"destination" = $destination;
	"include" = $include
}

## Functions:
# Get-ScriptDirectory to find the directory of the script
function Get-ScriptDirectory {
	Split-Path $script:MyInvocation.MyCommand.Path
}

## Prepare running variables with prompt values if present, otherwise defaults
function Running-Variables ($promptVal, $defaultVal) {
	If ($promptVal) {
		$running = $promptVal
	} Else {
		$running = $defaultVal
	}
	return $running
}

# Check and load variables from $defaultVals into $runningVals if $runningVals is blank/empty for each key
ForEach ($key in $defaultVals.Keys) {
	$runningVals[$key] = Running-Variables -promptVal $runningVals[$key] -defaultVal $defaultVals[$key]
}

# Locations validity check
$runningVals.source = Resolve-Path($runningVals.source)
$runningVals.destination = Resolve-Path($runningVals.destination)

## Dates to copmpare
$Today = (Get-Date).Date
$StartDate = $Today.AddDays(-$runningVals.daysOldest)
$EndDate = $Today.AddDays(-$runningVals.daysNewest)
# Check if date range is valid
If ($runningVals.daysOldest -lt $runningVals.daysNewest) {
	Read-Host -Prompt "Invalid date range, the oldest date is after the newest date. Press Enter to exit"
	exit
}

## Prepend " - " to $description if populated, else leave blank
If ($runningVals.description) {
	$runningVals.description = " - " + $runningVals.description
}

## Output the settings to the user
Write-Host Copying files between ($StartDate).ToString("yyyy-MM-dd") and ($EndDate).ToString("yyyy-MM-dd")
Write-Host From  $runningVals.source to $runningVals.destination
Write-Host Using these extensions only: $runningVals.include

# Find all '-include'ed files in $source, created within the date range specified
# Add -recursive to Get-ChildItem in the below line (before the | ) to search subdirectories
Get-ChildItem -Path "$($runningVals.source)\*" -Include $runningVals.include |
	# Compare the creation dates only (remove time - e.g. 2001-03-24 06:00:00 becomes 2001-03-24)
	Where-Object {($_.CreationTime).Date -ge $StartDate `
			-and ($_.CreationTime).Date -le $EndDate} |
	# For each file found...
	ForEach-Object {
		# Create a destination folder (destination\date - description\file extension
		$Folder = Join-Path -Path $runningVals.destination -ChildPath (($_.CreationTime).ToString("yyyy-MM-dd") + $runningVals.description)
		$Folder = Join-Path -Path $Folder -ChildPath ($_.Extension).Substring(1).ToUpper()
		$File = Join-Path -Path $Folder -ChildPath $_.Name
		
		# See if the destination folder already exists and create it if not
		If (!(Test-Path $Folder -PathType Container))
			{
			New-Item -ItemType Directory -Path $Folder
			}
		
		# Test if the file exists in destination and copy if not
		If (Test-Path -Path $File)
			{
			Write-Host [-] $_.Name exists in $Folder\
			}
		Else
			{
			Write-Host [+] Copying: $_.Name to $Folder\
			Copy-Item -Path $_.FullName -Destination $Folder
			}
		}

## Clean-up
Remove-Variable -name defaultVals
Remove-Variable -name runningVals

Write-Host Finished
Read-Host -Prompt "Press Enter to exit"