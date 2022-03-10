$mytimestamp = Get-Date -Format "MMddyyyyHHmmss"

$shorthostname = hostname

$myfilename = $shorthostname + "_" + $mytimestamp+".txt"

$mytimeoutput = "Timecheck: " + $mytimestamp

Write-Output $mytimeoutput | Out-File $myfilename

$myhostname = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname

$myhostname_output = "Hostname: " + $myhostname

$myuser = whoami

$myuser_output = "Current User: " + $myuser

$wmiQuery = "SELECT * FROM AntiVirusProduct"

$antivirus_software = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery | ft @{L=’AV Solution’;E={$_.displayname}}

$myav_software_output = "Antivirus" + $antivirus_software

#$bitlocker_status = (New-Object -ComObject Shell.Application).NameSpace('C:').Self.ExtendedProperty('System.Volume.BitLockerProtection')

#$bitlocker_status_output = "Bitlocker Status: " + $bitlocker_status

$pcinfo = get-wmiobject win32_operatingsystem

$mypcinfo_output = "Windows Version: " + $pcinfo.Caption + " " + "Build Number: " + $pcinfo.BuildNumber

$forencoding = $mytimestamp + $myhostname + $myuser
$forencoding

$encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($forencoding)
$encodedText = [System.Convert]::ToBase64String($encodedBytes)


$stringAsStream = [System.IO.MemoryStream]::new()
$writer = [System.IO.StreamWriter]::new($stringAsStream)
$writer.write($encodedText)
$writer.Flush()
$stringAsStream.Position = 0
$hashEncodedText = Get-FileHash -InputStream $stringAsStream | select Hash



Write-output $mypcinfo_output | Out-File $myfilename -Append
Write-output $myhostname_output | Out-File $myfilename -Append
Write-output $myuser_output | Out-File $myfilename -Append
Write-output $antivirus_software | Out-File $myfilename -Append
#Write-output $bitlocker_status_output | Out-File $myfilename -Append
Write-output $hashEncodedText | Out-File $myfilename -Append
Write-Output ""

Write-Host "Screenshot the hash output below and send to SecAdmin together with the file:"$myfilename
Write-Host "The hash will be verified in our end so pls do not change the content or rename"$myfilename
write-host ""
Write-Host "-----------------------------------------------------BEGIN----------------------------------------------------------------"

#Write-Host $forencoding
write-host $hashEncodedText

get-filehash $myfilename




Write-Host "------------------------------------------------------END-----------------------------------------------------------------"
