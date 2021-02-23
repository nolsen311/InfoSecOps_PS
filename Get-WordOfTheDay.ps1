#Requires -PSEdition Desktop
Function Get-WordOfTheDay {
    $ie = Invoke-WebRequest -Uri "http://febe/teamsites/it/wotd.aspx" -UseDefaultCredentials
    $word_of_the_day = $ie.ParsedHtml.GetElementById("WOTD").InnerText
    Write-Host $word_of_the_day -ForegroundColor Green
}