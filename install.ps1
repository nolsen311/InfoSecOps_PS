Switch ($PSEdition) {
    "Core" { $output = @"
`n`$functions_dir = "$PSScriptRoot"
Get-ChildItem -Path `$functions_dir -Filter *ps1 | 
    ForEach-Object { 
        if (-not (Select-String -Path `$_.FullName -Pattern "#Requires -PSEdition Desktop" -SimpleMatch) `
            -and -not (`$_.Name -eq "install.ps1")) {
            Import-Module `$_.FullName }
        }
"@; 
            break; }
    "Desktop" { $output = @"
`n`$functions_dir = "$PSScriptRoot"
Get-ChildItem -Path `$functions_dir -Filter *ps1 | 
    ForEach-Object { 
        if ((Select-String -Path `$_.FullName -Pattern "#Requires -PSEdition Desktop" -SimpleMatch) `
            -and -not (`$_.Name -eq "install.ps1")) {
            Import-Module `$_.FullName }
        }
"@; 
            break; }
}
if (Test-Path $PROFILE -PathType Leaf) {
    $output |
        Out-File -FilePath $PROFILE -Append -NoClobber -Encoding ascii 
} else {
    $output |
        Out-File -FilePath $PROFILE -Encoding ascii
}