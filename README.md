
# Dated-and-extension-file-sort.ps1
Copy files from one location to another, picking only the ones that were created within a specified date range and matching particular filetypes/extensions
Matching files are copied to dated folders with a custom description and further split by file extensions into subfolders. The steps it takes are listed below:

Dated_and_extension_file_sort.ps1

1.	Default values are set in the `$defaultVals` hashtable in the script
	*	Change the *source* and *destination* values to something appropriate!
2.	Ask for `$daysOldest`, the farthest (in whole days) you want to go back in time e.g. *`5`*
3.	Ask for `$daysNewest`, the closest (in whole days) you want to go back in time e.g. *`2`*
4.	Ask for `$description`, the custom description to tack onto the end of the dated folders
	e.g. *`A Summer's Day`* would give `2001-03-24 - A Summer's Day` as the dated folder
5.	Ask for `$include[]`, an array of allowed file extensions in the form *`include[0]: *.jpg, include[1]: *.txt`* etc.
	*	(you can leave this blank to include all files (*`*`*) by default)
6.	Ask for `$source` and `$destination` directories - you should change these defaults even if you don't change any others
7.	Check that each file in the `$source` directory has an allowed file extension
	*and* was created within the date range specified
8.	Work out the new folder structures and create them if they don't exist
9.	Check if the files has already been added to the destination
10.	Copy the files

### NOTE: Replace the source and destination paths in the `$defaultVals` hashtable!

The final results will look something like:
```powershell
> Dated_and_extension_file_sort.ps1
daysOldest: 3
daysNewest: 1
description: A Summer's Day
source: <e.g. a microSD card from a phone>
destination: <e.g. holiday pics folder>
include[0]: *.jpg
include[1]: *.txt
include[2]: *.mp4
include[3]: 
```
*	.\\2001-03-24 - A Summer's Day\\
	*	JPG\\
		*	image01.jpg
		*	image02.jpg
	*	MP4\\
		*	video01.mp4
	*	TXT\\
		*	TripNotes.txt
		*	PicnicList.txt
*	.\\2001-03-25 - A Summer's Day\\
	*	MP4\\
		*	video02.mp4
	*	TXT\\
		*	InsuranceClaim.txt