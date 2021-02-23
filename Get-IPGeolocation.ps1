#requires -Version 3
function Get-IPGeolocation
{
    Param
    (
        [string]$IPAddress
    )
    
    [string]$script:access_key="528bc56d6728d8e56e209662210ad3c8"

    $request = Invoke-RestMethod -Method Get -Uri "http://api.ipapi.com/$($IPAddress)?access_key=$($access_key)"

    [PSCustomObject]@{
        IP        = $request.IP
        Latitude  = $request.Latitude
        Longitude = $request.Longitude
        City      = $request.City
        State     = $request.Region_name
        Country   = $request.Country_Name
        Code      = $request.Country_code
        Continent = $request.continent_name
    }
}