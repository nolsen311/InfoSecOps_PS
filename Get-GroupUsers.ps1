function Get-GroupUsers { 
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,
        [Parameter()]
        [switch]$WithPhotos = $false
    )
    $ad_group = Get-ADGroup $GroupName
    $global:ad_group_users = @((Get-ADGroupMember $GroupName).SAMAccountName)
    
    $group = $ad_group |
        select -Property name,`
                         Created,`
                         Description,`
                         GroupScope,`
                         GroupCategory,`
                         SID,`
                         SIDHistory |
        foreach { [PSCustomObject] @{ Name          = $_.name;
                                      Scope         = $_.GroupScope;
                                      Type          = $_.GroupCategory;
                                      Description   = $_.Description;
                                      SID           = $_.SID;
                                      "SID History" = $_.SIDHistory;
                                      Created       = $_.Created;
                                      }
                }
    $users = `
    @($ad_group_users | %{ Get-User $_ })
#        select -Property name,`
#                         emailaddress,`
#                         enabled,`
#                         passwordexpired,`
#                         passwordlastset,`
#                         userprincipalname,`
#                         department,`
#                         title,`
#                         physicaldeliveryofficename,`
#                         lockedout,`
#                         officephone,`
#                         mobilephone,`
#                         thumbnailPhoto | 
#        foreach { [PSCustomObject] @{ Name = $_.name; 
#                                      Department = $_.department; 
#                                      Title = $_.title; 
#                                      Office = $_.physicaldeliveryofficename;
#                                      "User Name" = $_.userprincipalname; 
#                                      "Work Phone" = $_.officephone;
#                                      "Corp Cell Phone" = $_.mobilephone
#                                      Email = $_.emailaddress;
#                                      "Locked Out" = $_.lockedout; 
#                                      Enabled = $_.enabled; 
#                                      "Password Expired" = $_.passwordexpired; 
#                                      "Password Set" = $( if ($_.passwordLastSet){( New-TimeSpan -Start (Get-Date) -End $_.passwordlastset)} else { "PASSWORD NOT CHANGED" });
#                                      Photo = $_.thumbnailPhoto
#                                      }
#                }
#        })
    $group
    $users
    if ($WithPhoto) {
        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $displayForm = New-Object Windows.Forms.Form
        $displayForm.Text = "$($GroupName.Name)"
        $displayForm.AutoSize = $true
        $displayForm.AutoSizeMode = "GrowAndShrink"
        
        $PictureBox = New-Object Windows.Forms.PictureBox
        $PictureBox.SizeMode = "AutoSize"
        $PictureBox.Image = $user.Photo
        
        $displayForm.Controls.Add($PictureBox)
        $displayForm.Add_Shown({$displayForm.Activate()})
    
        $displayForm.ShowDialog()
    }
    #Write-Host -ForegroundColor Yellow 'Use $ad_user object for full properties list'
}