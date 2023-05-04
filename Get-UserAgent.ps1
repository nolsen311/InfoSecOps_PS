$global:access_key = "%%INSERT API KEY%%"
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
    @( $response = Invoke-RestMethod -Uri "http://api.userstack.com/detect?access_key=$($access_key)&ua=$($UserAgent)" `
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
        $InputFile,
        [Parameter()]
        [string]
        $OutputFile
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
            $response = Invoke-RestMethod -Uri "http://api.userstack.com/detect?access_key=$($access_key)&ua=$($_.UserAgent)" `
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
    $output | ConvertTo-Csv | Out-File -FilePath $OutputFile

}
