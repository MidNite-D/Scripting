#####  EXPORT TO PST SCRIPT - ANDY TAYLOR 08/09/09


####  First Section taken from exchange.ps1, needed to load exchange functions, variables & stuff
####  ends line 250




# Copyright (c) Microsoft Corporation. All rights reserved.  

## ALIASES ###################################################################

set-alias list       format-list 
set-alias table      format-table 

## Confirmation is enabled by default, uncommenting next line will disable it 
# $ConfirmPreference = "None"


## EXCHANGE VARIABLEs ########################################################

$global:exbin = (get-itemproperty HKLM:\SOFTWARE\Microsoft\Exchange\Setup).MsiInstallPath + "bin\"
$global:exinstall = (get-itemproperty HKLM:\SOFTWARE\Microsoft\Exchange\Setup).MsiInstallPath
$global:exscripts = (get-itemproperty HKLM:\SOFTWARE\Microsoft\Exchange\Setup).MsiInstallPath + "scripts\"
$global:AdminSessionADSettings = [Microsoft.Exchange.Data.Directory.AdminSessionADSettings]::Instance
## Reset the Default Domain
$global:AdminSessionADSettings.ViewEntireForest = $false

$FormatEnumerationLimit = 16

## PROMPT ####################################################################

## PowerShell can support very rich prompts, this simple one prints the current
## working directory and updates the console window title to show the machine 
## name and directory.  

function prompt 
{ 
	$cwd = (get-location).Path
	$scope = "View Entire Forest"
	if (!$AdminSessionADSettings.ViewEntireForest)
	{
		$scope = $AdminSessionADSettings.DefaultScope
	}
	$host.UI.RawUI.WindowTitle = "Machine: " + $(hostname) + " | Scope: " + $scope
	$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[PS]")
	" $cwd>" 
}


## FUNCTIONs #################################################################

## returns all defined functions 

function functions
{ 
    if ( $args ) 
    { 
        foreach($functionName in $args )
        {
             get-childitem function:$functionName | 
                  foreach { "function " + $_.Name; "{" ; $_.Definition; "}" }
        }
    } 
    else 
    { 
        get-childitem function: | 
             foreach { "function " + $_.Name; "{" ; $_.Definition; "}" }
    } 
}

## generates a tip of the day 


function get-tip
{
    param($local:number=$null) 

    if( ($global:exrandom -eq $null) -or ($exrandom -isnot [System.Random]))
    {
        $global:exrandom = new-object System.Random
    }

    $exchculture = [System.Threading.Thread]::CurrentThread.CurrentUICulture.Parent

    if ( test-path "$($global:exbin)\$($exchculture.Name)\extips.xml" )
    {
	$exchculture = $exchculture.Name 
    }
    else 
    {
	$exchculture = 'en'
    } 

    if (test-path "$($global:exbin)\$exchculture\extips.xml")
    {

        $local:tips = [xml](get-content $global:exbin\$exchculture\extips.xml)
        if($local:number -eq $null)
        {
            $local:temp = $global:exrandom.Next( 0, $local:tips.topic.developerConceptualDocument.introduction.table.row.Count )
            write-host -fore Yellow ( "Tip of the day #" + $local:temp + ":`n" )
            $local:nav = $tips.topic.developerConceptualDocument.introduction.table.row[$local:temp].entry.CreateNavigator()
            [void] $nav.MoveToFirstChild()
            do
            {
               write-host $nav.Value
            }
            while( $nav.MoveToNext() )
	    ""
        }
        else
        {
            $local:nav = $tips.topic.developerConceptualDocument.introduction.table.row[$local:number].entry.CreateNavigator()       
	    write-host -fore Yellow ( "Tip of the day #" + $local:number + ":`n" )
         
	    
            [void] $nav.MoveToFirstChild()
            do
            {
                 write-host $nav.Value
            }
            while( $nav.MoveToNext() )
            ""
        }
    }
    else
    {
        "Exchange tips file $($global:exbin)\$exchculture\extips.xml not found!"
    }

    trap
    {
	continue
    }
}


