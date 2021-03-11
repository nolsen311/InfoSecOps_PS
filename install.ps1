[string[]]$output = "`n`$functions_dir = `"$PSScriptRoot`""
$output += "Get-ChildItem -Path `$functions_dir -File -Filter *ps1  | %{ Import-Module `$_.FullName }"
if (Test-Path $PROFILE -PathType Leaf) {
    $output |
        Out-File -FilePath $PROFILE -Append -NoClobber -Encoding ascii 
} else {
    $output |
        Out-File -FilePath $PROFILE -Encoding ascii
}