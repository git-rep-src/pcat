# os:0
# raw:0
# one:0
# out:1
$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$PSV = ([int]$PsVersionTable.PsVersion.Major) 
$global:BUF = ""
$RET = ""
function xml()
{
    if ($args[0] -eq "OPEN") {
        $global:BUF += "<" + $args[1] + ">"
    } elseif ($args[0] -eq "CLOSE") {
        $global:BUF += "</" + $args[1] + ">"
    } else {
        $global:BUF += "<" + $args[0] + ">" + $args[1] + "</" + $args[0] + ">"
    }
}
xml "OPEN" "DATA type='show' name='system' namemax='6'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "HOST"
    $RET = ((Get-CimInstance Win32_OperatingSystem).CSName)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "NAME" $RET
    } else {
        xml "NAME" "N/A"
    }
    $RET = ((Get-CimInstance Win32_OperatingSystem).Caption)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "OS" $RET
    } else {
        xml "OS" "N/A"
    }
    $RET = ((Get-CimInstance Win32_OperatingSystem).BuildNumber)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "BUILD" $RET
    } else {
        xml "BUILD" "N/A"
    }
    $RET = ((Get-CimInstance Win32_OperatingSystem).ServicePackMajorVersion)
    if ($RET -ne $null -and $? -eq "True") {
        xml "SP" $RET
    } else {
        xml "SP" "N/A"
    }
    $RET = ((Get-CimInstance Win32_OperatingSystem).Version)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "KERNEL" $RET
    } else {
        xml "KERNEL" "N/A"
    }
    $RET = ((Get-CimInstance Win32_OperatingSystem).OSArchitecture)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        if ($RET -eq "32-bit") {
            xml "ARCH" "x86"
        } else {
            xml "ARCH" "x86_64"
        }
    } else {
        xml "ARCH" "N/A"
    }
    $RET = ((Get-CimInstance Win32_BaseBoard).Product)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        if ($RET -like "*virtualbox*") {
            xml "VBOX" "Yes"
        } else {
            xml "VBOX" "No"
        }
    } else {
        xml "VBOX" "N/A"
    }
    $RET = (Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object Name -eq cexecsvc | Format-Table -Hidetableheaders -Property Name | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "DOCKER" "Yes"
    } else {
        xml "DOCKER" "No"
    }
    $RET = ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "UPTIME" $RET
    } else {
        xml "UPTIME" "N/A"
    }
    xml "CLOSE" "HOST"
    xml "OPEN" "STORAGE"
    $RET = (Get-CimInstance Win32_LogicalDisk | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "ALL" $RET
    } else {
        xml "ALL" "N/A"
    }
    xml "CLOSE" "STORAGE"
}
echo "$BUF"
