## Parameters for $daysOldest, $daysNewest (counting back from now) and the $description name
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)][int]$daysOldest,
	[Parameter(Mandatory=$True)][int]$daysNewest,
	[Parameter(Mandatory=$True)][string]$description
)

## Locations; $Source = Source directory, $Destination = Parent destination directory
$Source = Resolve-Path("E:\DCIM\100CANON")
$Destination = Resolve-Path("D:\User\Pictures")

## Dates to copmpare
$Today = (Get-Date).Date
$StartDate = $Today.AddDays(-$daysOldest)
$EndDate = $Today.AddDays(-$daysNewest)

Write-Host Copying files between ($StartDate).ToString("yyyy-MM-dd") and ($EndDate).ToString("yyyy-MM-dd")# from $Source to $Destination

# Find all '-include'ed .cr2, .jpeg, .jpg, .mov and .mp4 files in $Source, created within the date range specified
# Add -recursive to Get-ChildItem in the below line (before the | ) to search subdirectories
Get-ChildItem $Source\* -Include *.cr2, *.jpg, *.jpeg, *.mov, *.mp4, *.avi |
	# Compare the creation dates only (remove time - e.g. 2001-03-24 06:00:00 becomes 2001-03-24)
	Where-Object {($_.CreationTime).Date -ge $StartDate `
			-and ($_.CreationTime).Date -le $EndDate} |
	# For each file found...
	ForEach-Object {
		# Create a destination folder ($Destination\date - $description\file extension
		$Folder = Join-Path -Path $Destination -ChildPath (($_.CreationTime).ToString("yyyy-MM-dd") + " - " + $description)
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