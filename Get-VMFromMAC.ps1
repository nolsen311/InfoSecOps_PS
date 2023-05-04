function Get-VMFromMAC {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $MACAddress,
        [Parameter(Mandatory=$true)]
        [string]
        $VCenterServer
    )
    Import-Module VMware.VimAutomation.Core

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
    
    Connect-VIServer -Server $VCenterServer -Protocol https -Credential (Get-Credential) -AllLinked

    $output = `
    Get-VM | 
    Get-NetworkAdapter |
    Where-Object { $_.MacAddress -eq $MACAddress } |
    Select-Object Parent,Name,MacAddress

    Disconnect-VIServer -Force
    return $output
}
