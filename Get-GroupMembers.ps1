function Get-GroupMembers {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $GroupName
    )
    Get-ADGroupMember $GroupName | ForEach-Object { $_.name }
}
function Get-AllowGroup {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $GroupName
    )
    Get-ADGroupMember "WSECU Allow $GroupName" | ForEach-Object { $_.name }
}