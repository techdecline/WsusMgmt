    <#
    .Synopsis
    Start initial WSUS Sync with Microsoft Update after WSUS Installation.
    .DESCRIPTION
    Start initial WSUS Sync with Microsoft Update after WSUS Installation. Optionally, a proxy server can be added.
    .EXAMPLE
    PS> Start-WsusInitialization

    This command will start the initial MU sync without using a proxy server.
    .EXAMPLE
    PS> Start-WsusInitialization -ProxyAddress proxy:8080

    Using this command the initial MU sync will be started using a proxy server called "proxy" and TCP Port 8080.
    .INPUTS
    .NOTES
    Author: Cornelius Schuchardt
    Link: https://github.com/techdecline/WsusMgmt
    #>
    function Start-WsusInitialization {
        [CmdletBinding(DefaultParameterSetName="Default")]
        param (
            # Proxy Server and Port
            [Parameter(Mandatory,ParameterSetName="WithProxy")]
            [ValidatePattern("^.*:.*$")]
            [String]
            $ProxyAddress
        )

        process {
            $wsus = get-wsusserver
            Set-WsusServerSynchronization -SyncFromMU
            $wsusConfig = $wsus.GetConfiguration()
            $wsusConfig.AllUpdateLanguagesEnabled = $false
            $wsusConfig.SetEnabledUpdateLanguages("en")
            if ($ProxyAddress) {
                $proxyServerPort = ($ProxyAddress -split ":")[1]
                $proxyServerName = ($ProxyAddress -split ":")[0]
                $wsusConfig.UseProxy = $true
                $wsusConfig.ProxyName = $proxyServerName
                $wsusConfig.ProxyServerPort = $proxyServerPort
            }

            $wsusConfig.Save()

            # Start Synchronisierung und warten auf Ergebnis
            $subscription = $wsus.GetSubscription()
            $subscription.StartSynchronizationForCategoryOnly()
            $subscription.GetSynchronizationStatus()
            while ($subscription.GetSynchronizationStatus() -eq "Running")  {
                Write-Verbose "Waiting for synchronization to finish"
                Start-Sleep -Seconds 5
            }
        }
    }