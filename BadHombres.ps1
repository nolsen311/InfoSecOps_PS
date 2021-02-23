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
function Verify-Splunk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("UserIdNotFound","BadHombres")]
        [string]
        $blockList,
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-Not ($_ | Test-Path)) { throw "File does not exist" }
            if (-Not ($_ | Test-Path -PathType Leaf)) { throw "Parameter splunkList must be a file" }
            # if (-Not ($_ -notmatch "(\.csv)")) { throw "the file specified in splunkList must be a Comma-Separated Value"}
            return $true
        })]
        [System.IO.FileInfo]
        $splunkList
    )
    switch ($blockList)
    {
        "UserIdNotFound" {
            $F5_block_list = (Get-UserIdRegMim | Select-Object -ExpandProperty "Splunk Violators").Trim("/");
            break; }
        "BadHombres" {
            $F5_block_list = (Get-BadHombres | Select-Object -ExpandProperty "Bad Hombres").Trim("/");
            break; }
    }
    $splunk_List = Get-Content $splunkList | ConvertFrom-Csv | Select-Object -ExpandProperty "sourceIP"
    $list_comparison = Compare-Object -ReferenceObject $F5_block_list `
                                      -DifferenceObject $splunk_List `
                                      -IncludeEqual
    $in_both_lists = $list_comparison | Where-Object { $_.SideIndicator -eq '==' }
    $only_in_Splunk = $list_comparison | Where-Object { $_.SideIndicator -eq '=>' }

    if (-NOT $only_in_Splunk) { Write-Host "All IPs already in F5 Blocking list: $blockList" -ForegroundColor Green }
    else { Write-Host "$($only_in_splunk.count) IPs are not added to F5 Blocking list: $blockList" -ForegroundColor Yellow; return $only_in_Splunk | Select-Object -ExpandProperty "InputObject" }
    
}
Function Remove-BadHombres {
    $jenkins_root = "\\oly-jenkins-01\D$"
    $adhoc_file = "JENKINS:\Jenkins_Jobs\AdHoc.csv"
    $anchor_ip = "222.186.56.121"
    New-PSDrive -Name JENKINS -PSProvider FileSystem -Root $jenkins_root -Credential (Get-Credential)
    Remove-Item -Path $adhoc_file -Force
    Remove-PSDrive -Name JENKINS -PSProvider FileSystem -Force


}
Function Push-BadHombres {
    $my_cred = (Get-Credential -Message "Authenticate to Jenkins\Infrashared servers")
    $adhoc_file = "\\oly-jenkins-01\D`$\Jenkins_Jobs\AdHoc.csv"
    $servers = @("oly-intweb-01","spo-intweb-01")
    $servers |
    ForEach-Object {
        $destination = "\\$server\d$\inetpub\wwwroot\InfraShared-011"
        Write-Verbose "Copying $adhoc_file to $server with updated IP list"
        Copy-Item -Path $adhoc_file -Destination $destination -Credential $my_cred #-ErrorAction SilentlyContinue           
    }
    Remove-Variable $my_cred
}