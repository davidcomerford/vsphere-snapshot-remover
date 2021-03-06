<#
.SYNOPSIS
  Deletes snapshots over x days old

.NOTES
  Version:        1.0
  Author:         David Comerford 
  Tested on:      vCenter 6.0
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
# Load VMware PowerCLI Module
Load-Module VMware.VimAutomation.Core

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$retentiondays = 14
$maxsimultaneousremovals = 1
$vcenter = ""
$vcenteruser = "snapshot-cleaner@vsphere.local"
$vcenterpasswd = ""

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function getTaskCount {
    $tmptasks = Get-Task -Status "Running" | where {$_.Name -eq "RemoveSnapshot_Task"} | Measure | Select -expand Count
    Return $tmptasks
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
# Connect to vCenter Server
Connect-VIServer -Server $vcenter -User $vcenteruser -Password $vcenterpasswd

# Create the list of abandoned snapshots
$snaps = Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-$retentiondays)} 

# Count the number of snapshots
$snapsCount = $snaps | Measure | Select -expand Count

# Tell the user how many snapshots were found
write-host -ForegroundColor Yellow "Found" $snapsCount "snaphot(s)"

# If there was no snapshots found, then exit
if ($snapsCount -eq 0) { exit }

ForEach ($s in $snaps) {
    # Get a list of running snapshot removals
    $tasksCount = getTaskCount

    while($tasksCount -ge $maxsimultaneousremovals) {
        Write-Host -ForegroundColor Cyan "Max simultaneous removals reached. Waiting..."
        Start-Sleep -s 60
        $tasksCount = getTaskCount
        }

    Write-Host "Removing snapshot on:" $s.VM.Name
    Remove-Snapshot $s -RunAsync -Confirm:$false
    Start-Sleep -s 10
}

# Disconnect
Disconnect-VIServer -Server $vcenter -Confirm:$false