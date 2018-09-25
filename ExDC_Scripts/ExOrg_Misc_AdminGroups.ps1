 ############################################################################
#                     ExOrg_Misc_AdminGroups.ps1							#
#                                     			 							#
#                               4.0.2    		 							#
#                                     			 							#
#   This Sample Code is provided for the purpose of illustration only       #
#   and is not intended to be used in a production environment.  THIS       #
#   SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT    #
#   WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT    #
#   LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS     #
#   FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free    #
#   right to use and modify the Sample Code and to reproduce and distribute #
#   the object code form of the Sample Code, provided that You agree:       #
#   (i) to not use Our name, logo, or trademarks to market Your software    #
#   product in which the Sample Code is embedded; (ii) to include a valid   #
#   copyright notice on Your software product in which the Sample Code is   #
#   embedded; and (iii) to indemnify, hold harmless, and defend Us and      #
#   Our suppliers from and against any claims or lawsuits, including        #
#   attorneys' fees, that arise or result from the use or distribution      #
#   of the Sample Code.                                                     #
#                                     			 							#
#############################################################################
Param($location,$server,$i,$PSSession)

Write-Output -InputObject $PID
Write-Output -InputObject "ExOrg"

$ErrorActionPreference = "Stop"
Trap {
$ErrorText = "ExOrg_Misc_AdminGroups " + "`n" + $server + "`n"
$ErrorText += $_

$ErrorLog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList Application
$ErrorLog.MachineName = "."
$ErrorLog.Source = "ExDC"
$ErrorLog.WriteEntry($ErrorText,"Error", 100)
}

set-location -LiteralPath $location
$output_location = $location + "\output\ExOrg"

if ((Test-Path -LiteralPath $output_location) -eq $false)
    {New-Item -Path $output_location -ItemType directory -Force}

if ($PSSession -ne $null)
{
	$cxnUri = "http://" + $PSSession + "/powershell"
	$session = New-PSSession -configurationName Microsoft.Exchange -ConnectionUri $cxnUri -authentication Kerberos
	Import-PSSession -Session $session -AllowClobber -CommandName get-group,set-adserversettings
    Set-AdServerSettings -ViewEntireForest $true
}
else
{
	Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.Admin
    ([Microsoft.Exchange.Data.Directory.AdminSessionADSettings]::Instance).ViewEntireForest = $true
}

$ExOrg_Misc_AdminGroups_outputfile = $output_location + "\ExOrg_Misc_AdminGroups.txt"

$DefaultAdminGroups = @(`
	"Account Control Assistance Operators",`
	"Account Operators",`
	"Administrators",`
	"Backup Operators",`
	"Cert Publishers",`
	"Cryptographic Operators",`
	"DHCP Administrators",`
	"DNSAdmins",`
	"Domain Admins",`
	"Domain Controllers",`
	"Enterprise Admins",`
	"Enterprise Read-only Domain Controllers",`
	"Group Policy Creator Owners",`
	"Hyper-V Administrators",`
	"Network Configuration Operators",`
	"Print Operators",`
	"RAS and IAS Servers",`
	"Read-only Domain Controllers",`
	"Schema Admins",`
	"Server Operators",`
	"WSUS Administrators",`
	"WSUS Reporters"`
	)
$Exchange2013SecurityGroups = @(`
	"Compliance Management",`
	"Managed Availability Servers"`
	)
$Exchange2010SecurityGroups = @(`
	"Delegated Setup",`
	"Discovery Management",`
	"Exchange All Hosted Organizations",`
	"Exchange Install Domain Servers",`
	"Exchange Mailbox Import-Export",`
	"Exchange Servers",`
	"Exchange Trusted Subsystem",`
	"Exchange Windows Permissions",`
	"ExchangeLegacyInterop",`
	"Help Desk",`
	"Hygeine Management",`
	"Organization Management",`
	"Public Folder Management",`
	"Recipient Management",`
	"Records Management",`
	"Server Management",`
	"UM Management",`
	"View-Only Organization Management"`
	)
$Exchange2007SecurityGroups = @(`
	"Exchange Organization Administrators",`
	"Exchange Recipient Administrators",`
	"Exchange View-Only Administrators",`
	"ExchangeLegacyInterop"`
	)
$Exchange2003SecurityGroups = @(`
	"Exchange Domain Servers",`
	"Exchange Enterprise Servers"`
	)
$OtherSecurityGroups  = @()

$Groups = $DefaultAdminGroups + `
	$Exchange2013SecurityGroups + `
	$Exchange2010SecurityGroups + `
	$Exchange2007SecurityGroups + `
	$Exchange2003SecurityGroups + `
	$OtherSecurityGroups

$Groups = $Groups | Sort-Object -Unique

$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
Foreach ($domain in $forest.domains)
{
	$domain_name = $domain.Name
	foreach ($group in $Groups)
	{
		$GroupName = $domain_Name + "\" + $group
		try
		{
			$Get_Group = Get-Group $GroupName
			$Get_Group_Count = $Get_Group.Members.count
			foreach ($member in $Get_group.members)
			{
				$GroupName + "`t" + $Get_Group_Count + "`t" + $member.tostring() | Out-File -FilePath $ExOrg_Misc_AdminGroups_outputfile -append 
			}
		}
		Catch{}
	}
}


$a = Get-Process -pid $PID

$EventText = "ExOrg_Misc_AdminGroups " + "`n" + $server + "`n"
$vmMB = [int](($a.vm)/1048576)
$wsMB = [int](($a.ws)/1048576)
$pmMB = [int](($a.privatememorysize)/1048576)
$RunTimeInSec = [int](((get-date) - $a.starttime).totalseconds)
$EventText += "VirtualMemorySize `t" + $vmMB + " MB `n"
$EventText += "WorkingSet      `t`t" + $wsMB + " MB `n"
$EventText += "PrivateMemorySize `t" + $pmMB + " MB `n"
$EventText += "Process run time`t`t" + $RunTimeInSec + " sec `n" 

$EventLog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList Application
$EventLog.MachineName = "."
$EventLog.Source = "ExDC"
$EventLog.WriteEntry($EventText,"Information", 35)

if ($PSSession -ne $null)
{
	Remove-PSSession -Session $session
}
