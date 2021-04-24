# PCAT

An extension of Ncat for pentesters: [video](https://streamable.com/oas5v)

It preserves all the features of Ncat and adds new ones, divided into two groups:

* **Pre**: work in progress.
* **Post**: enumeration, exploit manager and privilege escalation vector checking on Unix/Windows systems.

## INSTALLATION

```shell
libssl  (optional)
liblua  (optional/included)
libpcap (included)
libxml2
```
```shell
./configure
make
sudo make install

# BSD: use gmake instead of make.
# Windows: work in progress.
```
## USAGE

##### GENERAL

```shell
$ ./pcat --help
Pcat 0.1.0 ( https://gitlab.com/git-rep/pcat )
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
      --remote-os            Specify remote operating system ("bsd", "linux", "windows")
      --version              Display Pcat's version information and exit

See the pcat(1) manpage for full options, descriptions and usage examples
```
##### SESSION

```shell
post help

Usage: post <option> <arguments>

  set  os [bsd|linux|windows]                        set remote operating system
  show [system|users|process|network|pe|exploits]    show information
  run  tty                                           spawn tty shell
  pull [tools|exploits] <dir>                        download and install package
  doc  [iptables|ssh|sql|pe]                         show cheatsheet
  help                                               show help

  windows: cmd shell is mandatory
```
Pcat is based on source code of [Ncat](https://github.com/nmap/nmap)

Pcat use Linux exploits list of [Linux Exploit Suggester](https://github.com/mzet-/linux-exploit-suggester)