## only returns exchange commands 

function get-excommand
{
	if ($args[0] -eq $null)
	{
		get-command -pssnapin Microsoft.Exchange*
	}
	else
	{
		get-command $args[0] | where { $_.psSnapin -ilike 'Microsoft.Exchange*' }
	}
}


## only returns PowerShell commands 

function get-pscommand
{
	if ($args[0] -eq $null) 
	{
		get-command -pssnapin Microsoft.PowerShell* 
	}
	else 
	{
		get-command $args[0] | where { $_.PsSnapin -ilike 'Microsoft.PowerShell*' }	}
}


## prints the Exchange Banner in pretty colors 

function get-exbanner
{
	write-host "`n         Welcome to the Exchange Management Shell!`n"

	write-host " Full list of cmdlets:          " -no 
	write-host -fore Yellow "get-command"

	write-host " Only Exchange cmdlets:         " -no
	write-host -fore Yellow "get-excommand"

##	write-host " Only Monad cmdlets:            " -no
##	write-host -fore Yellow "get-pscommand"

	write-host " Cmdlets for a specific role:   " -no
	write-host -fore Yellow "get-help -role *UM* or *Mailbox*"

	write-host " Get general help:              " -no
	write-host -fore Yellow "help"

	write-host " Get help for a cmdlet:         " -no
	write-host -fore Yellow "help <cmdlet-name> or <cmdlet-name> -?"

	write-host " Show quick reference guide:    " -no
	write-host -fore Yellow "quickref"

	write-host " Exchange team blog:            " -no
	write-host -fore Yellow "get-exblog"

	write-host " Show full output for a cmd:    " -no
	write-host -fore Yellow "<cmd> | format-list`n"
}


## shows quickref guide

function quickref
{
    $exchculture = [System.Threading.Thread]::CurrentThread.CurrentUICulture.Parent

    if ( test-path "$($global:exbin)\$($exchculture.Name)\exquick.htm" )
    {
	$exchculture = $exchculture.Name 
    }
    else 
    {
	$exchculture = 'en'
    } 

    if ( test-path "$($global:exbin)\$exchculture\exquick.htm" )
    {
	invoke-item $global:exbin\$exchculture\exquick.htm
    }
    else
    {
	"Exchange quickstart guide $global:exbin\$exchculture\exquick.htm not found!"
    } 
}


function get-exblog
{
       invoke-expression 'cmd /c start http://go.microsoft.com/fwlink/?LinkId=35786'
}


## now actually call the functions 

get-exbanner 
get-tip 










################ START OF EXPORT SCRIPT#####################
CLS

### Get creditials and target
$USER=read-host "Your Credentials (DOMAIN\USERNAME) "
$TARGET=read-host "Target Mailbox (Alias) "

### Grant user rights to target mailbox
Get-Mailbox $TARGET| Add-MailboxPermission -User $USER -AccessRights FullAccess

### Export mailbox to archive
Export-Mailbox -identity $TARGET -pstfolderpath \\ukban-pststore\archive\leavers

### Confirm file status
Get-Item \\ukban-pststore\archive\leavers\$target.pst

### Compress Arhcive Remotely

Write-Host "***** COMPRESSING REMOTE FILE *****"
$commandline="c:\scripts\psexec /accepteula \\ukban-pststore.iresource.local -w c:\scriptapps c:\scriptapps\7za.exe a -tzip d:\archive\leavers\$target.zip d:\archive\leavers\$target.pst"
cmd /c $commandline

### Display result
$resultzip=Get-Item \\ukban-pststore\archive\leavers\$target.ZIP
$resultpst=Get-Item \\ukban-pststore\archive\leavers\$target.PST
Write-Host $resultpst.name
Write-Host $resultpst.length"bytes"
Write-Host $resultzip.name
Write-Host $resultzip.length"bytes"


### Delete PST
$delyn=Read-Host "Delete PST?"
if ($delyn -eq "y")
{
remove-item "\\ukban-pststore.iresource.local\archive\leavers\$target.pst"
}

