<#	
	.NOTES
	===========================================================================
	 Created on:   	30.12.2018 16:41
	 Created by:   	Anton
	 Filename:     	New-WebProject.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

param (
	[parameter(Mandatory = $true)]
	[string]$Path,
	
	[parameter(Mandatory = $true)]
	[string]$Name
)

$System = [Environment]::GetFolderPath("System") # C:\Windows\system32
$script:hostsPath = ([System.IO.Path]::Combine($System, "drivers\etc\"))+"hosts" # C:\Windows\system32\drivers\etc\hosts
