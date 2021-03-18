#=========================================================================================
# updateMMARegEntriesSafe:
#    - removes law regentries that are specified in $lawsToRemove
#    - adds law regentries that are specified in $lawsToAdd
#
# Note: regentries that exist but not specifically mentionned in $lawsToRemove will not be
#       removed.
#       To only keep or add what is specified in list, use the updateMMARegEntries
#=========================================================================================
$lawsToAdd = @(
    @{
        # Management/securityoperations-monitoring-management-law
        "id" = "f79d0c5a-73a2-4cf3-9a56-8d2cbe3449d0"
        "key" = "R34sd7VsS2buAaPhLZotG9RQ9p3xJX41LZemHlvlED75sMp74wLAkPT7YGwkxTFx+5IlyyCH56JwmxolaRQZ3w=="
    },
    # @{
    #     # dev/cloudmonitoring-dev-law
    #     "id" = "e2a3a59b-1946-4173-b6d0-d8cd64304ce7"
    #     "key" = "pRjPVYnzfU0T0lUGuNN54+mqC3GSVfA9hS8Cp69mZ2Jzjphkj7iZLxI4CyYcLTGpHV8nG7GNCg7ipug4QCKY+Q=="
    # },
    # @{
    #     # dev/vm-logs-law
    #     "id" = "caa69981-0b78-48ef-bdc6-d9294a0702cf"
    #     "key" = "PrIVLP0HSC6krGs0iM8hqb/yGoJvmewafWUY05m3yRMbwmiWyfHlhEG5oQ+/16P17fBphMWH95rB3upf2Nfzjg=="
    # },
    # @{
    #     # dev/ds-metrics-sa-law
    #     "id" = "f9fd8fad-317b-4ec0-97fb-f9bae23b769e"
    #     "key" = "gbJvEAoOQ4xgxOxQ9grx3TpymtXAcs4bMFIvg4FCa7PkWfARMwsQhQA5YxeMrCCPWgDKbdRKDjRwHY1cIUUd6Q=="
    #  },
    @{
        # Production/StatcanProd
        "id" = "d884a269-b5ab-40db-a1b2-ca922ee9f1cb"
        "key" = "eOSFce8QzlC4MklOyeBi9xjeiY7YP6DklwHG07Zabw7ukyknrjddHxOfMI540UIOK8lZBd3ut18WCBS7/1s1cw=="
    }
);
 
$lawsToRemove = @(
 
    # @{
    #     # Production/StatcanProd
    #     "id" = "d884a269-b5ab-40db-a1b2-ca922ee9f1cb"
    #     "key" = "eOSFce8QzlC4MklOyeBi9xjeiY7YP6DklwHG07Zabw7ukyknrjddHxOfMI540UIOK8lZBd3ut18WCBS7/1s1cw=="
    # },
    @{
        # dev/cloudmonitoring-dev-law
        "id" = "e2a3a59b-1946-4173-b6d0-d8cd64304ce7"
        "key" = "pRjPVYnzfU0T0lUGuNN54+mqC3GSVfA9hS8Cp69mZ2Jzjphkj7iZLxI4CyYcLTGpHV8nG7GNCg7ipug4QCKY+Q=="
    },
    @{
        # dev/vm-logs-law
        "id" = "caa69981-0b78-48ef-bdc6-d9294a0702cf"
        "key" = "PrIVLP0HSC6krGs0iM8hqb/yGoJvmewafWUY05m3yRMbwmiWyfHlhEG5oQ+/16P17fBphMWH95rB3upf2Nfzjg=="
    }
);
 
if (Test-Path "HKLM:\SYSTEM\ControlSet001\Services\HealthService\Parameters\Service Connector Services\")
{
    # remove unwanted entries
    $regentries = Get-ChildItem -Path 'HKLM:\SYSTEM\ControlSet001\Services\HealthService\Parameters\Service Connector Services\'
    foreach($regentry in $regentries)
    {
        $wid =  $regentry.Name.Substring($regentry.Name.Length-36)
        $found =  $lawsToRemove | Where-Object {$_.id -eq $wid}
        #Write-Host "wid = $($wid) ...... $found = $($found)"
        if ($found)
        {
            Write-Host "remove this items: $wid"
            $mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg';
            $mma.RemoveCloudWorkspace($wid);
            $mma.ReloadConfiguration();
        }
    }
 
    foreach($w in $lawsToAdd)
    {
        $WorkspaceId = $w.id
        $WorkspaceKey = $w.key
        $testpath = "HKLM:\SYSTEM\ControlSet001\Services\HealthService\Parameters\Service Connector Services\Log Analytics - $($w.Id)"
        if (-Not (Test-Path -Path $testpath))
        {
            Write-Host "add this item. key: $($WorkspaceId)    ...... id: $($WorkspaceKey)"
            $mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg';
            $mma.AddCloudWorkspace($WorkspaceId, $WorkspaceKey);
            $mma.ReloadConfiguration();
        }
    }
}