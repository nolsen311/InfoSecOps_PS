function Get-User { 
    [CmdletBinding(DefaultParameterSetName='Default')]
    param
    (
        [Parameter(Mandatory=$true,
                   ParameterSetName='Default',
                   HelpMessage='Enter a user name.',
                   Position=0)]
        [Parameter(Mandatory=$true,
                    ParameterSetName='Photo')]
        [string]$UserName,
        [Parameter(Mandatory=$false,
                   ParameterSetName='Photo',
                   HelpMessage="Do you want to see their photo?")]
        [switch]$WithPhoto = $false,
        [Parameter(Mandatory=$false,
                   ParameterSetName='Photo',
                   HelpMessage="Would you like to save the photo to a file?")]
        [switch]$SavePhoto = $false
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
    $user | Select-Object -Property * -ExcludeProperty Photo #| Tee-Object -Variable clippy 
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
    $clippy = '```' + "`n" + ($user | Select-Object -Property * -ExcludeProperty Photo | Out-String).Trim() + "`n" + '```'
    # $clippy = '```' + "`n" + ($clippy | Out-String).Trim() + "`n" + '```'
    $clippy | Set-Clipboard
    $PSStyle.OutputRendering = "Ansi"
    Write-Host -ForegroundColor Yellow 'Use $ad_user object for full properties list'
    Write-Host -ForegroundColor Yellow 'User properties have been saved to the Clipboard'
    if ($SavePhoto) {
        $photo = ".\$(Get-Date -UFormat '%Y-%m-%d')_$UserName.jpg"
        $user.Photo | Set-Content $photo -Encoding byte
        Write-Host -ForegroundColor Yellow "User photo saved to $photo"
    }
}