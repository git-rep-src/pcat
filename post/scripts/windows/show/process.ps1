$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$global:BUF = ""
$RET = ""
$PSV = ([int]$PsVersionTable.PsVersion.Major)
$PROCS = ""
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
function get_process()
{
    Get-CimInstance Win32_Process | foreach {
        $OWNER = (Invoke-CimMethod -InputObject $PsItem -MethodName GetOwner)
        if ($OWNER.User -ne $null) {
            $PROC = $PsItem.Name
            $USER = $OWNER.User
            $global:PROCS += "$PROC ($USER)"+" `n"
        }
    }
}
xml "OPEN" "DATA name='process' maxlen='0'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "USERS"
    get_process
    if ($PROCS -ne "" -and $PROCS -ne $null -and $? -eq "True") {
        xml "NONE" $PROCS
    } else {
        xml "NONE" "N/A"
    }
    xml "CLOSE" "USERS"
    xml "OPEN" "SERVICES"
    $RET = (Get-CimInstance Win32_Service | Where-Object State -eq Running | Format-Table -Property Name, State, Status, StartMode | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "NONE" $RET
    } else {
        xml "NONE" "N/A"
    }
    xml "CLOSE" "SERVICES"
} else {
    xml "OPEN" "NULL"
    xml "NONE" "Powershell is not installed or version is not compatible"
    xml "CLOSE" "NULL"
}
xml "CLOSE" "DATA"
echo "$BUF [POST-EOS]"
