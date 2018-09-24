#############################################################################
#                     Cluster_MSCluster_Network.ps1		 					#
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
Param($server,$location,$append)

Write-Output -InputObject $PID
Write-Output -InputObject "Cluster"

$ErrorActionPreference = "Stop"
Trap {
$ErrorText = "Cluster_MSCluster_Network " + "`n" + $server + "`n"
$ErrorText += $_

$ErrorLog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList Application
$ErrorLog.MachineName = "."
$ErrorLog.Source = "ExDC"
$ErrorLog.WriteEntry($ErrorText,"Error", 100)
}

set-location -LiteralPath $location
$output_location = $location + "\output\Cluster_MSCluster_Network"

if ((Test-Path -LiteralPath $output_location) -eq $false)
    {New-Item -Path $output_location -ItemType directory -Force}

$Cluster_MSCluster_Network_outputfile = $output_location + "\" +$server + "~~Cluster_MSCluster_Network.txt"

ForEach ($Cluster in (Get-WmiObject -Namespace "root\MSCluster" -ComputerName $server -Impersonation impersonate -Authentication PacketPrivacy `
	-Query ('select name from MSCluster_Cluster')))
{
	Get-WmiObject -Namespace "root\MSCluster" -comp $server -Impersonation impersonate -authentication PacketPrivacy `
	    -query ('select name,role,state,status from MSCluster_Network') | ForEach-Object `
	{
		$output_Cluster_MSCluster_Network = $Cluster.name + "`t" + `
			$_.name + "`t" + `
			$_.role + "`t" + `
			$_.state + "`t" + `
			$_.status 
		$output_Cluster_MSCluster_Network | Out-File -FilePath $Cluster_MSCluster_Network_outputfile -Append 			
	}
}
	# Role		0 = Not used
	#		  	1 = Heartbeat
	#			2 = Client
	#			3 = Mixed
	# State		-1 = State Unknown
	#			0 = State Unavailable
	#			1 = Down
	#			2 = Partitioned
	#			3 = Up

$a = Get-Process -pid $PID

$EventText = "Cluster_MSCluster_Network " + "`n" + $server + "`n"
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

