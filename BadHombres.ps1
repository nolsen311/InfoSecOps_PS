#requires -PSEdition Core
Function Get-Infrashared { return "https://infrashared.wsecu.net/" }
Function Get-BadHombres { 
    Invoke-WebRequest -Uri "$(Get-Infrashared)AdHoc.csv" | 
    ConvertFrom-Csv -Header @("ip","netmask","type","category") |
    ForEach-Object { 
        if (-not $_.netmask) { [PSCustomObject] @{ "Bad Hombres" = $_.ip }}
        else { [PSCustomObject] @{ "Bad Hombres" = $_.ip + "/" + $_.netmask }} 
    }
}
Function Test-BadHombres {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [IPAddress]
        $IP
    )
    if ($(Get-BadHombres).ip -contains $IP) { Write-Host "BLOCKED" -ForegroundColor Red }
    else { Write-Host "NOT BLOCKED" -ForegroundColor Green }
}
Function Get-GoodGuys { 
    Invoke-WebRequest -Uri "$(Get-Infrashared)GoodGuys.csv" | 
    ConvertFrom-Csv -Header @("ip","netmask","type","category") |
    ForEach-Object { [PSCustomObject] @{ "Allow List" = $_.ip + "/" + $_.netmask }}
}
Function Get-UserIdNotFound { 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]
        $Count=$false
    )
    $output = `
    Invoke-WebRequest -Uri "$(Get-Infrashared)UserIdNotFound.csv" | 
    ConvertFrom-Csv -Header @("ip","netmask") 

    if ($Count) {
        return $output.count
    } else { return $output | ForEach-Object {
        if ($_.netmask -eq "") {$_.netmask = 32}
        [PSCustomObject] @{ "sourceIP" = "$($_.ip)/$($_.netmask)" }
    }}

}
Function Get-UserIdRegMim { 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]
        $Count=$false
    )
    $output = `
    Invoke-WebRequest -Uri "$(Get-Infrashared)UserIdRegMim.csv" | 
    ConvertFrom-Csv -Header @("ip","netmask") 

    if ($Count) {
        return $output.count
    } else { return $output | ForEach-Object {
        if ($_.netmask -eq "") {$_.netmask = 32}
        [PSCustomObject] @{ "sourceIP" = "$($_.ip)/$($_.netmask)" }
    }}

}