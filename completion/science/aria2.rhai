// aria2c 1.37.0, from `aria2c --help=#all`. The arguments are URIs, or torrent and metalink files.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn spec(cmd) {
    #{
        opts: `
            -v, --version                                 print the version number and exit
            -h, --help[=TAG|KEYWORD]                      print usage and exit
            -t, --timeout SEC                             set timeout in seconds
            --connect-timeout SEC                         set the connect timeout in seconds to establish
            -m, --max-tries N                             set number of tries
            --auto-save-interval SEC                      save a control file(*.aria2) every SEC seconds
            -l, --log LOG                                 the file name of the log file
            -d, --dir DIR                                 the directory to store the downloaded file
            -o, --out FILE                                the file name of the downloaded file
            -s, --split N                                 download a file using N connections
            -D, --daemon[=BOOL]                           run as daemon
            --referer REFERER                             set an http referrrer (Referer)
            --lowest-speed-limit SPEED                    close connection if download speed is lower than
            --piece-length LENGTH                         set a piece length for HTTP/FTP downloads
            --max-overall-download-limit SPEED            set max overall download speed in bytes/sec
            --max-download-limit SPEED                    set max download speed per each download in
            --file-allocation METHOD                      specify file allocation method
            --no-file-allocation-limit SIZE               no file allocation is made for files whose
            --allow-overwrite[=BOOL]                      restart download from scratch if the
            --realtime-chunk-checksum[=BOOL]              validate chunk of data by calculating
            -V, --check-integrity[=BOOL]                  check file integrity by validating piece
            --netrc-path FILE                             specify the path to the netrc file
            -c, --continue[=BOOL]                         continue downloading a partially downloaded
            -n, --no-netrc[=BOOL]                         disables netrc support
            -i, --input-file FILE                         downloads URIs found in FILE. You can specify
            --deferred-input[=BOOL]                       if true is given, aria2 does not read all URIs
            -j, --max-concurrent-downloads N              set maximum number of parallel downloads for
            --optimize-concurrent-downloads[=true|false|A:B]  optimizes the number of
            -Z, --force-sequential[=BOOL]                 fetch URIs in the command-line sequentially
            --auto-file-renaming[=BOOL]                   rename file name if the same file already
            -P, --parameterized-uri[=BOOL]                enable parameterized URI support
            --allow-piece-length-change[=BOOL]            if false is given, aria2 aborts
            --no-conf[=BOOL]                              disable loading aria2.conf file
            --conf-path PATH                              change the configuration file path to PATH
            --stop SEC                                    stop application after SEC seconds has passed
            -q, --quiet[=BOOL]                            make aria2 quiet(no console output)
            --async-dns[=BOOL]                            enable asynchronous DNS
            --summary-interval SEC                        set interval to output download progress summary
            --log-level LEVEL                             set log level to output to file specified using
            --console-log-level LEVEL                     set log level to output to console
            --uri-selector SELECTOR                       specify URI selection algorithm
            --server-stat-timeout SEC                     specifies timeout in seconds to invalidate
            --server-stat-if FILE                         specify the filename to load performance profile
            --server-stat-of FILE                         specify the filename to which performance profile
            -R, --remote-time[=BOOL]                      retrieve timestamp of the remote file from the
            --max-file-not-found NUM                      if aria2 receives 'file not found' status from the
            --event-poll POLL                             specify the method for polling events
            --enable-rpc[=BOOL]                           enable JSON-RPC/XML-RPC server
            --rpc-listen-port PORT                        specify a port number for JSON-RPC/XML-RPC server
            --rpc-user USER                               set JSON-RPC/XML-RPC user
            --rpc-passwd PASSWD                           set JSON-RPC/XML-RPC password
            --rpc-max-request-size SIZE                   set max size of JSON-RPC/XML-RPC request
            --rpc-listen-all[=BOOL]                       listen incoming JSON-RPC/XML-RPC requests on all
            --rpc-allow-origin-all[=BOOL]                 add Access-Control-Allow-Origin header
            --rpc-certificate FILE                        use the certificate in FILE for RPC server
            --rpc-private-key FILE                        use the private key in FILE for RPC server
            --rpc-secure[=BOOL]                           RPC transport will be encrypted by SSL/TLS
            --rpc-save-upload-metadata[=BOOL]             save the uploaded torrent or
            --dry-run[=BOOL]                              if true is given, aria2 just checks whether the
            --reuse-uri[=BOOL]                            reuse already used URIs if no unused URIs are
            --on-download-start COMMAND                   set the command to be executed after download
            --on-download-pause COMMAND                   set the command to be executed after download
            --on-download-stop COMMAND                    set the command to be executed after download
            --on-download-complete COMMAND                set the command to be executed after download
            --on-download-error COMMAND                   set the command to be executed after download
            --interface INTERFACE                         bind sockets to given interface
            --multiple-interface INTERFACES               comma separated list of interfaces to bind
            --disable-ipv6[=BOOL]                         disable IPv6
            --human-readable[=BOOL]                       print sizes and speed in human readable format
            --remove-control-file[=BOOL]                  remove control file before download
            --always-resume[=BOOL]                        always resume download
            --max-resume-failure-tries N                  when used with --always-resume=false, aria2
            --save-session FILE                           save error/unfinished downloads to FILE on exit
            -x, --max-connection-per-server NUM           the maximum number of connections to one
            -k, --min-split-size SIZE                     aria2 does not split less than 2*SIZE byte range
            --conditional-get[=BOOL]                      download file only when the local file is older
            --enable-async-dns6[=BOOL]                    enable IPv6 name resolution in asynchronous
            --max-download-result NUM                     set maximum number of download result kept in
            --retry-wait SEC                              set the seconds to wait between retries
            --async-dns-server IPADDRESS[,...]            comma separated list of DNS server address
            --show-console-readout[=BOOL]                 show console readout
            --stream-piece-selector SELECTOR              specify piece selection algorithm
            --truncate-console-readout[=BOOL]             truncate console readout to fit in
            --pause[=BOOL]                                pause download after added
            --download-result OPT                         this option changes the way "Download Results"
            --hash-check-only[=BOOL]                      if true is given, after hash check using
            --checksum TYPE=DIGEST                        set checksum
            --stop-with-process PID                       stop application when process PID is not running
            --enable-mmap[=BOOL]                          map files into memory
            --force-save[=BOOL]                           save download with --save-session option even
            --save-not-found[=BOOL]                       save download with --save-session option even
            --disk-cache SIZE                             enable disk cache
            --gid GID                                     set GID manually
            --save-session-interval SEC                   save error/unfinished downloads to a file
            --enable-color[=BOOL]                         enable color output for a terminal
            --rpc-secret TOKEN                            set RPC secret authorization token
            --dscp DSCP                                   set DSCP value in outgoing IP packets of
            --pause-metadata[=BOOL]                       pause downloads created as a result of metadata
            --rlimit-nofile NUM                           set the soft limit of open file descriptors
            --min-tls-version VERSION                     specify minimum SSL/TLS version to enable
            --socket-recv-buffer-size SIZE                set the maximum socket receive buffer in bytes
            --max-mmap-limit SIZE                         set the maximum file size to enable mmap
            --stderr[=BOOL]                               redirect all console output that would be
            --keep-unfinished-download-result[=BOOL]      keep unfinished download results even if doing
            --ftp-user USER                               set FTP user
            --ftp-passwd PASSWD                           set FTP password
            --ftp-type TYPE                               set FTP transfer type
            -p, --ftp-pasv[=BOOL]                         use the passive mode in FTP. If false is given
            --ftp-reuse-connection[=BOOL]                 reuse connection in FTP
            --ssh-host-key-md TYPE=DIGEST                 set checksum for SSH host public key
            --http-user USER                              set HTTP user
            --http-passwd PASSWD                          set HTTP password
            -U, --user-agent USER_AGENT                   set user agent for http(s) downloads
            --load-cookies FILE                           load Cookies from FILE using the Firefox3 format
            --save-cookies FILE                           save Cookies to FILE in Mozilla/Firefox(1.x/2.x)/
            --enable-http-keep-alive[=BOOL]               enable HTTP/1.1 persistent connection
            --enable-http-pipelining[=BOOL]               enable HTTP/1.1 pipelining
            --header HEADER                               append HEADER to HTTP request header
            --certificate FILE                            use the client certificate in FILE
            --private-key FILE                            use the private key in FILE
            --ca-certificate FILE                         use the certificate authorities in FILE to verify
            --check-certificate[=BOOL]                    verify the peer using certificates specified
            --use-head[=BOOL]                             use HEAD method for the first request to the HTTP
            --http-auth-challenge[=BOOL]                  send HTTP authorization header only when it
            --http-no-cache[=BOOL]                        send Cache-Control: no-cache and Pragma: no-cache
            --http-accept-gzip[=BOOL]                     send 'Accept-Encoding: deflate, gzip' request
            --content-disposition-default-utf8[=BOOL]     handle quoted string in
            --no-want-digest-header[=BOOL]                whether to disable Want-Digest header
            --http-proxy PROXY                            use a proxy server for HTTP. To override a
            --https-proxy PROXY                           use a proxy server for HTTPS. To override a
            --ftp-proxy PROXY                             use a proxy server for FTP. To override a
            --all-proxy PROXY                             use a proxy server for all protocols
            --no-proxy DOMAINS                            specify comma separated hostnames, domains or
            --proxy-method METHOD                         set the method to use in proxy request
            --http-proxy-user USER                        set user for --http-proxy
            --http-proxy-passwd PASSWD                    set password for --http-proxy
            --https-proxy-user USER                       set user for --https-proxy
            --https-proxy-passwd PASSWD                   set password for --https-proxy
            --ftp-proxy-user USER                         set user for --ftp-proxy
            --ftp-proxy-passwd PASSWD                     set password for --ftp-proxy
            --all-proxy-user USER                         set user for --all-proxy
            --all-proxy-passwd PASSWD                     set password for --all-proxy
            -S, --show-files[=BOOL]                       print file listing of .torrent, .meta4 and
            --max-overall-upload-limit SPEED              set max overall upload speed in bytes/sec
            -u, --max-upload-limit SPEED                  set max upload speed per each torrent in
            -T, --torrent-file TORRENT_FILE               the path to the .torrent file
            --listen-port PORT...                         set TCP port number for BitTorrent downloads
            --follow-torrent true|false|mem               if true or mem is specified, when a file
            --select-file INDEX...                        set file to download by specifying its index
            --seed-time MINUTES                           specify seeding time in (fractional) minutes
            --seed-ratio RATIO                            specify share ratio
            --peer-id-prefix PEER_ID_PREFIX               specify the prefix of peer ID. The peer ID in
            --peer-agent PEER_AGENT                       set client reported during Extended torrent handshakes
            --enable-peer-exchange[=BOOL]                 enable Peer Exchange extension
            --enable-dht[=BOOL]                           enable IPv4 DHT functionality
            --dht-listen-port PORT...                     set UDP listening port used by DHT(IPv4, IPv6)
            --dht-entry-point HOST:PORT                   set host and port as an entry point to IPv4 DHT
            --dht-file-path PATH                          change the IPv4 DHT routing table file to PATH
            --enable-dht6[=BOOL]                          enable IPv6 DHT functionality
            --dht-listen-addr6 ADDR                       specify address to bind socket for IPv6 DHT
            --dht-entry-point6 HOST:PORT                  set host and port as an entry point to IPv6 DHT
            --dht-file-path6 PATH                         change the IPv6 DHT routing table file to PATH
            --bt-min-crypto-level plain|arc4              set minimum level of encryption method
            --bt-require-crypto[=BOOL]                    if true is given, aria2 doesn't accept and
            --bt-request-peer-speed-limit SPEED           if the whole download speed of every
            --bt-max-open-files NUM                       specify maximum number of files to open in
            --bt-seed-unverified[=BOOL]                   seed previously downloaded files without
            --bt-hash-check-seed[=BOOL]                   if true is given, after hash check using
            --bt-max-peers NUM                            specify the maximum number of peers per torrent
            --bt-external-ip IPADDRESS                    specify the external IP address to use in
            -O, --index-out INDEX=PATH                    set file path for file with index=INDEX. You can
            --bt-tracker-interval SEC                     set the interval in seconds between tracker
            --bt-stop-timeout SEC                         stop BitTorrent download if download speed is 0 in
            --bt-prioritize-piece head[=SIZE],tail[=SIZE]  try to download first and last
            --bt-save-metadata[=BOOL]                     save metadata as .torrent file
            --bt-metadata-only[=BOOL]                     download metadata only
            --bt-enable-lpd[=BOOL]                        enable Local Peer Discovery
            --bt-lpd-interface INTERFACE                  use given interface for Local Peer Discovery
            --bt-tracker-timeout SEC                      set timeout in seconds
            --bt-tracker-connect-timeout SEC              set the connect timeout in seconds to
            --dht-message-timeout SEC                     set timeout in seconds
            --on-bt-download-complete COMMAND             for BitTorrent, a command specified in
            --bt-tracker URI[,...]                        comma separated list of additional BitTorrent
            --bt-exclude-tracker URI[,...]                comma separated list of BitTorrent tracker's
            --bt-remove-unselected-file[=BOOL]            removes the unselected files when
            --bt-detach-seed-only[=BOOL]                  exclude seed only downloads when counting
            --bt-force-encryption[=BOOL]                  requires BitTorrent message payload encryption
            --bt-enable-hook-after-hash-check[=BOOL]      allow hook command invocation
            --bt-load-saved-metadata[=BOOL]               before getting torrent metadata from DHT when
            -M, --metalink-file METALINK_FILE             the file path to the .meta4 and .metalink
            --metalink-version VERSION                    the version of the file to download
            --metalink-language LANGUAGE                  the language of the file to download
            --metalink-os OS                              the operating system of the file to download
            --metalink-location LOCATION[,...]            the location of the preferred server
            --follow-metalink true|false|mem              if true or mem is specified, when a file
            --metalink-preferred-protocol PROTO           specify preferred protocol
            --metalink-enable-unique-protocol[=BOOL]      if true is given and several
            --metalink-base-uri URI                       specify base URI to resolve relative URI in
        `,
        values: #{
            "-h": "none", "--help": "none", "-t": "none", "--timeout": "none", "--connect-timeout": "none",
            "-m": "none", "--max-tries": "none", "--auto-save-interval": "none", "-l": "files", "--log": "files",
            "-d": "dirs", "--dir": "dirs", "-o": "files", "--out": "files", "-s": "none", "--split": "none",
            "-D": ["true", "false"], "--daemon": ["true", "false"], "--referer": "none",
            "--lowest-speed-limit": "none", "--piece-length": "none", "--max-overall-download-limit": "none",
            "--max-download-limit": "none", "--file-allocation": ["none", "prealloc", "trunc", "falloc"],
            "--no-file-allocation-limit": "none", "--allow-overwrite": ["true", "false"],
            "--realtime-chunk-checksum": ["true", "false"], "-V": ["true", "false"],
            "--check-integrity": ["true", "false"], "--netrc-path": "files", "-c": ["true", "false"],
            "--continue": ["true", "false"], "-n": ["true", "false"], "--no-netrc": ["true", "false"],
            "-i": "files", "--input-file": "files", "--deferred-input": ["true", "false"], "-j": "none",
            "--max-concurrent-downloads": "none", "--optimize-concurrent-downloads": "none",
            "-Z": ["true", "false"], "--force-sequential": ["true", "false"],
            "--auto-file-renaming": ["true", "false"], "-P": ["true", "false"],
            "--parameterized-uri": ["true", "false"], "--allow-piece-length-change": ["true", "false"],
            "--no-conf": ["true", "false"], "--conf-path": "files", "--stop": "none", "-q": ["true", "false"],
            "--quiet": ["true", "false"], "--async-dns": ["true", "false"], "--summary-interval": "none",
            "--log-level": ["debug", "info", "notice", "warn", "error"],
            "--console-log-level": ["debug", "info", "notice", "warn", "error"],
            "--uri-selector": ["inorder", "feedback", "adaptive"], "--server-stat-timeout": "none",
            "--server-stat-if": "files", "--server-stat-of": "files", "-R": ["true", "false"],
            "--remote-time": ["true", "false"], "--max-file-not-found": "none",
            "--event-poll": ["epoll", "poll", "select"], "--enable-rpc": ["true", "false"],
            "--rpc-listen-port": "none", "--rpc-user": "none", "--rpc-passwd": "none",
            "--rpc-max-request-size": "none", "--rpc-listen-all": ["true", "false"],
            "--rpc-allow-origin-all": ["true", "false"], "--rpc-certificate": "files",
            "--rpc-private-key": "files", "--rpc-secure": ["true", "false"],
            "--rpc-save-upload-metadata": ["true", "false"], "--dry-run": ["true", "false"],
            "--reuse-uri": ["true", "false"], "--on-download-start": "files", "--on-download-pause": "files",
            "--on-download-stop": "files", "--on-download-complete": "files", "--on-download-error": "files",
            "--interface": "none", "--multiple-interface": "none", "--disable-ipv6": ["true", "false"],
            "--human-readable": ["true", "false"], "--remove-control-file": ["true", "false"],
            "--always-resume": ["true", "false"], "--max-resume-failure-tries": "none", "--save-session": "files",
            "-x": "none", "--max-connection-per-server": "none", "-k": "none", "--min-split-size": "none",
            "--conditional-get": ["true", "false"], "--enable-async-dns6": ["true", "false"],
            "--max-download-result": "none", "--retry-wait": "none", "--async-dns-server": "none",
            "--show-console-readout": ["true", "false"],
            "--stream-piece-selector": ["default", "inorder", "random", "geom"],
            "--truncate-console-readout": ["true", "false"], "--pause": ["true", "false"],
            "--download-result": ["default", "full", "hide"], "--hash-check-only": ["true", "false"],
            "--checksum": "none", "--stop-with-process": "none", "--enable-mmap": ["true", "false"],
            "--force-save": ["true", "false"], "--save-not-found": ["true", "false"], "--disk-cache": "none",
            "--gid": "none", "--save-session-interval": "none", "--enable-color": ["true", "false"],
            "--rpc-secret": "none", "--dscp": "none", "--pause-metadata": ["true", "false"],
            "--rlimit-nofile": "none", "--min-tls-version": ["TLSv1.1", "TLSv1.2", "TLSv1.3"],
            "--socket-recv-buffer-size": "none", "--max-mmap-limit": "none", "--stderr": ["true", "false"],
            "--keep-unfinished-download-result": ["true", "false"], "--ftp-user": "none", "--ftp-passwd": "none",
            "--ftp-type": ["binary", "ascii"], "-p": ["true", "false"], "--ftp-pasv": ["true", "false"],
            "--ftp-reuse-connection": ["true", "false"], "--ssh-host-key-md": "none", "--http-user": "none",
            "--http-passwd": "none", "-U": "none", "--user-agent": "none", "--load-cookies": "files",
            "--save-cookies": "files", "--enable-http-keep-alive": ["true", "false"],
            "--enable-http-pipelining": ["true", "false"], "--header": "none", "--certificate": "files",
            "--private-key": "files", "--ca-certificate": "files", "--check-certificate": ["true", "false"],
            "--use-head": ["true", "false"], "--http-auth-challenge": ["true", "false"],
            "--http-no-cache": ["true", "false"], "--http-accept-gzip": ["true", "false"],
            "--content-disposition-default-utf8": ["true", "false"], "--no-want-digest-header": ["true", "false"],
            "--http-proxy": "none", "--https-proxy": "none", "--ftp-proxy": "none", "--all-proxy": "none",
            "--no-proxy": "none", "--proxy-method": ["get", "tunnel"], "--http-proxy-user": "none",
            "--http-proxy-passwd": "none", "--https-proxy-user": "none", "--https-proxy-passwd": "none",
            "--ftp-proxy-user": "none", "--ftp-proxy-passwd": "none", "--all-proxy-user": "none",
            "--all-proxy-passwd": "none", "-S": ["true", "false"], "--show-files": ["true", "false"],
            "--max-overall-upload-limit": "none", "-u": "none", "--max-upload-limit": "none",
            "-T": own("kinds:torrent"), "--torrent-file": own("kinds:torrent"), "--listen-port": "none",
            "--follow-torrent": ["true", "mem", "false"], "--select-file": "none", "--seed-time": "none",
            "--seed-ratio": "none", "--peer-id-prefix": "none", "--peer-agent": "none",
            "--enable-peer-exchange": ["true", "false"], "--enable-dht": ["true", "false"],
            "--dht-listen-port": "none", "--dht-entry-point": "none", "--dht-file-path": "files",
            "--enable-dht6": ["true", "false"], "--dht-listen-addr6": "none", "--dht-entry-point6": "none",
            "--dht-file-path6": "files", "--bt-min-crypto-level": ["plain", "arc4"],
            "--bt-require-crypto": ["true", "false"], "--bt-request-peer-speed-limit": "none",
            "--bt-max-open-files": "none", "--bt-seed-unverified": ["true", "false"],
            "--bt-hash-check-seed": ["true", "false"], "--bt-max-peers": "none", "--bt-external-ip": "none",
            "-O": "none", "--index-out": "none", "--bt-tracker-interval": "none", "--bt-stop-timeout": "none",
            "--bt-prioritize-piece": "none", "--bt-save-metadata": ["true", "false"],
            "--bt-metadata-only": ["true", "false"], "--bt-enable-lpd": ["true", "false"],
            "--bt-lpd-interface": "none", "--bt-tracker-timeout": "none", "--bt-tracker-connect-timeout": "none",
            "--dht-message-timeout": "none", "--on-bt-download-complete": "files", "--bt-tracker": "none",
            "--bt-exclude-tracker": "none", "--bt-remove-unselected-file": ["true", "false"],
            "--bt-detach-seed-only": ["true", "false"], "--bt-force-encryption": ["true", "false"],
            "--bt-enable-hook-after-hash-check": ["true", "false"], "--bt-load-saved-metadata": ["true", "false"],
            "-M": own("kinds:metalink"), "--metalink-file": own("kinds:metalink"), "--metalink-version": "none",
            "--metalink-language": "none", "--metalink-os": "none", "--metalink-location": "none",
            "--follow-metalink": ["true", "mem", "false"],
            "--metalink-preferred-protocol": ["http", "https", "ftp", "none"],
            "--metalink-enable-unique-protocol": ["true", "false"], "--metalink-base-uri": "none",
        },
        args: [own("kinds:aria2_input")],
    }
}
