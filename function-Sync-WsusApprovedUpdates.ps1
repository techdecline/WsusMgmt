<#
    .SYNOPSIS
        Synchronize all Update Approvals from a WSUS Server.
    .DESCRIPTION
        Synchronize all Update Approvals from a WSUS Server. Currently limited to HTTP-connection on Port 8530
    .EXAMPLE
        PS> Sync-WsusApprovedUpdates -OldWsusServerName srv-wsus1

        Syncs all updates that were approved on srv-wsus1 and publishes to "All Computers"

    .EXAMPLE
        PS> Sync-WsusApprovedUpdates -OldWsusServerName srv-wsus1 -TargetGroupName "Development"

        Syncs all updates that were approved on srv-wsus1 and publishes to "Development"
#>
function Sync-WsusApprovedUpdates {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory,Position=0,ValueFromPipeline)]
        [ValidateScript({test-netconnection $_ -Port 8530})]
        [String]$OldWsusServerName,

        [Parameter(Mandatory=$false)]
        [String]$TargetGroupName = "All Computers"
    )

    $newWsus = Get-WsusServer
    $oldWsus = Get-WsusServer -Name $OldWsusServerName -PortNumber 8530
    $updateArr = Get-WsusUpdate -UpdateServer $newWsus

    foreach ($update in $updateArr) {
        $oldUpdate = Get-WsusUpdate -UpdateServer $oldWsus -UpdateId $update.UpdateId
        if ($oldUpdate.Approved -eq "Install") {
            if (Get-WsusUpdateEulaApprovalRequirement -WsusUpdate $update) {
                Approve-WsusUpdateLicense -WsusUpdate $update
            }
            Approve-WsusUpdate -Update $update -Action Install -TargetGroupName $TargetGroupName
        }
    }
}