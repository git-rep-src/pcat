# os:0
# raw:0
# one:1
# out:1
param
(
    [Parameter(Mandatory=$True,Position=1)] [string] $FILE,
    [Parameter(Mandatory=$True,Position=2)] [string] $FILEPATH
)
$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$PSV = ([int]$PsVersionTable.PsVersion.Major) 
$TMP = ""
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
xml "OPEN" "DATA type='cp' name='cp'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "CP"
    xml "FILEPATH" $FILEPATH
    $TMP = (Get-Content $FILE -Encoding UTF8 -Raw)
    if ($TMP -ne "" -and $TMP -ne $null -and $? -eq "True") {
        $RET = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($TMP))
    }
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "SRC" $RET
    } else {
        xml "STATUS" "FAIL"
    }
    xml "CLOSE" "CP"
} else {
    xml "OPEN" "NULL"
    xml "NONE" "Powershell is not installed or version is not compatible"
    xml "CLOSE" "NULL"
}
xml "CLOSE" "DATA"
echo "$BUF [CMD-EOF]"
