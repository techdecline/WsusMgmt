$moduleName = "WsusMgmt"
Remove-Module $moduleName -Force -ErrorAction SilentlyContinue

Import-Module "$PSScriptRoot\..\$moduleName.psd1"

Describe "Sync-WsusApprovedUpdates Tests" {

}