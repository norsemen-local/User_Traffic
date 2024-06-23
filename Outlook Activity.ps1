# Define the users involved in the automation
$users = @(
    "user1@example.com",
    "user2@example.com",
    "user3@example.com",
    "user4@example.com",
    "user5@example.com",
    "user6@example.com",
    "user7@example.com",
    "user8@example.com",
    "user9@example.com",
    "user10@example.com"
)

# Function to check if Outlook is open, if not, open it
function Open-Outlook {
    try {
        $outlook = [Runtime.InteropServices.Marshal]::GetActiveObject("Outlook.Application")
        Write-Output "Outlook is already running."
    }
    catch {
        Write-Output "Outlook is not running. Starting Outlook..."
        Start-Process "outlook.exe"
        # Wait for Outlook to open
        Start-Sleep -Seconds 10
        $outlook = New-Object -ComObject Outlook.Application
    }
    return $outlook
}

# Function to get the current user's Outlook ID
function Get-CurrentUser {
    param (
        [ref]$outlook
    )
    $namespace = $outlook.Value.GetNamespace("MAPI")
    $currentUser = $namespace.CurrentUser.Address
    return $currentUser
}

# Function to send initial batch of emails
function Send-InitialBatch {
    param (
        [string[]]$recipients,
        [string]$initialMessage = "This is a starter message to populate the XSIAM data ingestion metrics",
        [int]$emailsPerRecipient = 25
    )
    foreach ($recipient in $recipients) {
        for ($i = 0; $i -lt $emailsPerRecipient; $i++) {
            $mail = $outlook.CreateItem(0) # 0: olMailItem
            $mail.To = $recipient
            $mail.Subject = "Starter Email"
            $mail.Body = $initialMessage
            $mail.Send()
            Start-Sleep -Milliseconds 200 # Slight delay to prevent being flagged as spam
        }
    }
}

# Function to read emails in the inbox
function Read-Emails {
    param (
        [int]$numberOfEmailsToRead = 5
    )
    $namespace = $outlook.GetNamespace("MAPI")
    $inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)
    $emails = $inbox.Items

    $count = 0
    foreach ($email in $emails) {
        if ($count -ge $numberOfEmailsToRead) {
            break
        }

        if ($email.UnRead -eq $true) {
            Write-Output "Reading email from: $($email.SenderName) with subject: $($email.Subject)"
            $email.Display()
            Start-Sleep -Seconds 6
            $email.UnRead = $false
            $count++
        }
    }
}

# Function to reply to emails in the inbox
function Reply-To-Emails {
    param (
        [string]$replyMessage = "This is to populate the XSIAM data ingestion metrics",
        [int]$numberOfReplies = 1
    )
    $namespace = $outlook.GetNamespace("MAPI")
    $inbox = $namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderInbox)
    $emails = $inbox.Items

    $count = 0
    foreach ($email in $emails) {
        if ($count -ge $numberOfReplies) {
            break
        }

        if ($email.UnRead -eq $false) {
            Write-Output "Replying to email from: $($email.SenderName) with subject: $($email.Subject)"
            $reply = $email.Reply()
            $reply.Body = $replyMessage
            $reply.Send()
            $count++
        }
    }
}

# Main script logic
$outlook = Open-Outlook

# Get the current user
$current_user = Get-CurrentUser -outlook ([ref]$outlook)

# Determine the recipients (all users except the current one)
$recipients = $users | Where-Object { $_ -ne $current_user }

# Send initial batch of emails
Send-InitialBatch -recipients $recipients

# Perform the main loop of reading and replying to emails
for ($cycle = 0; $cycle -lt 45; $cycle++) {
    Read-Emails -numberOfEmailsToRead 5
    Reply-To-Emails -replyMessage "This is to populate the XSIAM data ingestion metrics" -numberOfReplies 1
    Write-Output "Completed cycle $($cycle + 1) of reading and replying."
}
