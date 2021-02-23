[string[]]$output = "`n`$functions_dir = `"$PSScriptRoot`""
$output += "Get-ChildItem -Path `$functions_dir -File -Filter *ps1  | %{ Import-Module `$_.FullName -ErrorAction SilentlyContinue}"
$output |
    Out-File -FilePath $PROFILE -Append -NoClobber -Encoding ascii