### Finish Off
Write-Host "Press Any Key to Finish"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host ""






# SIG # Begin signature block
# MIIkDgYJKoZIhvcNAQcCoIIj/zCCI/sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUONBWg24vCtFxtVHgwnz3q6X6
# Kf+ggh7hMIIEEjCCAvqgAwIBAgIPAMEAizw8iBHRPvZj7N9AMA0GCSqGSIb3DQEB
# BAUAMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQgQ29y
# cC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
# cm9zb2Z0IFJvb3QgQXV0aG9yaXR5MB4XDTk3MDExMDA3MDAwMFoXDTIwMTIzMTA3
# MDAwMFowcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBD
# b3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhN
# aWNyb3NvZnQgUm9vdCBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCpAr3BcOY78k4bKJ+XeF4w6qKpjSVf+P6VTKO3/p2iID58UaKboo9g
# MmvRQmR57qx2yVTa8uuchhyPn4Rms8VremIj1h083g8BkuiWxL8tZpqaaCaZ0Dos
# vwy1WCbBRucKPjiWLKkoOajsSYNC44QPu5psVWGsgnyhYC13TOmZtGQ7mlAcMQgk
# FJ+p55ErGOY9mGMUYFgFZZ8dN1KH96fvlALGG9O/VUWziYC/OuxUlE6u/ad6bXRO
# rxjMlgkoIQBXkGBpN7tLEgc8Vv9b+6RmCgim0oFWV++2O14WgXcE2va+roCV/rDN
# f9anGnJcPMq88AijIjCzBoXJsyB3E4XfAgMBAAGjgagwgaUwgaIGA1UdAQSBmjCB
# l4AQW9Bw72lyniNRfhSyTY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykg
# MTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyI
# EdE+9mPs30AwDQYJKoZIhvcNAQEEBQADggEBAJXoC8CN85cYNe24ASTYdxHzXGAy
# n54Lyz4FkYiPyTrmIfLwV5MstaBHyGLv/NfMOztaqTZUaf4kbT/JzKreBXzdMY09
# nxBwarv+Ek8YacD80EPjEVogT+pie6+qGcgrNyUtvmWhEoolD2Oj91Qc+SHJ1hXz
# UqxuQzIH/YIX+OVnbA1R9r3xUse958Qw/CAxCYgdlSkaTdUdAqXxgOADtFv0sd3I
# V+5lScdSVLa0AygS/5DW8AiPfriXxas3LOR65Kh343agANBqP8HSNorgQRKoNWob
# ats14dQcBOSoRQTIWjM4bk0cDWK3CqKM09VUP0bNHFWmcNsSOoeTdZ+n0qAwggQS
# MIIC+qADAgECAg8AwQCLPDyIEdE+9mPs30AwDQYJKoZIhvcNAQEEBQAwcDErMCkG
# A1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBDb3JwLjEeMBwGA1UE
# CxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgUm9v
# dCBBdXRob3JpdHkwHhcNOTcwMTEwMDcwMDAwWhcNMjAxMjMxMDcwMDAwWjBwMSsw
# KQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYD
# VQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBS
# b290IEF1dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkC
# vcFw5jvyThson5d4XjDqoqmNJV/4/pVMo7f+naIgPnxRopuij2Aya9FCZHnurHbJ
# VNry65yGHI+fhGazxWt6YiPWHTzeDwGS6JbEvy1mmppoJpnQOiy/DLVYJsFG5wo+
# OJYsqSg5qOxJg0LjhA+7mmxVYayCfKFgLXdM6Zm0ZDuaUBwxCCQUn6nnkSsY5j2Y
# YxRgWAVlnx03Uof3p++UAsYb079VRbOJgL867FSUTq79p3ptdE6vGMyWCSghAFeQ
# YGk3u0sSBzxW/1v7pGYKCKbSgVZX77Y7XhaBdwTa9r6ugJX+sM1/1qcaclw8yrzw
# CKMiMLMGhcmzIHcThd8CAwEAAaOBqDCBpTCBogYDVR0BBIGaMIGXgBBb0HDvaXKe
# I1F+FLJNjv/LoXIwcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jv
# c29mdCBDb3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYD
# VQQDExhNaWNyb3NvZnQgUm9vdCBBdXRob3JpdHmCDwDBAIs8PIgR0T72Y+zfQDAN
# BgkqhkiG9w0BAQQFAAOCAQEAlegLwI3zlxg17bgBJNh3EfNcYDKfngvLPgWRiI/J
# OuYh8vBXkyy1oEfIYu/818w7O1qpNlRp/iRtP8nMqt4FfN0xjT2fEHBqu/4STxhp
# wPzQQ+MRWiBP6mJ7r6oZyCs3JS2+ZaESiiUPY6P3VBz5IcnWFfNSrG5DMgf9ghf4
# 5WdsDVH2vfFSx73nxDD8IDEJiB2VKRpN1R0CpfGA4AO0W/Sx3chX7mVJx1JUtrQD
# KBL/kNbwCI9+uJfFqzcs5HrkqHfjdqAA0Go/wdI2iuBBEqg1ahtq2zXh1BwE5KhF
# BMhaMzhuTRwNYrcKoozT1VQ/Rs0cVaZw2xI6h5N1n6fSoDCCBGAwggNMoAMCAQIC
# Ci6rEdxQ/1ydy8AwCQYFKw4DAh0FADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNzA4
# MjIyMjMxMDJaFw0xMjA4MjUwNzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcg
# UENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt3l91l2zRTmoNKwx
# 2vklNUl3wPsfnsdFce/RRujUjMNrTFJi9JkCw03YSWwvJD5lv84jtwtIt3913UW9
# qo8OUMUlK/Kg5w0jH9FBJPpimc8ZRaWTSh+ZzbMvIsNKLXxv2RUeO4w5EDndvSn0
# ZjstATL//idIprVsAYec+7qyY3+C+VyggYSFjrDyuJSjzzimUIUXJ4dO3TD2AD30
# xvk9gb6G7Ww5py409rQurwp9YpF4ZpyYcw2Gr/LE8yC5TxKNY8ss2TJFGe67SpY7
# UFMYzmZReaqth8hWPp+CUIhuBbE1wXskvVJmPZlOzCt+M26ERwbRntBKhgJuhgCk
# wIffUwIDAQABo4H6MIH3MBMGA1UdJQQMMAoGCCsGAQUFBwMDMIGiBgNVHQEEgZow
# gZeAEFvQcO9pcp4jUX4Usk2O/8uhcjBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eYIPAMEAizw8
# iBHRPvZj7N9AMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMwdznYAcFuv8drE
# TppRRC6jRGPwMAsGA1UdDwQEAwIBhjAJBgUrDgMCHQUAA4IBAQB7q65+SibyzrxO
# dKJYJ3QqdbOG/atMlHgATenK6xjcacUOonzzAkPGyofM+FPMwp+9Vm/wY0SpRADu
# lsia1Ry4C58ZDZTX2h6tKX3v7aZzrI/eOY49mGq8OG3SiK8j/d/p1mkJkYi9/uEA
# uzTz93z5EBIuBesplpNCayhxtziP4AcNyV1ozb2AQWtmqLu3u440yvIDEHx69dLg
# Qt97/uHhrP7239UNs3DWkuNPtjiifC3UPds0C2I3Ap+BaiOJ9lxjj7BauznXYIxV
# hBoz9TuYoIIMol+Lsyy3oaXLq9ogtr8wGYUgFA0qvFL0QeBeMOOSKGmHwXDi86er
# zoBCcnYOMIIEajCCA1KgAwIBAgIKYQ94TQAAAAAAAzANBgkqhkiG9w0BAQUFADB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQTAeFw0wNzA4MjMwMDIzMTNaFw0wOTAy
# MjMwMDMzMTNaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAKLbCo3PwsFJm82qOjStI1lr22y+ISK3lMjqrr/G1SbC
# MhGLvNpdLPs2Vh4VK66PDd0Uo24oTH8WP0GsjUCxRogN2YGUrZcG0FdEdlzq8fwO
# 4n90ozPLdOXv42GhfgO3Rf/VPhLVsMpeDdB78rcTDfxgaiiFdYy3rbyF6Be0kL71
# FrZiXe0R3zruIVuLr4Bzw0XjlYl3YJvnrXfBN40zFC8T22LJrhqpT5hnrdQgOTBx
# 4I1nRuLGHPQNUHRBL+gFJGoha0mwksSyOcdCpW1cGEqrj9eOgz54CkfYpLKEI8Pi
# 8ntmsUp0vSZBS5xhFGBOMMiC89ALcHzuVU130ghVdoECAwEAAaOB+DCB9TAOBgNV
# HQ8BAf8EBAMCBsAwHQYDVR0OBBYEFPMhQI58UfhUS5jlF9dqgzQFLiboMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB8GA1UdIwQYMBaAFMwdznYAcFuv8drETppRRC6jRGPw
# MEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kv
# Y3JsL3Byb2R1Y3RzL0NTUENBLmNybDBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUH
# MAKGLGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvQ1NQQ0EuY3J0
# MA0GCSqGSIb3DQEBBQUAA4IBAQBAV29TZ54ggzQBDuYXSzyt69iBf+4NeXR3T5dH
# GPMAFWl+22KQov1noZzkKCn6VdeZ/lC/XgmzuabtgvOYHm9Z+vXx4QzTiwg+Fhcg
# 0cC1RUcIJmBXCUuU8AjMuk1u8OJIEig1iyFy31+2r2kSJJTu6TQJ235ub5IKUsoq
# TEmqMiyG6KHMXSa8vDzgW7KDC7o1HE+ERUf/u5ShWQeplt14vVd/padOzPKtnJpB
# 4stcJD7cfzRHTvbPyHud67bJnGMUU6+tmu/Xv8+goauVynorhyzAx9n8bAPavzit
# 8dFcGRcPwPfKgKYQCBrdkCPnsKFMPuqwESZ4DsEsuaRrx488MIIEnTCCA4WgAwIB
# AgIKYRQspwAAAAAABjANBgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1w
# aW5nIFBDQTAeFw0wNzA2MTIyMzU0NTFaFw0xMjA2MTMwMDA0NTFaMIGmMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVy
# IERTRSBFU046MjdGNC1ENDQwLTU0RjMxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1l
# c3RhbXBpbmcgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AJHLpHsUc9Pn1IaTwAN92ESk4bO1+Lj9vCpTAsqvkd2hGYM6MXj0lkQN5uDuRWaz
# vPYCdOo0OLzTdzwjtHD8BzLOnvNFQ+Z0U0xOL1u8UwU+gfzhw1bB5CaT23y6Y+CR
# bFZyquugixZ4ZYiXTuJ7IovNqlmezXjHOGKLQ41PxudDzEFF4vvZMe/Y/75pMcrs
# drn0IbSQNBf+yRD5uIbPXqHRUrJGWCG4OVeBbwiKX2x1FcCQNnattthJpEh9dp4J
# E+zCAH3jh7yXDw4c9ZpG1aTsa8Oqc0j47pOE+SUSSo4EgOB0UOIRaeD1+2LhZmx5
# MwSmJ3GENTZjEitZEwZ5xXUCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUN1XZlgmRta5b
# 2j/2WaH+SvSBlqAwHwYDVR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYD
# VR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvdHNwY2EuY3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYs
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUA
# A4IBAQAlnG+HOS0aiLECAz678khs6jwNDq7u5geVDmK6RyeP0w2qaCIfKfrP/L7a
# 7aQvqPJylA50J7P0rIwARchNnF4BBN6PW8nlViqe5pM98d0BIccGweJBWTJx/VgW
# IbPzGuQGq1sAaBl3fPj3t7unIslUK4jSiJzPLNA6XzoIfBVh9QIoFZ85bcZqL/gw
# eK5Z5Oxq+LWUVpY198M4DDyCGUDOgIooagJZH0BsC8LvsD81euuleWqL0Qoi5mD4
# CxASrCFgFK28yTXXv/2Y11oBNAV6ZrKOnPG74aHJdvD1shxMTUAZWbhGq0zIrEyU
# QuMnrvlTP5PKY3wll8uXxDae+a6gMIIEnTCCA4WgAwIBAgIKYRQspwAAAAAABjAN
# BgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQTAeFw0wNzA2
# MTIyMzU0NTFaFw0xMjA2MTMwMDA0NTFaMIGmMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046MjdGNC1E
# NDQwLTU0RjMxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJHLpHsUc9Pn1IaTwAN9
# 2ESk4bO1+Lj9vCpTAsqvkd2hGYM6MXj0lkQN5uDuRWazvPYCdOo0OLzTdzwjtHD8
# BzLOnvNFQ+Z0U0xOL1u8UwU+gfzhw1bB5CaT23y6Y+CRbFZyquugixZ4ZYiXTuJ7
# IovNqlmezXjHOGKLQ41PxudDzEFF4vvZMe/Y/75pMcrsdrn0IbSQNBf+yRD5uIbP
# XqHRUrJGWCG4OVeBbwiKX2x1FcCQNnattthJpEh9dp4JE+zCAH3jh7yXDw4c9ZpG
# 1aTsa8Oqc0j47pOE+SUSSo4EgOB0UOIRaeD1+2LhZmx5MwSmJ3GENTZjEitZEwZ5
# xXUCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUN1XZlgmRta5b2j/2WaH+SvSBlqAwHwYD
# VR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYDVR0fBD0wOzA5oDegNYYz
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvdHNwY2Eu
# Y3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYsaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUAA4IBAQAlnG+HOS0aiLEC
# Az678khs6jwNDq7u5geVDmK6RyeP0w2qaCIfKfrP/L7a7aQvqPJylA50J7P0rIwA
# RchNnF4BBN6PW8nlViqe5pM98d0BIccGweJBWTJx/VgWIbPzGuQGq1sAaBl3fPj3
# t7unIslUK4jSiJzPLNA6XzoIfBVh9QIoFZ85bcZqL/gweK5Z5Oxq+LWUVpY198M4
# DDyCGUDOgIooagJZH0BsC8LvsD81euuleWqL0Qoi5mD4CxASrCFgFK28yTXXv/2Y
# 11oBNAV6ZrKOnPG74aHJdvD1shxMTUAZWbhGq0zIrEyUQuMnrvlTP5PKY3wll8uX
# xDae+a6gMIIEnTCCA4WgAwIBAgIQaguZT8AAJasR20UfWHpnojANBgkqhkiG9w0B
# AQUFADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENv
# cnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1p
# Y3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNjA5MTYwMTA0NDdaFw0xOTA5MTUw
# NzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgUENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA3Ddu+6/IQkpxGMjOSD5TwPqrFLosMrsST1LIg+0+
# M9lJMZIotpFk4B9QhLrCS9F/Bfjvdb6Lx6jVrmlwZngnZui2t++Fuc3uqv0SpAtZ
# Iikvz0DZVgQbdrVtZG1KVNvd8d6/n4PHgN9/TAI3lPXAnghWHmhHzdnAdlwvfbYl
# BLRWW2ocY/+AfDzu1QQlTTl3dAddwlzYhjcsdckO6h45CXx2/p1sbnrg7D6Pl55x
# Dl8qTxhiYDKe0oNOKyJcaEWL3i+EEFCy+bUajWzuJZsT+MsQ14UO9IJ2czbGlXqi
# zGAG7AWwhjO3+JRbhEGEWIWUbrAfLEjMb5xD4GrofyaOawIDAQABo4IBKDCCASQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwgaIGA1UdAQSBmjCBl4AQW9Bw72lyniNRfhSy
# TY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQg
# Q29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMY
# TWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyIEdE+9mPs30AwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFG/oTj+XuTSrS4aPvJzqrDtBQ8bQMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MA0GCSqGSIb3DQEBBQUAA4IBAQCUTRExwnxQuxGOoWEHAQ6McEWN73NUvT8J
# BS3/uFFThRztOZG3o1YL3oy2OxvR+6ynybexUSEbbwhpfmsDoiJG7Wy0bXwiuEbT
# hPOND74HijbB637pcF1Fn5LSzM7djsDhvyrNfOzJrjLVh7nLY8Q20Rghv3beO5qz
# G3OeIYjYtLQSVIz0nMJlSpooJpxgig87xxNleEi7z62DOk+wYljeMOnpOR3jifLa
# OYH5EyGMZIBjBgSW8poCQy97Roi6/wLZZflK3toDdJOzBW4MzJ3cKGF8SPEXnBEh
# OAIch6wGxZYyuOVAxlM9vamJ3uhmN430IpaczLB3VFE61nJEsiP2MYIElzCCBJMC
# AQEwgYcweTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEG
# A1UEAxMaTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0ECCmEPeE0AAAAAAAMwCQYF
# Kw4DAhoFAKCBwjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUwrJOCiZbmqYvhTqN
# U/rn/uZJUwIwYgYKKwYBBAGCNwIBDDFUMFKgNIAyAE0AaQBjAHIAbwBzAG8AZgB0
# ACAARQB4AGMAaABhAG4AZwBlACAAUwBjAHIAaQBwAHShGoAYaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIBAJ6RSOY0/nOTQGT5MWRrSC0X
# Qpgnete8Erp1/EMM/RorKpxyys3XRR+5PSJJqsFom2hPKcao0eXP+95qsfuE+8e7
# OdWcwlvrGVwX+k4OQ+9fydSW6QfPkZwf+OYjXFF3qbdDFOATPRVvtzrNLA/fYbse
# 7oYP293JAx0eL5Gj8jtPLCDhkB4QjHYAY2AqDxOyGzCqKHjNtx/C9qp8wS2yiZe7
# lBJiSoR11l8bvdh4ensapitw/MK+d/wahVsySxq14gJWNYr8/NcLLduCz/jO0FsY
# fHKXCYvjl4SorQ+BflZe10rIPuTON2AY68u0O+P1Fch7HUm0KPhORBBedLOm0uWh
# ggIfMIICGwYJKoZIhvcNAQkGMYICDDCCAggCAQEwgYcweTELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IFRpbWVz
# dGFtcGluZyBQQ0ECCmEULKcAAAAAAAYwBwYFKw4DAhqgXTAYBgkqhkiG9w0BCQMx
# CwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0wNzA5MTIyMDIzMTNaMCMGCSqG
# SIb3DQEJBDEWBBRaPYCqmJK/Axk5PvuAE8uP0SurSDANBgkqhkiG9w0BAQUFAASC
# AQAQ069CNARp+4IPzHt/mhyZ19QFG6Vpcwmsl/slPZ5DETFt3b7g90ElCRo9Zw/S
# u0k4RLiHkFoMLnmnryysF8BgJYhDhX8NgY9CGSW31loNt/HB1NTjeu5cYRfJed26
# gyr4JKSEMwwPeq/Evb1eSARMfLpJOemXQYwZgZEvxXXLBtQGozHUEiHnQoAKWR3q
# 5ZfqXy7eMrTB1pRdsReykqkjiULoD3jmFHzCuEBuhxH+E5oIjPfyUvb8pJreaFbN
# 7EK85QSn/7PYVEkfNGbdv2U2QLrBEJaX5Y/MEkYpeRkTSD0bdRjUNxtz5rbp0DdM
# KpfRwtQO/bPu5Tpcup2MUF/x
# SIG # End signature block





















