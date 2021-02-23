function Get-UserAgent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $UserAgent
    )
    $UserAgent = [System.Web.HttpUtility]::UrlEncode($UserAgent)

    # $user_agents = $csv_content.UserAgent
    # $user_agents |
    $output = `
    @( $response = Invoke-RestMethod -Uri "http://api.userstack.com/detect?access_key=ca06cf167c405d4be9c5fd0f07d9c8de&ua=$UserAgent" `
            -Method POST
            [PSCustomObject] @{
                Browser = [string] $response.Browser.name
                UserAgent = [string] $_.UserAgent
                Count = [int] $_.Count
            }        
    )
    $output

    Write-Host "use `$response for full data object" -ForegroundColor Green
}

function Get-UserAgentsFromFile {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $File="$Env:USERPROFILE\Downloads\TEMP_PAN\20201208*.csv"
    )
    $csv_content = `
    Get-Content $File |
    Select-Object -Skip 1 |
    ConvertFrom-Csv -Header @("UserAgent","Count")

    # $user_agents = $csv_content.UserAgent
    # $user_agents |
    $output = `
    @( $csv_content |
        ForEach-Object {
            $response = Invoke-RestMethod -Uri "http://api.userstack.com/detect?access_key=ca06cf167c405d4be9c5fd0f07d9c8de&ua=$($_.UserAgent)" `
            -Method POST
            [PSCustomObject] @{
                Browser = [string] $response.Browser.name
                UserAgent = [string] $_.UserAgent
                Count = [int] $_.Count
            }        
        })
    $output = $output | 
                Where-Object { $_.Browser -ne "" } | 
                Group-Object -Property Browser |
                ForEach-Object {
                    [PSCustomObject] @{
                        Browser = [string] $_.Name
                        Count = [int] ($_.Group | Measure-Object -Property Count -Sum).Sum
                    }
                } |
                Sort-Object -Property Count -Descending
    $output | ConvertTo-Csv | Out-File -FilePath $Env:UserProfile\Desktop\20201208_UserAgent_Parsed.csv

}