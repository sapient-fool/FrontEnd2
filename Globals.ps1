#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------
### Customize domain to match your org
$global:Domain = "intra.cascadetech.org"
##### Customize FrontEnd title and logo #####
$title = "OSD FrontEnd"
$iconfile = ".\PowerShell.ico"


#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

function Get-ADCreds
{
<#
	.SYNOPSIS
		Get-ADCreds authenticates user to our Domain.

	.OUTPUTS
		Boolean
	
	.NOTES
		.
#>
	##### Customize authentication message #####
	$creds = get-credential -message "Please authenticate with your CTA account"
	
	$global:UserName = $creds.username
	$global:encPassword = $creds.password
	$global:Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($encpassword))
	
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
	$pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext $ct, $Domain
	$authed = $pc.ValidateCredentials($UserName, $Password)
	
	if ($authed -eq $false)
	{
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
		[System.Windows.Forms.MessageBox]::Show("Authentication failed - please retry!")
		Get-ADCreds
	}
	$global:UserName = $UserName.ToUpper()
}
function Get-MachineInfo
{	
	$global:make = (Get-CimInstance -classname win32_computersystem).manufacturer
	$global:model = (get-ciminstance win32_computersystemproduct).version
	$global:modelnumber = (Get-CimInstance -classname win32_computersystem).model
	$global:serial = (Get-CimInstance -classname win32_bios).serialnumber
#	if ($global:serial -notlike "*vmware*" -and $make -notlike "*Microsoft*")
#	{
#		$global:compname = "WK" + $global:serial
#	}
#	else
#	{
#		$global:compname = "VM" + $username.toupper()
#	}
	$global:macaddress = (get-ciminstance win32_networkadapter -property Name, MacAddress, AdapterType | where adaptertype -eq "Ethernet 802.3").MACAddress
	$global:nic = (get-ciminstance win32_networkadapter -property Name, MacAddress, AdapterType | where adaptertype -eq "Ethernet 802.3").name
	$global:ipaddress = (get-ciminstance win32_networkadapterconfiguration -property ipaddress | where ipaddress -ne $null).ipaddress[0]
	$global:uuid = (Get-WmiObject uuid -Namespace root\cimv2 -class win32_computersystemproduct).uuid
	$global:slic = (Get-CimInstance win32_baseboard).version
	
}