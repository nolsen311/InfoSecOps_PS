function Send-PhishProneEmails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if ( Test-Path -Path $_ -PathType Leaf ) {$true}
            else { throw "File $_ does not exist!" }
        })]
        [string]
        $File
    )
    $month_name="$(Get-Date -UFormat '%B')"
    $phishing_guide = "assets/Phishing` Conversation` Guide.pdf" # whatever attachments you want to send
$email_body = @"
%%MANAGER%%,
<p>I'm following up with leaders to provide information on your staff who recently
clicked a link and/or opened a bad attachment from a phishing email. In the table
below, you can see the employees who clicked; the "Email Template" column shows the
subject line from the message they received.
<p>
%%EXCEL_DATA%%
<p>
<p>There is a pop-up "in the moment" learning given at the time an employee clicks 
on a mock phish, which outlines the "red flag" areas on the email. Our request is 
that you provide follow-up coaching using the attached guide during a conversation 
and gain some insight into what tripped them up (why they failed to identfy the phish).
<p>
<p>
<p>Thank you,
<br%%YOUR NAME%%
"@

    $clickers = Import-Csv -Path $File -Encoding utf8
    $leaders_name = $($clickers)."Manager Name" | Sort-Object -Unique
    $email_subject = "$($month_name) List of Clickers - Phishing Campaign"

    foreach ($leader in $leaders_name) {
        $ldr_email = $clickers | 
            Where-Object { $_."Manager Name" -eq $leader } |
            Select-Object -ExpandProperty "Manager Email"

        $clicker_data = $clickers |
            Where-Object { $_."Manager Name" -eq $leader } |
            Select-Object -Property "First Name", "Last Name", "Job Title", "Email Template" |
            ConvertTo-Html -Fragment
        [string]$clicker_data = ($clicker_data | Out-String)

        $temp_body = $email_body -replace "%%MANAGER%%","$leader"
        $temp_body = $temp_body -replace "%%EXCEL_DATA%%","$clicker_data"

        Send-MailMessage -Attachments $phishing_guide `
                         -Body $temp_body `
                         -BodyAsHtml `
                         -From "%%YOUR EMAIL ADDRESS%%" `
                         -Smtp "%%YOUR SMTP SERVER%%" `
                         -Subject "$email_subject" `
                         -To $ldr_email `
                         -Priority High `
                         -Encoding utf8
        ## TESTING
        # $temp_body += "`n<p>CC: $ldr_email"
        # Send-MailMessage -Attachments $phishing_guide `
        #                  -Body $temp_body `
        #                  -BodyAsHtml `
        #                  -From "%%YOUR EMAIL ADDRESS%%" `
        #                  -Smtp "%%YOUR SMTP SERVER%%" `
        #                  -Subject "$email_subject" `
        #                  -To "%%YOUR EMAIL ADDRESS%%" `
        #                  -Priority High `
        #                  -Encoding utf8
        Clear-Variable temp_body 
        Clear-Variable ldr_email
        Clear-Variable clicker_data
    }
}
