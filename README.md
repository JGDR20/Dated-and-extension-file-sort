# Dated-and-extension-file-sort
Copy files from one location to another, picking only the ones that were created within a specified date range and matching particular filetypes/extensions
Matching files are copied to dated folders with a custom description and further split by file extensions into subfolders. The steps it takes are listed below:

Dated_and_extension_file_sort.ps1

1.	Ask for $daysOldest, the farthest (in whole days) you want to go back in time e.g. 5
2.	Ask for $daysNewest, the closest (in whole days) you want to go back in time e.g. 2
3.	Ask for $description, the custom description to tack onto the end of the dated folders
	e.g. 'A Summer's Day' would give 2001-03-24 - A Summer's Day as the dated folder
4.	Check that each file in the $Source directory has an allowed file extension
	(you can get rid of this if you want to sort all files by removing the -Include section)
	and was created within the date range specified
5.	Work out the new folder structures and create them if they don't exist
6.	Check if the files has already been added to the destination
7.	Copy the files

# NOTE: Add source and destination paths into the accompanying .\config.xml file!