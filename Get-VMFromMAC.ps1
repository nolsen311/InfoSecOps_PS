function Get-VMFromMAC {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $MACAddress
    )
    Import-Module VMware.VimAutomation.Core

    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore
    
    Connect-VIServer -Server oly-vcenter-01 -Protocol https -Credential (Get-Credential) -AllLinked

    $output = `
    Get-VM | 
    Get-NetworkAdapter |
    Where-Object { $_.MacAddress -eq $MACAddress } |
    Select-Object Parent,Name,MacAddress

    Disconnect-VIServer -Force
    return $output
}