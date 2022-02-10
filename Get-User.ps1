function Get-User { 
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$UserName = $Env:UserName,
        [Parameter()]
        [switch]$WithPhoto = $false
    )
    $global:ad_user = Get-ADUser $UserName -Properties *

    $user = `
    $ad_user | 
    Select-Object -Property name,`
                            emailaddress,`
                            enabled,`
                            passwordexpired,`
                            passwordlastset,`
                            userprincipalname,`
                            department,`
                            title,`
                            physicaldeliveryofficename,`
                            lockedout,`
                            officephone,`
                            mobilephone,`
                            thumbnailPhoto | 
    ForEach-Object { [PSCustomObject] @{ Name = $_.name; 
                                        Department = $_.department; 
                                        Title = $_.title; 
                                        Office = $_.physicaldeliveryofficename;
                                        "User Name" = $_.userprincipalname; 
                                        "Work Phone" = $_.officephone;
                                        "Corp Cell Phone" = $_.mobilephone
                                        Email = $_.emailaddress;
                                        "Locked Out" = $_.lockedout; 
                                        Enabled = $_.enabled; 
                                        "Password Expired" = $_.passwordexpired; 
                                        "Password Set" = $( if ($_.passwordLastSet){( New-TimeSpan -Start (Get-Date) -End $_.passwordlastset)} else { "PASSWORD NOT CHANGED" });
                                        Photo = $_.thumbnailPhoto
                                        }
            }
    $user | Select-Object -Property * -ExcludeProperty Photo | Tee-Object -Variable clippy
    if ($WithPhoto) {
        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $displayForm = New-Object Windows.Forms.Form
        $displayForm.Text = "$($user.Name)"
        $displayForm.AutoSize = $true
        $displayForm.AutoSizeMode = "GrowAndShrink"
        
        $PictureBox = New-Object Windows.Forms.PictureBox
        $PictureBox.SizeMode = "AutoSize"
        $PictureBox.Image = $user.Photo
        
        $displayForm.Controls.Add($PictureBox)
        $displayForm.Add_Shown({$displayForm.Activate()})
    
        $displayForm.ShowDialog()
    }
    $PSStyle.OutputRendering = "Plaintext"
    $clippy = '```' + "`n" + ($clippy | Out-String).Trim() + "`n" + '```'
    $clippy | Set-Clipboard
    $PSStyle.OutputRendering = "Ansi"
    Write-Host -ForegroundColor Yellow 'Use $ad_user object for full properties list'
    Write-Host -ForegroundColor Yellow 'User properties have been saved to the Clipboard'
}