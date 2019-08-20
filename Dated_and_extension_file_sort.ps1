### CHANGE DEFAULTS IN .\config.xml!!!
## Parameters for $daysOldest, $daysNewest (counting back from now)
## $description name (allows blank/null)
## $source and $destination directories ## CHANGE ME ##
## $include extension filter e.g. *.jpg, *.avi
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)][AllowNull()][int]$daysOldest,
	[Parameter(Mandatory=$True)][AllowNull()][int]$daysNewest,
	[Parameter(Mandatory=$True)][AllowEmptyString()][string]$description,
    [Parameter(Mandatory=$True)][AllowEmptyString()][string]$source,
    [Parameter(Mandatory=$True)][AllowEmptyString()][string]$destination,
    [Parameter(Mandatory=$True)][AllowEmptyString()][string]$include
)

## Stop running the script if any errors occur
$ErrorActionPreference = "Stop"

## Function Get-ScriptDirectory to find the directory of the script
function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

## Get config values from .\config.xml
$config = ([xml](Get-Content (Join-Path -Path (Get-ScriptDirectory) -ChildPath config.xml))).config

## Check and load variables from config if blank/empty
# Days
If (!($daysOldest)) {
    $daysOldest = $config.daysOldest
}
If (!($daysNewest)) {
    $daysNewest = $config.daysNewest
}

# Set $description
If (!($description)) {
    $description = $config.description
}

# Check if .\config.xml is populated with paths
If (!($config.source -and $config.destination)) {
	Read-Host -Prompt "Blank source or destination in .\config.xml, press Enter to exit"
	exit
}
# Locations; $source = Source directory, $destination = Parent destination directory
If (!($source)) {
    $source = Resolve-Path($config.source)
} Else {
    $source = Resolve-Path($source)
}
If (!($destination)) {
    $destination = Resolve-Path($config.destination)
} Else {
    $destination = Resolve-Path($destination)
}

# File filter; $include
If (!($include)) {
    $include = $config.include
}

## Dates to copmpare
$Today = (Get-Date).Date
$StartDate = $Today.AddDays(-$daysOldest)
$EndDate = $Today.AddDays(-$daysNewest)
# Check if date range is valid
If ($daysOldest -lt $daysNewest) {
    Read-Host -Prompt "Invalid date, press Enter to exit"
	exit
}

## Prepend " - " to $description if populated, else leave blank
If ($description) {
    $description = " - " + $description
}

## Output the settings to the user
Write-Host Copying files between ($StartDate).ToString("yyyy-MM-dd") and ($EndDate).ToString("yyyy-MM-dd")
Write-Host From $source to $destination
Write-Host Using these extensions only: $include

# Find all '-include'ed files in $source, created within the date range specified
# Add -recursive to Get-ChildItem in the below line (before the | ) to search subdirectories
Get-ChildItem $source\* -Include $include |
	# Compare the creation dates only (remove time - e.g. 2001-03-24 06:00:00 becomes 2001-03-24)
	Where-Object {($_.CreationTime).Date -ge $StartDate `
			-and ($_.CreationTime).Date -le $EndDate} |
	# For each file found...
	ForEach-Object {
		# Create a destination folder ($Destination\date - $description\file extension
		$Folder = Join-Path -Path $Destination -ChildPath (($_.CreationTime).ToString("yyyy-MM-dd") + $description)
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

Write-Host Finished
Read-Host -Prompt "Press Enter to exit"