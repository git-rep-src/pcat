# PCAT

An extension of Ncat for pentesters.

Pcat preserves all the features of Ncat and adds new ones: enumeration, privilege escalation vector checking, file manager and more on Unix/Windows systems.

## INSTALLATION

```shell
libssl  (optional)
liblua  (optional/included)
libpcap (included)
```
```shell
BSD:
./configure
gmake
gmake install

Linux:
./configure
make
make install

Windows:
Work in progress.
```
## USAGE

##### GENERAL

```shell
Pcat 0.1.0 ( https://github.com/git-rep-src/pcat )
Usage: pcat [options] [hostname] [port]

Options taking a time assume seconds. Append 'ms' for milliseconds,
's' for seconds, 'm' for minutes, or 'h' for hours (e.g. 500ms).
  -4                         Use IPv4 only
  -6                         Use IPv6 only
  -U, --unixsock             Use Unix domain sockets only
      --vsock                Use vsock sockets only
  -C, --crlf                 Use CRLF for EOL sequence
  -c, --sh-exec <command>    Executes the given command via /bin/sh
  -e, --exec <command>       Executes the given command
      --lua-exec <filename>  Executes the given Lua script
  -g hop1[,hop2,...]         Loose source routing hop points (8 max)
  -G <n>                     Loose source routing hop pointer (4, 8, 12, ...)
  -m, --max-conns <n>        Maximum <n> simultaneous connections
  -h, --help                 Display this help screen
  -d, --delay <time>         Wait between read/writes
  -o, --output <filename>    Dump session data to a file
  -x, --hex-dump <filename>  Dump session data as hex to a file
  -i, --idle-timeout <time>  Idle read/write timeout
  -p, --source-port port     Specify source port to use
  -s, --source addr          Specify source address to use (doesn't affect -l)
  -l, --listen               Bind and listen for incoming connections
  -k, --keep-open            Accept multiple connections in listen mode
  -n, --nodns                Do not resolve hostnames via DNS
  -t, --telnet               Answer Telnet negotiations
  -u, --udp                  Use UDP instead of default TCP
      --sctp                 Use SCTP instead of default TCP
  -v, --verbose              Set verbosity level (can be used several times)
  -w, --wait <time>          Connect timeout
  -z                         Zero-I/O mode, report connection status only
      --append-output        Append rather than clobber specified output files
      --send-only            Only send data, ignoring received; quit on EOF
      --recv-only            Only receive data, never send anything
      --no-shutdown          Continue half-duplex when receiving EOF on stdin
      --allow                Allow only given hosts to connect to Pcat
      --allowfile            A file of hosts allowed to connect to Pcat
      --deny                 Deny given hosts from connecting to Pcat
      --denyfile             A file of hosts denied from connecting to Pcat
      --broker               Enable Pcat's connection brokering mode
      --chat                 Start a simple Pcat chat server
      --proxy <addr[:port]>  Specify address of host to proxy through
      --proxy-type <type>    Specify proxy type ("http", "socks4", "socks5")
      --proxy-auth <auth>    Authenticate with HTTP or SOCKS proxy server
      --proxy-dns <type>     Specify where to resolve proxy destination
      --ssl                  Connect or listen with SSL
      --ssl-cert             Specify SSL certificate file (PEM) for listening
      --ssl-key              Specify SSL private key (PEM) for listening
      --ssl-verify           Verify trust and domain name of certificates
      --ssl-trustfile        PEM file containing trusted SSL certificates
      --ssl-ciphers          Cipherlist containing SSL ciphers to use
      --ssl-servername       Request distinct server name (SNI)
      --ssl-alpn             ALPN protocol list to use
      --version              Display Pcat's version information and exit
```
##### SESSION

```shell
post set  bsd|linux|windows                      set post on remote system memory
     show system|users|process|network|pe|cve    show information
     push FILE FILE                              copy local FILE to remote FILE (windows <= 4MB)
     pull FILE FILE                              copy remote FILE to local FILE
     put  tools DIR                              install static binaries package on DIR
          exploits DIR                           install exploit sources package on DIR
     help                                        show help

     Windows need a powershell reverse shell.
```
##### EXAMPLE

```shell
post show system

HOST
    NAME ............ host
    OS .............. GNU/Linux
    KERNEL .......... Linux 5.11.9-arch1-1
    ARCH ............ x86_64
    DISTRO .......... Arch Linux 
    INIT ............ Systemd
    RUNLEVEL ........ graphical.target
    VBOX ............ No
    DOCKER .......... No
    LXC ............. No
    UPTIME .......... up 1 hour, 56 minutes

STORAGE
    NAME      FSTYPE      FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINT   SIZE OWNER GROUP MODE
    sda                                                                                              321.3G root  disk  brw-rw----
    ├─sda1    ext2        1.0         0531bc2d-b6d6-493a-8fe7-e6634513dac1   44.9M    64% /boot        180M root  disk  brw-rw----
    ├─sda2    crypto_LUKS 1           bn873f84-7b98-4776-a6ce-e26d51fa0152                              30G root  disk  brw-rw----
    │ └─mmovt ext4        1.0         2bf99beb-f0b9-4b61-b62d-fa6e61096c96    7.1G    80% /             30G root  disk  brw-rw----
    ├─sda3    crypto_LUKS 1           0043a648-0355-4eb4-baf8-dc0df7a064ef                              60G root  disk  brw-rw----
    ├─sda4                                                                                               1K root  disk  brw-rw----
    └─sda5    crypto_LUKS 1           96653dcb-e813-432b-8ad5-ecr3b1bf95d4                           128.3G root  disk  brw-rw----

DEV
    GCC ............. /usr/bin/gcc
    PYTHON .......... /usr/bin/python
                      /usr/bin/python2
                      /usr/bin/python2.7
                      /usr/bin/python3
    PERL ............ /usr/bin/perl
    RUBY ............ /usr/bin/ruby

TOOLS
    WGET ............ /usr/bin/wget
    CURL ............ /usr/bin/curl
    GIT ............. /usr/bin/git
    FTP ............. /usr/bin/ftp
    TELNET .......... /usr/bin/telnet
    SSH ............. /usr/bin/ssh
                      /usr/bin/sshd
    NETCAT .......... /usr/bin/nc
                      /usr/bin/ncat
                      /usr/bin/netcat
    SOCAT ........... /usr/bin/socat
    TCPDUMP ......... /usr/bin/tcpdump
    NMAP ............ /usr/bin/nmap
    TAR ............. /usr/bin/tar
    VIM ............. /usr/bin/vim
    VI .............. /usr/bin/vi
```
Pcat is based on source code of [Ncat](https://github.com/nmap/nmap).
