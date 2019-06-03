#get-mailbox|foreach {Add-MailboxFolderPermission -identity ($_.userprincipalname+":\calendar") -user "ExchangeEveryone" -AccessRights Reviewer}


get-mailbox|foreach {Add-MailboxFolderPermission -identity ($_.userprincipalname+":\calendar") -user reception@connect-up.co.uk -AccessRights PublishingEditor}