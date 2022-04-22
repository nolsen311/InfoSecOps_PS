#requires -Modules ExchangeOnlineManagement
function Get-SharedMailboxUsers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    Get-ActiveEXOSession
    $my_mailbox = Get-EXOMailbox $Name
    Get-MailboxPermission $my_mailbox.Name |
    Where-Object { $_.User -like "*wsecu.org" } |
    Select-Object -ExpandProperty User
}
function Get-ActiveEXOSession {
    $my_sessions = Get-PSSession | Select-Object -Property State,Name
    [switch]$isConnected = (@($my_sessions) -like '@{State=Opened; Name=ExchangeOnlineInternalSession*').Count -gt 0
    if (-not $isConnected) {
        Connect-ExchangeOnline
    }
}