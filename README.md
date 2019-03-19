# WsusMgmt
PowerShell Module to automate and accelerate WSUS deployments and migrations.

# How to install WSUS using WsusMgmt
1. Install required Windows Features
`Install-WindowsFeature UpdateServices-Services,UpdateServices-WID -IncludeManagementTools`
2. Run Post-Installation
`Start-Process -FilePath 'C:\Program Files\Update Services\Tools\wsusutil.exe' -ArgumentList 'postinstall CONTENT_DIR=C:\WSUS'`
3. Browse to Module Directory
4. Import Module
`Import-Module .\WsusMgmt.psd1`
5. Start First Sync (proxy and asjob are optional parameters)
`Start-WsusInitialization`
6. Configured desired products and classifications
7. Sync WSUS against Microsoft Update
8. (Optional) Sync approved and declined updates against existing WSUS server
`Sync-WsusApprovedUpdates -OldWsusServerName wsus.contoso.com`