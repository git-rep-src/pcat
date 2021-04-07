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
function get_open_ports()
{
    $IP = ((Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress)
    $PORTS = "21", "22", "23", "25", "53", "80", "110", "143", "443", "993", "995", "8080" 
    $TMP = ""
    foreach ($PORT in $PORTS) {
        $Socket = New-Object Net.Sockets.TcpClient
        $ErrorActionPreference = 'SilentlyContinue'
        $Socket.Connect((Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress, $PORT)
        $ErrorActionPreference = 'Continue'
        if ($Socket.Connected) {
            $TMP += ("$IP"+":"+"$PORT (open)`n")
            $Socket.Close()
        }
        $Socket.Dispose()
        $Socket = $null
    }
    if ($TMP -ne "" -and $TMP -ne $null) {
        echo $TMP
    } else {
        echo "*:* (closed)"
    }
}
xml "OPEN" "DATA name='network' maxlen='7'"
if ($PSV -ne "" -and $PSV -ne $null -and $PSV -gt 2 -and $? -eq "True") {
    xml "OPEN" "PUBLIC"
    $RET = ((Invoke-WebRequest -UseBasicParsing -Uri "https://ipinfo.io/json").Content)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "IP" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property ip | Out-String)
        xml "CITY" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property city | Out-String)
        xml "REGION" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property region | Out-String)
        xml "COUNTRY" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property country | Out-String)
    } else {
        xml "IP" "N/A"
        xml "CITY" "N/A"
        xml "REGION" "N/A"
        xml "COUNTRY" "N/A"
    }
    xml "CLOSE" "PUBLIC"
    xml "OPEN" "LOCAL"
    $RET = ((Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "IP" $RET
    } else {
        xml "IP" "N/A"
    }
    $RET = get_open_ports
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "PORTS" $RET
    } else {
        xml "PORTS" "N/A"
    }
    $RET = ((Get-NetIPConfiguration).IPv4DefaultGateWay | Format-Table -Hidetableheaders -Property NextHop | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "GATEWAY" $RET
    } else {
        xml "GATEWAY" "N/A"
    }
    $RET = ((Get-NetIPConfiguration).DNSServer | Where-Object ServerAddresses -ne "{}" | Format-Table -Hidetableheaders -Property ServerAddresses | Out-String)
    if ($RET -ne "" -and $RET -ne $null -and $? -eq "True") {
        xml "DNS" ($RET -replace "[{}]")
    } else {
        xml "DNS" "N/A"
    }
    xml "CLOSE" "LOCAL"
}
echo "$BUF"
