$body=get-content "c:\serverreport.txt"

$messageParameters = @{                        
                Subject = "Inst"                        
                Body = $body                      
                From = "Server@Home.NET"                        
                To = "andy0taylor@googlemail.com"                        
                SmtpServer = "Relay.Plus.NET"                        
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml   