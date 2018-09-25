#############################################################################
#                          DC_W32_CS.ps1		 							#
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
Write-Output -InputObject "WMI"

$ErrorActionPreference = "Stop"
Trap {
$ErrorText = "DC_W32_CS " + "`n" + $server + "`n"
$ErrorText += $_

$ErrorLog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList Application
$ErrorLog.MachineName = "."
$ErrorLog.Source = "ExDC"
$ErrorLog.WriteEntry($EventText,"Error", 1)
}

set-location -LiteralPath $location
$output_location = $location + "\output\DC_W32_CS"

if ((Test-Path -LiteralPath $output_location) -eq $false)
    {New-Item -Path $output_location -ItemType directory -Force}

$DC_W32_CS_outputfile = $output_location + "\" +$server + "~~DC_W32_CS.txt"

Get-WmiObject -ComputerName $server -ErrorAction SilentlyContinue `
    -Query ('select * from win32_computersystem') | ForEach-Object `
{
    $output_DC_W32_CS = $server + "`t" + `
    	$_.manufacturer + "`t" + `
    	$_.Model + "`t" + `
    	$_.NumberOfLogicalProcessors + "`t" + `
        $_.NumberOfProcessors + "`t" + `
    	$_.TotalPhysicalMemory + "`t" + `
		$_.AutomaticManagedPagefile
    $output_DC_W32_CS | Out-File -FilePath $DC_W32_CS_outputfile -append 
}

$a = Get-Process -pid $PID

$EventText = "DC_W32_CS " + "`n" + $server + "`n"
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

