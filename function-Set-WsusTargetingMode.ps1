<#
    .SYNOPSIS
        Configures WSUS Server Targeting Mode.
    .DESCRIPTION
        Configures WSUS Server Targeting Mode locally. This must be either "Client" or "Server"
    .EXAMPLE
        PS> Set-WsusTargetingMode -TargetingMode Client

        Configures the local WSUS to use Client Targeting
    .EXAMPLE
        PS> Set-WsusTargetingMode -TargetingMode Server

        Configures the local WSUS to use Server Targeting
#>
function Set-WsusTargetingMode {
    [CmdletBinding()]
    param (
        # Configure desired Targeting Mode
        [Parameter(Mandatory)]
        [ValidateSet("Client","Server")]
        [String]
        $TargetingMode
    )

    process {
        Write-Verbose "Connecting WSUS Server"
        $wsusServer = Get-WsusServer
        Write-Verbose "Loading WSUS Configuration"
        $wsusCfg = $wsusServer.GetConfiguration()

        if ($wsusCfg.TargetingMode -eq $TargetingMode) {
            Write-Verbose "Targeting Mode already configured correctly ($TargetingMode)"
            return $true
        }
        else {
            Write-Verbose "Changing Targeting Mode to: $TargetingMode"
            $wsusCfg.TargetingMode = $TargetingMode
            Write-Verbose "Saving WSUS Configuration"
            $wsusCfg.Save()
            return $true
        }
    }
}