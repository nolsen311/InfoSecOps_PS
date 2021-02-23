function Get-Computer { 
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [string]$ComputerName
    )
    Get-ADComputer $ComputerName -Properties * | 
    select -Property CanonicalName,`
                     description,`
                     DNSHostname,`
                     IPV4Address,`
                     LastBadPasswordAttempt,`
                     LastLogonDate,`
                     enabled,`
                     passwordexpired,`
                     passwordlastset,`
                     lockedout,`
                     LogonCount,`
                     OperatingSystem,`
                     OperatingSystemVersion,`
                     SID, `
                     ms-Mcs-AdmPwd | 
    ForEach-Object { [PSCustomObject] @{ "Owner"                     = $_.description;
                                  "DNS Hostname"              = $_.DNSHostName;
                                  "IP Address"                = [IPAddress]$_.IPV4Address;
                                  "Operating System"          = $_.OperatingSystem;
                                  "Version"                   = $_.OperatingSystemVersion;
                                  Enabled                     = $_.Enabled;
                                  "Locked Out"                = $_.LockedOut;
                                  "Password Expired"          = $_.PasswordExpired;
                                  "Last Bad PW Attempt"       = $(if ([string]::IsNullOrWhiteSpace($_.LastBadPasswordAttempt)) {[string]$null} else {[datetime]$_.LastBadPasswordAttempt});
                                  "Last Logon"                = $(if ([string]::IsNullOrWhiteSpace($_.LastLogonDate)){[string]$null} else {[datetime]$_.LastLogonDate});
                                  "Password Last Set"         = $(if ([string]::IsNullOrWhiteSpace($_.PasswordLastSet)) {[string]$null} else {[datetime]$_.PasswordLastSet});
                                  "Canonical Name"            = $_.CanonicalName;
                                  "Security Identifier (SID)" = $_.SID;
                                  "LAPS Password"             = $_."ms-Mcs-AdmPwd";
                                  }
            } 
}