# os:0
# raw:0
# one:1
# out:1
param
(
    [Parameter(Mandatory=$True,Position=1)] [string] $NAME,
    [Parameter(Mandatory=$True,Position=2)] [string] $DIR
)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
$ProgressPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8
$PSV = ([int]$PsVersionTable.PsVersion.Major) 
$FILE = $DIR + "/file.zip"
$URL = ""
$global:BUF = ""
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
function unzip()
{
    $SHELL = new-object -com shell.application
    $ITEM = get-item $args[0]
    $DIR = $SHELL.namespace($args[1])
    $DIRZIP = $SHELL.namespace($ITEM.fullname)
    $DIR.Copyhere($DIRZIP.items())
}
xml "OPEN" "DATA type='get' name='get'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "GET"
    if ($NAME -like "tools") {
        $URL="https://github.com/git-rep-src/pcat-packages/blob/master/tools/windows/tools.zip?raw=true"
    } elseif ($NAME -like "exploits") {
        $URL="https://github.com/git-rep-src/pcat-packages/blob/master/exploits/windows/exploits.zip?raw=true"
    }
    if ($URL -ne "") {
        $(Invoke-WebRequest -UseBasicParsing -MaximumRedirection 100 -Uri $URL -OutFile $FILE)
        if ($? -eq "True") {
            $(unzip $FILE $DIR) 
            if ($? -eq "True") {
                xml "STATUS" "SUCCESS"
            } else {
                xml "STATUS" "FAIL"
            }
            $(Remove-Item $FILE)
        } else {
            xml "STATUS" "FAIL"
        }
    } else {
        xml "STATUS" "FAIL"
    }
    xml "CLOSE" "GET"
} else {
    xml "OPEN" "NULL"
    xml "NONE" "Powershell is not installed or version is not compatible"
    xml "CLOSE" "NULL"
}
xml "CLOSE" "DATA"
echo "$BUF [CMD-EOF]"
