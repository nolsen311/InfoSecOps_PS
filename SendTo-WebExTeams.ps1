Function Get-BotCredLocation {
    return Join-Path -Path "$functions_dir/assets/InfoSecBot.credential"
}
Function Get-BotCreds {
    return (Import-CliXml -Path $(Get-BotCredLocation))
}
Function Set-BotCreds {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ID,
        [Parameter(Mandatory=$true)]
        [string]
        $Token
    )
    @{ "ID" = $ID
       "Token" = ($Token | ConvertTo-SecureString -AsPlainText)} |
       Export-CliXml -Path $(Get-BotCredLocation)
}
Function Get-BotRoomId {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $CoreTeam
    )
    $response = `
    Invoke-RestMethod -Method Get `
                        -Headers @{ Authorization = "Bearer " + $((Get-BotCreds).Token | ConvertFrom-SecureString -AsPlainText) } `
                        -ContentType "application/json" `
                        -Uri "https://api.ciscospark.com/v1/rooms"
    if (-not $CoreTeam) {
        return ($response.items | Where-Object {$_.title -inotmatch "Core Team"}).id
    } else { return $response.items.id }

}
Function SendTo-InfoSecBot {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Message,
        [Parameter()]
        [switch]
        $Markdown,
        [Parameter()]
        [switch]
        $CoreTeam
    )
    Get-BotRoomId -CoreTeam:$CoreTeam |
    ForEach-Object {

        $roomID = $_

        if ($Markdown) {
            $body = @{ roomId = $roomID
                    markdown = $Message }
        } else {
            $body = @{ roomId = $roomID
                    text = "$Message" }
        }
        $body = $body | ConvertTo-Json

        try {
            $response = `
            Invoke-RestMethod -Method Post `
                              -Headers @{ Authorization = "Bearer " + $((Get-BotCreds).Token | ConvertFrom-SecureString -AsPlainText) } `
                              -ContentType "application/json" `
                              -Body $body `
                              -Uri "https://api.ciscospark.com/v1/messages" 
            } catch { 
                $err = $_ 
                Write-Host $err.CategoryInfo -ForegroundColor Red
            }
    }

}