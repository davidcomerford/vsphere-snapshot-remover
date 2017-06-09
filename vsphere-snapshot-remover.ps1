#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#Add VMware PowerCLI Snap-Ins
Add-PSSnapin VMware.VimAutomation.Core


#----------------------------------------------------------[Declarations]----------------------------------------------------------
$retentiondays = 14
$vcenter = ""
$vcenteruser = "snapshot-cleaner@vsphere.local"
$vcenterpasswd = ""

#-----------------------------------------------------------[Execution]------------------------------------------------------------
Connect-VIServer -Server $vcenter -User $vcenteruser -Password $vcenterpasswd

$snaps = Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-$retentiondays)}

write-host -ForegroundColor Yellow "Found" $snaps.Count "snaphot(s)"

ForEach ($s in $snaps) {

    Write-Host "Removing snapshot on:" $s.VM.Name
    Remove-Snapshot $s -Confirm:$false
    Start-Sleep -s 10
}

Disconnect-VIServer -Server $vcenter -Confirm:$false