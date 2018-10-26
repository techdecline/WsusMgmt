# Implement your module commands in this script.<#

function Sync-WsusApprovedUpdates {
    param (
        [String]$OldWsusServerName
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
            Approve-WsusUpdate -Update $update -Action Install -TargetGroupName "Alle Computer"
        }
    }
}

function Sync-WsusCategories {
    param (
        [String]$OldWsusServerName
    )

    $oldWsusServer = Get-WsusServer -Name $OldWsusServerName -PortNumber 8530
    $oldSubscription = $oldWsusServer.GetSubscription()
    $oldProducts = $oldSubscription.GetUpdateCategories()
    $NewWsusServer = Get-WsusServer
    $validProducts = $oldProducts | Where-Object {(Get-WsusProduct).Product.Title -contains $_.Title}
    $updateCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateCategoryCollection
    $updateCollection.AddRange($validProducts)
    $newSubscription = $newWsusServer.GetSubscription()
    $newSubscription.SetUpdateCategories($updateCollection)
    $newSubscription.Save()
}

function Sync-WsusClassifications {
    param (
        [String]$OldWsusServerName
    )

    $oldWsusServer = Get-WsusServer -Name $OldWsusServerName -PortNumber 8530
    $oldSubscription = $oldWsusServer.GetSubscription()
    $oldProducts = $oldSubscription.GetUpdateClassifications()
    $NewWsusServer = Get-WsusServer
    #$validProducts = $oldProducts | Where-Object {(Get-WsusProduct).Product.Title -contains $_.Title}
    #$updateCollection = New-Object -TypeName Microsoft.UpdateServices.Administration.UpdateClassificationCollection
    #$updateCollection.AddRange($validProducts)
    $newSubscription = $newWsusServer.GetSubscription()
    $newSubscription.SetUpdateClassifications($oldProducts)
    $newSubscription.Save()
}

function Sync-WsusDeclinedUpdates {
    param (
        [String]$OldWsusServerName
    )

    $oldWsusServer = Get-WsusServer -Name $OldWsusServerName -PortNumber 8530

    Get-WsusUpdate -UpdateServer $OldWsusServer -Approval Declined | ForEach-Object {
        try {
            $update = Get-WsusUpdate -UpdateId $_.UpdateId -ErrorAction SilentlyContinue
            $update.update.Decline()
            Write-Host "Declined update: $($update.UpdateId)"
        }
        catch [Microsoft.UpdateServices.Administration.WsusObjectNotFoundException] {
            # placeholder
        }
    }
}
function Sync-WsusTargetGroup {
    param (
        [String]$OldWsusServerName
    )

    $oldWsusServer = Get-WsusServer -Name $OldWsusServerName -PortNumber 8530
    $wsusServer = Get-WsusServer
    $oldTargetGroupArr = $oldWsusServer.GetComputerTargetGroups() | Where-Object {$_.Name -ne "Nicht zugewiesene Computer"}

    foreach ($targetGroup in $oldTargetGroupArr) {
        $wsusServer.CreateComputerTargetGroup($targetGroup.Name)
        $targetGroup.Name
    }
}

function Get-WsusUpdateEulaApprovalRequirement {
    param (
        [Microsoft.UpdateServices.Commands.WsusUpdate]$WsusUpdate
    )

    $needsApproval = $WsusUpdate.Update.RequiresLicenseAgreementAcceptance
    return $needsApproval
}

function Approve-WsusUpdateLicense {
    param (
        [Microsoft.UpdateServices.Commands.WsusUpdate]$WsusUpdate
    )

    $approvalResult = $WsusUpdate.Update.AcceptLicenseAgreement()
}

. .\function-Set-WsusTargetingMode.ps1
. .\function-Start-WsusInitialization.ps1

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Start-WsusInitialization,Sync-WsusApprovedUpdates,Sync-WsusCategories,Sync-WsusDeclinedUpdates,Sync-WsusTargetGroup,Sync-WsusClassifications, Set-WsusTargetingMode
