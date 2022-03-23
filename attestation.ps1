<#
This script is created by ErnstGV for the benefit of SecAdmin Team. The aim is to get basic info such as hostname,
username, OS version, PC hardware make and installed AV and other applications as part of attestation process. The output can be verified by the user 
prior to submission to MISG. Use freely but ErnstGV will take no responsibility from any undesired effect. Thank you.
#>

$mytimestamp = Get-Date -Format "MMddyyyyHHmmss"    #timestamp generation

$shorthostname = hostname

$myfilename = $shorthostname + "_" + $mytimestamp+".txt"    #filename creation

$mytimeoutput = "Timestamp: " + $mytimestamp    #timestamp output

Write-Output $mytimeoutput | Out-File $myfilename   #output ti file and file creation file creation

function func_basic_info {

    $myhostname = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname   #to get the full DNS name of the pc

    $myhostname_output = "Hostname: " + $myhostname
    
    $myuser = $env:UserName    #to get the username
    
    $myuser_output = "Current User: " + $myuser
    
    $wmiQuery = "SELECT * FROM AntiVirusProduct"    #to get the Antivirus solution installed on the PC
    
    $antivirus_software = Get-WmiObject -Namespace "root\SecurityCenter2" -Query $wmiQuery | format-table @{L='AV Solution';E={$_.displayname}}

    $pcinfo = get-wmiobject win32_operatingsystem   #to get the OS version
    $mypcinfo_output = "Windows Version: " + $pcinfo.Caption + " " + "Build Number: " + $pcinfo.BuildNumber

    $mysysteminfo = get-wmiobject Win32_ComputerSystem

    $bios_serial_number = Get-WmiObject win32_bios | select-object -ExpandProperty Serialnumber | Out-string

    $mysysteminfo_output = "Manufacturer:" + $mysysteminfo.manufacturer + " Model " + $mysysteminfo.model + " Serial Number: " + $bios_serial_number

    

    Write-output $mypcinfo_output | Out-File $myfilename -Append
    Write-output $mysysteminfo_output | Out-File $myfilename -Append
    Write-output $myhostname_output | Out-File $myfilename -Append
    Write-output $myuser_output | Out-File $myfilename -Append
    Write-output $antivirus_software | Out-File $myfilename -Append
    Write-Output ""

}

function func_installed_app {

    # script for the function below came from https://blogs.technet.microsoft.com/heyscriptingguy/2011/11/13/use-powershell-to-quickly-find-installed-software/

    $array = @()

    $computername=$env:computerName

    #Define the variable to hold the location of Currently Installed Programs

    $UninstallKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 

    #Create an instance of the Registry Object and open the HKLM base key

    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername) 

    #Drill down into the Uninstall key using the OpenSubKey Method

    $regkey=$reg.OpenSubKey($UninstallKey) 

    #Retrieve an array of string that contain all the subkey names

    $subkeys=$regkey.GetSubKeyNames() 

    #Open each Subkey and use GetValue Method to return the required values for each

    foreach($key in $subkeys){

        $thisKey=$UninstallKey+"\\"+$key 

        $thisSubKey=$reg.OpenSubKey($thisKey)

        $obj = New-Object PSObject

        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $computername

        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))

        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))

        $obj | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))

        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))

        $obj | Add-Member -MemberType NoteProperty -Name "InstallDate" -Value $($thisSubKey.GetValue("InstallDate"))

        $array += $obj

    } 

$installed_applications = $array | Where-Object { $_.DisplayName } |Sort-Object installdate -desc | select-object InstallDate, DisplayName, Displayversion,Publisher 
 
Write-Output $installed_applications | Out-File $myfilename -Append

}

function func_hashinfo {

    $hashinfo_output = get-filehash $myfilename -Algorithm MD5  # Getting MD5 hash of the output file

    $outputfilepath = $hashinfo_output | Select-Object -ExpandProperty path

    $submission_steps = @"
    To OTS: Please take a quick screenshot of the hash output below and send to
    SecAdmin via email or TG group chat with the name of the user.


    To EndUser: Please fill up the form that will be provided by SecAdmin.

    In that same form, upload the generated output file in -> $outputfilepath. 

    Do not modify the contents of $myfilename. It will be counterchecked by SecAdmin i.e. MD5 hash.
"@ 

    Write-Host $submission_steps -ForegroundColor Green
    write-host ""

    Write-Host "-----------------------------------------------------BEGIN----------------------------------------------------------------"

    $hashinfo_output | Format-List path,hash | Out-String | ForEach-Object { $_.Trim() }

    Write-Host "------------------------------------------------------END-----------------------------------------------------------------"

}

func_basic_info

func_installed_app

func_hashinfo

