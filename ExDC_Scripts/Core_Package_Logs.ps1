[array]$FileList = $null
write-host "Starting to package the log files" -ForegroundColor Green
$Now = Get-Date
$Append = [string]$Now.month + "_" + [string]$now.Day + "_" + `
    [string]$now.year + "_" + [string]$now.hour + "_" + [string]$now.minute `
    + "_" + [string]$now.second

$ExDCLogsFile = ".\ExDC_Events_" + $append + ".txt"
#$ExDCLogs = Get-WinEvent -ProviderName ExDC |fl
Write-Host "Getting the last 24 hours of ExDC events from the application log" -ForegroundColor Green
$ExDCLogs = Get-EventLog -LogName application -Source exdc -After $Now.AddDays(-1) | Format-List -Property TimeGenerated,EntryType,Source,EventID,Message
$ExDCLogs | Out-File -FilePath $ExDCLogsFile -Force

write-host "Gathering..." -ForegroundColor Green
$FilesInCurrentFolder = Get-ChildItem
foreach ($a in $FilesInCurrentFolder)
{
	#If (($a.name -like ($ExDCLogsFile.replace('.\',''))) -or `
	If (($a.name -like "ExDC_Events*") -or `
		($a.name -like "ExDC_Step3*") -or `
		($a.name -like "Failed*"))
		{
			write-host $a.fullname
			$FileList += [string]$a.fullname
		}
}
$ZipFilename = (get-location).path + "\ExDCPackagedLogs_" + $append + ".zip"
if (-not (Test-Path -LiteralPath $ZipFilename))
{Set-Content -Path $ZipFilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))}
$ZipFile = (New-Object -ComObject shell.application).NameSpace($ZipFilename)
write-host "Packaging..." -ForegroundColor Green
ForEach ($File in $FileList)
{
	write-host "Zipping $File"
	$zipfile.CopyHere($File)
}
write-host "Finished collecting logs." -ForegroundColor Green
write-host "Output log is $ExDCLogsFile" -ForegroundColor Green