$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$global:BUF = ""
$RET = ""
$PSV = ([int]$PsVersionTable.PsVersion.Major) 
$TMP = "" 
$LIST_FOLDERS = "\repair\SAM", "\repair\system", "\System32\config\SAM", "\System32\config\SYSTEM", "\System32\config\RegBack\SAM", "\System32\config\RegBack\SYSTEM" 
$PROGRAMS_FOLDERS =  "C:\Program Files\*", "C:\Program Files (x86)\*"
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
xml "OPEN" "DATA name='pe' maxlen='16'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "FILES"
    foreach ($FOLDER in $LIST_FOLDERS) {
        $RET = (Test-Path $Env:WINDIR$FOLDER)
        if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
            $TMP += "$Env:WINDIR$FOLDER"+": Yes`n" 
        } else {
            $TMP += "$Env:WINDIR$FOLDER"+": No`n"
        }
    }
    xml "LIST" $TMP
    $TMP = ""
    foreach ($FOLDER in $PROGRAMS_FOLDERS) {
        $RET = (Get-ChildItem $FOLDER | % {try{Get-Acl $_ -EA SilentlyContinue | Where {($_.Access | select -ExpandProperty IdentityReference) -match "Everyone"}} catch {}} | Format-Table -Hidetableheaders -Property Path | Out-String)
        if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
            $TMP += $RET 
        } else {
            $TMP += "$FOLDER"+": No`n"
        }
    }
    xml "EVERYONE" $TMP
    xml "CLOSE" "FILES"
    xml "OPEN" "PROGRAMS"
    $RET = (Test-Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Installer")
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "INSTALL-ELEVATED" "Yes"
    } else {
        xml "INSTALL-ELEVATED" "No"
    }
    xml "CLOSE" "PROGRAMS"
    xml "OPEN" "SERVICES"
    $RET = (Get-CimInstance Win32_StartupCommand | select Command, User | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "STARTUP" $RET
    } else {
        xml "STARTUP" "N/A"
    }
    $RET = (Get-CimInstance Win32_Service -Property Name, DisplayName, PathName, StartMode | Where {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows*" -and $_.PathName -notlike '"*'} | select PathName, DisplayName, Name | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "UNQUOTED" $RET
    } else {
        xml "UNQUOTED" "No"
    }
    xml "CLOSE" "SERVICES"
}
echo $BUF
