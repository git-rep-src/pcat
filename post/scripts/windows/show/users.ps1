$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$global:BUF = ""
$RET = ""
$PSV = ([int]$PsVersionTable.PsVersion.Major) 
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
xml "OPEN" "DATA name='users' maxlen='8'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "EFFECTIVE"
    $RET = ($Env:UserName)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "NAME" $RET
    } else {
        xml "NAME" "N/A"
    }
    $RET = ((Get-CimInstance Win32_UserAccount -Filter "Name='$Env:UserName'").SID)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "SID" $RET
    } else {
        xml "SID" "N/A"
    }
    $RET = (net user $Env:UserName | Select-String "Local Group Memberships")
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        $RET = ($RET -replace 'Local Group Memberships', '' -replace '(^\s+|\s+$)', '' -replace '\s+', ' ' -replace '\*', '')
        xml "GROUP" $RET
    } else {
        xml "GROUP" "N/A"
    }
    $RET = ((Get-CimInstance Win32_UserAccount -Filter "Name='$Env:UserName'").PasswordRequired)
    if (($RET -ne "" -and $RET -ne $null -and $? -eq "True") -and ($RET -eq "True")) {
        xml "PASSWORD" "Yes"
    } else {
        xml "PASSWORD" "No"
    }
    $RET = ($Env:HomePath)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "HOME" $RET
    } else {
        xml "HOME" "N/A"
    }
    $RET = ($Env:Path)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "PATH" $RET
    } else {
        xml "PATH" "N/A"
    }
    $RET = (Get-ChildItem -Path Env:* | Sort-Object Name | Format-Table -Hidetableheaders -Wrap | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "ENV" $RET
    } else {
        xml "ENV" "N/A"
    }
    xml "CLOSE" "EFFECTIVE"
    $RET = ((Get-CimInstance Win32_UserAccount).Name | Foreach-Object {"<NAME>$_</NAME>"} | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "NORMAL" $RET
    } else {
        xml "OPEN" "NORMAL"
        xml "NONE" "N/A"
        xml "CLOSE" "NORMAL"
    }

    $RET = ((Get-CimInstance Win32_SystemAccount).Name | Foreach-Object {"<NAME>$_</NAME>"} | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "SYSTEM" $RET
    } else {
        xml "OPEN" "SYSTEM"
        xml "NONE" "N/A"
        xml "CLOSE" "SYSTEM"
    }
} 
echo "$BUF"
