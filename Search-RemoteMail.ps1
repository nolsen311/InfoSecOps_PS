Function Start-RemoteMailSearch {
    $onprem_exchange_mailbox_server = "%%INSERT SERVER NAME HERE%%"

    $global:exch_stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    $script:exchangeURI = "http://$onprem_exchange_mailbox_server/PowerShell/"
    $script:MyCredentials = (Get-Credential -Message "Exchange Mailbox Server")
    
    $Exch_Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $exchangeURI -Authentication Kerberos -Credential $MyCredentials
    Import-PSSession $Exch_Session -DisableNameChecking -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -AllowClobber | Out-Null

    Remove-Variable MyCredentials -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    Remove-Variable exchangeURI -ErrorAction SilentlyContinue -WarningAction SilentlyContinue  
    
    Write-Host -ForegroundColor Yellow "Don't forget to check for distribution lists"      
}

Function End-RemoteMailSearch {
    
    if (Get-Variable Exch_Session -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) { Remove-PSSession $Exch_Session }

    $exch_stopwatch.Stop()
    
    Write-Host "SEARCH COMPLETE!" -ForegroundColor Green
    Write-Host "Total Time :: $($exch_stopwatch.Elapsed.Minutes) Minutes, $($exch_stopwatch.Elapsed.Seconds) Seconds" -ForegroundColor Yellow
    
    Remove-Variable exch_stopwatch -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
Function Get-EmailRecipients {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $path="$Env:USERPROFILE\Desktop\"
    )
    Get-ChildItem -Path $path -Filter "message*csv" |
    ForEach-Object { $emails += Get-Content (join-path $path $_) | ConvertFrom-Csv }
    $recipients = $emails.Recipient | Select-Object -Unique
    return $recipients
}
