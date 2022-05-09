Function Clear-TempDirs {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateRange('Negative')]
        [int]
        $Days=-60,
        [Parameter()]
        [switch]
        $Force
    )

    $temp_dir_base_path = "$env:USERPROFILE\Downloads\"
    $temp_dir_filter = "TEMP*"
    $date_offset = (Get-Date).AddDays($Days)
    $confirmations = @("y","yes")

    $deleted_files = `
    Get-ChildItem -Path $temp_dir_base_path -Filter $temp_dir_filter |
    ForEach-Object {
        Get-ChildItem -Path $_.FullName -Recurse |
        Where-Object { $_.CreationTime -lt $date_offset } |
        Sort-Object -Property LastWriteTime -Descending
    }
    $deleted_files += `
    Get-ChildItem -Path (Join-Path -Path $temp_dir_base_path -ChildPath Fireshot) |
    ForEach-Object {
            Get-ChildItem -Path $_.FullName -Recurse |
            Where-Object { $_.CreationTime -lt $date_offset } |
            Sort-Object -Property LastWriteTime -Descending
    }

    Write-Verbose "Files older than $(Get-Date($date_offset) -UFormat '%m-%d-%Y') will be deleted"

    if (-not $Force) {
        $deleted_files | ForEach-Object { Write-Host "$($_.LastWriteTime)`t$($_.FullName)" }
        if ($confirmations -icontains (Read-Host -Prompt "Do you want to PERMANENTLY DELETE these files/directories?")) {
            $deleted_files.FullName | Remove-Item -Recurse -Force
            Write-Verbose "Files were deleted AFTER confirmation"
            break
        }
        Write-Verbose "Files were NOT deleted AFTER confirmation"
    } else {
        $deleted_files.FullName | Remove-Item -Recurse -Force
        Write-Verbose "Files were deleted WITHOUT confirmation"
    }
}