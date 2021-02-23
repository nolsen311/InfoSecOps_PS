function Get-Dossier{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ParameterSetName="IP")]
        [IPAddress]
        $IP,
        [Parameter(Mandatory=$true,ParameterSetName="Domain")]
        [System.Security.Policy.Url]
        $domain
    )
    if ($IP) {$search_query = $IP}
    elseif ($domain) {$search_query = $domain.Value}
    $centralops_url = "https://centralops.net/co/DomainDossier.aspx?addr=$search_query&dom_dns=true&dom_whois=true&net_whois=true"
    Start-Process $centralops_url
    $talos_url = "https://talosintelligence.com/reputation_center/lookup?search=$search_query"
    Start-Process $talos_url
}