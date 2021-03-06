/***************************************************************************
 * pcat_connect.c -- Pcat connect mode.                                    *
 ***********************IMPORTANT NMAP LICENSE TERMS************************
 *                                                                         *
 * The Nmap Security Scanner is (C) 1996-2019 Insecure.Com LLC ("The Nmap  *
 * Project"). Nmap is also a registered trademark of the Nmap Project.     *
 * This program is free software; you may redistribute and/or modify it    *
 * under the terms of the GNU General Public License as published by the   *
 * Free Software Foundation; Version 2 ("GPL"), BUT ONLY WITH ALL OF THE   *
 * CLARIFICATIONS AND EXCEPTIONS DESCRIBED HEREIN.  This guarantees your   *
 * right to use, modify, and redistribute this software under certain      *
 * conditions.  If you wish to embed Nmap technology into proprietary      *
 * software, we sell alternative licenses (contact sales@nmap.com).        *
 * Dozens of software vendors already license Nmap technology such as      *
 * host discovery, port scanning, OS detection, version detection, and     *
 * the Nmap Scripting Engine.                                              *
 *                                                                         *
 * Note that the GPL places important restrictions on "derivative works",  *
 * yet it does not provide a detailed definition of that term.  To avoid   *
 * misunderstandings, we interpret that term as broadly as copyright law   *
 * allows.  For example, we consider an application to constitute a        *
 * derivative work for the purpose of this license if it does any of the   *
 * following with any software or content covered by this license          *
 * ("Covered Software"):                                                   *
 *                                                                         *
 * o Integrates source code from Covered Software.                         *
 *                                                                         *
 * o Reads or includes copyrighted data files, such as Nmap's nmap-os-db   *
 * or nmap-service-probes.                                                 *
 *                                                                         *
 * o Is designed specifically to execute Covered Software and parse the    *
 * results (as opposed to typical shell or execution-menu apps, which will *
 * execute anything you tell them to).                                     *
 *                                                                         *
 * o Includes Covered Software in a proprietary executable installer.  The *
 * installers produced by InstallShield are an example of this.  Including *
 * Nmap with other software in compressed or archival form does not        *
 * trigger this provision, provided appropriate open source decompression  *
 * or de-archiving software is widely available for no charge.  For the    *
 * purposes of this license, an installer is considered to include Covered *
 * Software even if it actually retrieves a copy of Covered Software from  *
 * another source during runtime (such as by downloading it from the       *
 * Internet).                                                              *
 *                                                                         *
 * o Links (statically or dynamically) to a library which does any of the  *
 * above.                                                                  *
 *                                                                         *
 * o Executes a helper program, module, or script to do any of the above.  *
 *                                                                         *
 * This list is not exclusive, but is meant to clarify our interpretation  *
 * of derived works with some common examples.  Other people may interpret *
 * the plain GPL differently, so we consider this a special exception to   *
 * the GPL that we apply to Covered Software.  Works which meet any of     *
 * these conditions must conform to all of the terms of this license,      *
 * particularly including the GPL Section 3 requirements of providing      *
 * source code and allowing free redistribution of the work as a whole.    *
 *                                                                         *
 * As another special exception to the GPL terms, the Nmap Project grants  *
 * permission to link the code of this program with any version of the     *
 * OpenSSL library which is distributed under a license identical to that  *
 * listed in the included docs/licenses/OpenSSL.txt file, and distribute   *
 * linked combinations including the two.                                  *
 *                                                                         *
 * The Nmap Project has permission to redistribute Npcap, a packet         *
 * capturing driver and library for the Microsoft Windows platform.        *
 * Npcap is a separate work with it's own license rather than this Nmap    *
 * license.  Since the Npcap license does not permit redistribution        *
 * without special permission, our Nmap Windows binary packages which      *
 * contain Npcap may not be redistributed without special permission.      *
 *                                                                         *
 * Any redistribution of Covered Software, including any derived works,    *
 * must obey and carry forward all of the terms of this license, including *
 * obeying all GPL rules and restrictions.  For example, source code of    *
 * the whole work must be provided and free redistribution must be         *
 * allowed.  All GPL references to "this License", are to be treated as    *
 * including the terms and conditions of this license text as well.        *
 *                                                                         *
 * Because this license imposes special exceptions to the GPL, Covered     *
 * Work may not be combined (even as part of a larger work) with plain GPL *
 * software.  The terms, conditions, and exceptions of this license must   *
 * be included as well.  This license is incompatible with some other open *
 * source licenses as well.  In some cases we can relicense portions of    *
 * Nmap or grant special permissions to use it in other open source        *
 * software.  Please contact fyodor@nmap.org with any such requests.       *
 * Similarly, we don't incorporate incompatible open source software into  *
 * Covered Software without special permission from the copyright holders. *
 *                                                                         *
 * If you have any questions about the licensing restrictions on using     *
 * Nmap in other works, we are happy to help.  As mentioned above, we also *
 * offer an alternative license to integrate Nmap into proprietary         *
 * applications and appliances.  These contracts have been sold to dozens  *
 * of software vendors, and generally include a perpetual license as well  *
 * as providing support and updates.  They also fund the continued         *
 * development of Nmap.  Please email sales@nmap.com for further           *
 * information.                                                            *
 *                                                                         *
 * If you have received a written license agreement or contract for        *
 * Covered Software stating terms other than these, you may choose to use  *
 * and redistribute Covered Software under those terms instead of these.   *
 *                                                                         *
 * Source is provided to this software because we believe users have a     *
 * right to know exactly what a program is going to do before they run it. *
 * This also allows you to audit the software for security holes.          *
 *                                                                         *
 * Source code also allows you to port Nmap to new platforms, fix bugs,    *
 * and add new features.  You are highly encouraged to send your changes   *
 * to the dev@nmap.org mailing list for possible incorporation into the    *
 * main distribution.  By sending these changes to Fyodor or one of the    *
 * Insecure.Org development mailing lists, or checking them into the Nmap  *
 * source code repository, it is understood (unless you specify            *
 * otherwise) that you are offering the Nmap Project the unlimited,        *
 * non-exclusive right to reuse, modify, and relicense the code.  Nmap     *
 * will always be available Open Source, but this is important because     *
 * the inability to relicense code has caused devastating problems for     *
 * other Free Software projects (such as KDE and NASM).  We also           *
 * occasionally relicense the code to third parties as discussed above.    *
 * If you wish to specify special license conditions of your               *
 * contributions, just say so when you send them.                          *
 *                                                                         *
 * This program is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of              *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Nmap      *
 * license file for more details (it's in a COPYING file included with     *
 * Nmap, and also available from https://svn.nmap.org/nmap/COPYING)        *
 *                                                                         *
 ***************************************************************************/

/* $Id$ */

#include "base64.h"
#include "nsock.h"
#include "pcat.h"
#include "util.h"
#include "sys_wrap.h"

#include "nbase.h"
#include "http.h"
#include "post/post_input.h"
#include "post/post_output.h"

#ifndef WIN32
#include <unistd.h>
#include <netdb.h>
#endif
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#ifdef HAVE_OPENSSL
#include <openssl/ssl.h>
#include <openssl/err.h>
#endif

#ifdef WIN32
/* Define missing constant for shutdown(2).
 * See:
 * http://msdn.microsoft.com/en-us/library/windows/desktop/ms740481%28v=vs.85%29.aspx
 */
#define SHUT_WR SD_SEND
#endif

struct conn_state {
    nsock_iod sock_nsi;
    nsock_iod stdin_nsi;
    nsock_event_id idle_timer_event_id;
    int crlf_state;
};

static struct conn_state cs = {
    NULL,
    NULL,
    0,
    0
};

/* Post have output?. */
static int pout = 0;
/* Post buffer. */
static char *pbuf = NULL;

static void try_nsock_connect(nsock_pool nsp, struct sockaddr_list *conn_addr);
static void connect_handler(nsock_pool nsp, nsock_event evt, void *data);
static void post_connect(nsock_pool nsp, nsock_iod iod);
static void read_stdin_handler(nsock_pool nsp, nsock_event evt, void *data);
static void read_socket_handler(nsock_pool nsp, nsock_event evt, void *data);
static void write_socket_handler(nsock_pool nsp, nsock_event evt, void *data);
static void idle_timer_handler(nsock_pool nsp, nsock_event evt, void *data);
static void refresh_idle_timer(nsock_pool nsp);

#ifdef HAVE_OPENSSL
/* This callback is called for every certificate in a chain. ok is true if
   OpenSSL's internal verification has verified the certificate. We don't change
   anything about the verification, we only need access to the certificates to
   provide diagnostics. */
static int verify_callback(int ok, X509_STORE_CTX *store)
{
    X509 *cert = X509_STORE_CTX_get_current_cert(store);
    int err = X509_STORE_CTX_get_error(store);

    /* Print the subject, issuer, and fingerprint depending on the verbosity
       level. */
    if ((!ok && o.verbose) || o.debug > 1) {
        char digest_buf[SHA1_STRING_LENGTH + 1];
        char *fp;

        loguser("Subject: ");
        X509_NAME_print_ex_fp(stderr, X509_get_subject_name(cert), 0, XN_FLAG_COMPAT);
        loguser_noprefix("\n");
        loguser("Issuer: ");
        X509_NAME_print_ex_fp(stderr, X509_get_issuer_name(cert), 0, XN_FLAG_COMPAT);
        loguser_noprefix("\n");

        fp = ssl_cert_fp_str_sha1(cert, digest_buf, sizeof(digest_buf));
        pcat_assert(fp == digest_buf);
        loguser("SHA-1 fingerprint: %s\n", digest_buf);
    }

    if (!ok && o.verbose) {
        loguser("Certificate verification failed (%s).\n",
            X509_verify_cert_error_string(err));
    }

    return ok;
}

static void set_ssl_ctx_options(SSL_CTX *ctx)
{
    if (o.ssltrustfile == NULL) {
        ssl_load_default_ca_certs(ctx);
    } else {
        if (o.debug)
            logdebug("Using trusted CA certificates from %s.\n", o.ssltrustfile);
        if (SSL_CTX_load_verify_locations(ctx, o.ssltrustfile, NULL) != 1) {
            bye("Could not load trusted certificates from %s.\n%s",
                o.ssltrustfile, ERR_error_string(ERR_get_error(), NULL));
        }
    }

    if (o.sslverify) {
        SSL_CTX_set_verify(ctx, SSL_VERIFY_PEER, verify_callback);
    } else {
        /* Still check verification status and report it */
        SSL_CTX_set_verify(ctx, SSL_VERIFY_NONE, verify_callback);
        if (o.ssl && o.debug)
            logdebug("Not doing certificate verification.\n");
    }

    if (o.sslcert != NULL && o.sslkey != NULL) {
        if (SSL_CTX_use_certificate_file(ctx, o.sslcert, SSL_FILETYPE_PEM) != 1)
            bye("SSL_CTX_use_certificate_file(): %s.", ERR_error_string(ERR_get_error(), NULL));
        if (SSL_CTX_use_PrivateKey_file(ctx, o.sslkey, SSL_FILETYPE_PEM) != 1)
            bye("SSL_CTX_use_Privatekey_file(): %s.", ERR_error_string(ERR_get_error(), NULL));
    } else {
        if ((o.sslcert == NULL) != (o.sslkey == NULL))
            bye("The --ssl-key and --ssl-cert options must be used together.");
    }
    if (o.sslciphers == NULL) {
      if (!SSL_CTX_set_cipher_list(ctx, "ALL:!aNULL:!eNULL:!LOW:!EXP:!RC4:!MD5:@STRENGTH"))
        bye("Unable to set OpenSSL cipher list: %s", ERR_error_string(ERR_get_error(), NULL));
    }
    else {
      printf("setting ciphers: %s\n", o.sslciphers);
      if (!SSL_CTX_set_cipher_list(ctx, o.sslciphers))
        bye("Unable to set OpenSSL cipher list: %s", ERR_error_string(ERR_get_error(), NULL));
    }

#ifdef HAVE_ALPN_SUPPORT

    if (o.sslalpn) {
        size_t alpn_len;
        unsigned char *alpn = next_protos_parse(&alpn_len, o.sslalpn);

        if (alpn == NULL)
            bye("Could not parse ALPN string");

        if (o.debug)
            logdebug("Using ALPN String %s\n", o.sslalpn);

        /* SSL_CTX_set_alpn_protos returns 0 on success */
        if (SSL_CTX_set_alpn_protos(ctx, alpn, alpn_len) != 0){
            free(alpn);
            bye("SSL_CTX_set_alpn_protos: %s.", ERR_error_string(ERR_get_error(), NULL));
        }

        free(alpn);
    }

#endif

}
#endif

/* Depending on verbosity, print a message that a connection was established. */
static void connect_report(nsock_iod nsi)
{
    union sockaddr_u peer;
    zmem(&peer, sizeof(peer.storage));

    nsock_iod_get_communication_info(nsi, NULL, NULL, NULL, &peer.sockaddr,
                                     sizeof(peer.storage));
    if (o.verbose) {
#define connect_report_peer_str (o.proxytype ? o.target : inet_socktop(&peer))
#define connect_report_peer_port (o.proxytype ? o.portno : nsock_iod_get_peerport(nsi))
#ifdef HAVE_OPENSSL
        if (nsock_iod_check_ssl(nsi)) {
            X509 *cert;
            X509_NAME *subject;
            char digest_buf[SHA1_STRING_LENGTH + 1];
            char *fp;

            loguser("SSL connection to %s:%d.", connect_report_peer_str,
                    connect_report_peer_port);

            cert = SSL_get_peer_certificate((SSL *)nsock_iod_get_ssl(nsi));
            pcat_assert(cert != NULL);

            subject = X509_get_subject_name(cert);
            if (subject != NULL) {
                char buf[256];
                int n;

                n = X509_NAME_get_text_by_NID(subject, NID_organizationName, buf, sizeof(buf));
                if (n >= 0 && n <= sizeof(buf) - 1)
                    loguser_noprefix(" %s", buf);
            }

            loguser_noprefix("\n");

            fp = ssl_cert_fp_str_sha1(cert, digest_buf, sizeof(digest_buf));
            pcat_assert(fp == digest_buf);
            loguser("SHA-1 fingerprint: %s\n", digest_buf);
        } else {
#if HAVE_SYS_UN_H
            if (peer.sockaddr.sa_family == AF_UNIX)
                loguser("Connected to %s.\n", peer.un.sun_path);
            else
#endif
#ifdef HAVE_LINUX_VM_SOCKETS_H
            if (peer.sockaddr.sa_family == AF_VSOCK)
                loguser("Connection to %u.\n", peer.vm.svm_cid);
            else
#endif
                loguser("Connected to %s:%d.\n", connect_report_peer_str,
                        connect_report_peer_port);
        }
#else
#if HAVE_SYS_UN_H
        if (peer.sockaddr.sa_family == AF_UNIX)
            loguser("Connected to %s.\n", peer.un.sun_path);
        else
#endif
#ifdef HAVE_LINUX_VM_SOCKETS_H
        if (peer.sockaddr.sa_family == AF_VSOCK)
            loguser("Connection to %u.\n", peer.vm.svm_cid);
        else
#endif
            loguser("Connected to %s:%d.\n", connect_report_peer_str,
                    connect_report_peer_port);
#endif
    }
}

/* Just like inet_socktop, but it puts IPv6 addresses in square brackets. */
static const char *sock_to_url(char *host_str, unsigned short port)
{
    static char buf[512];

    switch(getaddrfamily(host_str)) {
       case -1:
       case 1:
           Snprintf(buf, sizeof(buf), "%s:%hu", host_str, port);
           break;
       case 2:
           Snprintf(buf, sizeof(buf), "[%s]:%hu", host_str, port);
    }

    return buf;
}

static int append_connect_request_line(char **buf, size_t *size, size_t *offset,
    char* host_str,unsigned short port)
{
    return strbuf_sprintf(buf, size, offset, "CONNECT %s HTTP/1.0\r\n",
        sock_to_url(host_str,port));
}

static char *http_connect_request(char* host_str, unsigned short port, int *n)
{
    char *buf = NULL;
    size_t size = 0, offset = 0;

    append_connect_request_line(&buf, &size, &offset, host_str, port);
    strbuf_append_str(&buf, &size, &offset, "\r\n");
    *n = offset;

    return buf;
}

static char *http_connect_request_auth(char* host_str, unsigned short port, int *n,
    struct http_challenge *challenge)
{
    char *buf = NULL;
    size_t size = 0, offset = 0;

    append_connect_request_line(&buf, &size, &offset, host_str, port);
    strbuf_append_str(&buf, &size, &offset, "Proxy-Authorization:");
    if (challenge->scheme == AUTH_BASIC) {
        char *auth_str;

        auth_str = b64enc((unsigned char *) o.proxy_auth, strlen(o.proxy_auth));
        strbuf_sprintf(&buf, &size, &offset, " Basic %s\r\n", auth_str);
        free(auth_str);
#if HAVE_HTTP_DIGEST
    } else if (challenge->scheme == AUTH_DIGEST) {
        char *proxy_auth;
        char *username, *password;
        char *response_hdr;

        /* Split up the proxy auth argument. */
        proxy_auth = Strdup(o.proxy_auth);
        username = proxy_auth;
        password = strchr(proxy_auth, ':');
        if (password == NULL) {
            free(proxy_auth);
            return NULL;
        }
        *password++ = '\0';
        response_hdr = http_digest_proxy_authorization(challenge,
            username, password, "CONNECT", sock_to_url(o.target,o.portno));
        if (response_hdr == NULL) {
            free(proxy_auth);
            return NULL;
        }
        strbuf_append_str(&buf, &size, &offset, response_hdr);
        free(proxy_auth);
        free(response_hdr);
#endif
    } else {
        bye("Unknown authentication type.");
    }
    strbuf_append_str(&buf, &size, &offset, "\r\n");
    *n = offset;

    return buf;
}

/* Return a usable socket descriptor after proxy negotiation, or -1 on any
   error. If any bytes are received through the proxy after negotiation, they
   are written to stdout. */
static int do_proxy_http(void)
{
    struct socket_buffer sockbuf;
    char *request;
    char *status_line, *header;
    char *remainder;
    size_t len;
    int sd, code;
    int n;
    char *target;
    union sockaddr_u addr;
    size_t sslen;
    void *addrbuf;
    char addrstr[INET6_ADDRSTRLEN];

    request = NULL;
    status_line = NULL;
    header = NULL;

    sd = do_connect(SOCK_STREAM);
    if (sd == -1) {
        loguser("Proxy connection failed: %s.\n", socket_strerror(socket_errno()));
        return -1;
    }

    if (proxyresolve(o.target, 0, &addr.storage, &sslen, o.af)) {
        /* target resolution has failed, possibly because it is disabled */
        if (!(o.proxydns & PROXYDNS_REMOTE)) {
            loguser("Error: Failed to resolve host %s locally.\n", o.target);
            goto bail;
        }
        if (o.verbose)
            loguser("Host %s will be resolved by the proxy.\n", o.target);
        target = o.target;
    } else {
        /* addr is now populated with either sockaddr_in or sockaddr_in6 */
        switch (addr.sockaddr.sa_family) {
            case AF_INET:
                addrbuf = &addr.in.sin_addr;
                break;
            case AF_INET6:
                addrbuf = &addr.in6.sin6_addr;
                break;
            default:
                pcat_assert(0);
        }
        inet_ntop(addr.sockaddr.sa_family, addrbuf, addrstr, sizeof(addrstr));
        target = addrstr;
        if (o.verbose && getaddrfamily(o.target) == -1)
            loguser("Host %s locally resolved to %s.\n", o.target, target);
    }

    /* First try a request with no authentication. */
    request = http_connect_request(target, o.portno, &n);
    if (send(sd, request, n, 0) < 0) {
        loguser("Error sending proxy request: %s.\n", socket_strerror(socket_errno()));
        goto bail;
    }
    free(request);
    request = NULL;

    socket_buffer_init(&sockbuf, sd);

    if (http_read_status_line(&sockbuf, &status_line) != 0) {
        loguser("Error reading proxy response Status-Line.\n");
        goto bail;
    }
    code = http_parse_status_line_code(status_line);
    if (o.debug)
      logdebug("Proxy returned status code %d.\n", code);
    free(status_line);
    status_line = NULL;
    if (http_read_header(&sockbuf, &header) != 0) {
        loguser("Error reading proxy response header.\n");
        goto bail;
    }

    if (code == 407 && o.proxy_auth != NULL) {
        struct http_header *h;
        struct http_challenge challenge;

        close(sd);
        sd = -1;

        if (http_parse_header(&h, header) != 0) {
            loguser("Error parsing proxy response header.\n");
            goto bail;
        }
        free(header);
        header = NULL;

        if (http_header_get_proxy_challenge(h, &challenge) == NULL) {
            loguser("Error getting Proxy-Authenticate challenge.\n");
            http_header_free(h);
            goto bail;
        }
        http_header_free(h);

        sd = do_connect(SOCK_STREAM);
        if (sd == -1) {
            loguser("Proxy reconnection failed: %s.\n", socket_strerror(socket_errno()));
            goto bail;
        }

        request = http_connect_request_auth(target, o.portno, &n, &challenge);
        if (request == NULL) {
            loguser("Error building Proxy-Authorization header.\n");
            http_challenge_free(&challenge);
            goto bail;
        }
        if (o.debug)
          logdebug("Reconnection header:\n%s", request);
        if (send(sd, request, n, 0) < 0) {
            loguser("Error sending proxy request: %s.\n", socket_strerror(socket_errno()));
            http_challenge_free(&challenge);
            goto bail;
        }
        free(request);
        request = NULL;
        http_challenge_free(&challenge);

        socket_buffer_init(&sockbuf, sd);

        if (http_read_status_line(&sockbuf, &status_line) != 0) {
            loguser("Error reading proxy response Status-Line.\n");
            goto bail;
        }
        code = http_parse_status_line_code(status_line);
        if (o.debug)
          logdebug("Proxy returned status code %d.\n", code);
        free(status_line);
        status_line = NULL;
        if (http_read_header(&sockbuf, &header) != 0) {
            loguser("Error reading proxy response header.\n");
            goto bail;
        }
    }

    if (code != 200) {
        loguser("Proxy returned status code %d.\n", code);
        goto bail;
    }

    free(header);
    header = NULL;

    remainder = socket_buffer_remainder(&sockbuf, &len);
    Write(STDOUT_FILENO, remainder, len);

    return sd;

bail:
    if (sd != -1)
        close(sd);
    if (request != NULL)
        free(request);
    if (status_line != NULL)
        free(status_line);
    if (header != NULL)
        free(header);

    return -1;
}


/* SOCKS4a support
 * Return a usable socket descriptor after
 * proxy negotiation, or -1 on any error.
 */
static int do_proxy_socks4(void)
{
    struct socket_buffer stateful_buf;
    char socksbuf[8];
    struct socks4_data socks4msg;
    size_t datalen;
    char *username = o.proxy_auth != NULL ? o.proxy_auth : "";
    union sockaddr_u addr;
    size_t sslen;
    int sd;

    if (getaddrfamily(o.target) == 2) {
        loguser("Error: IPv6 addresses are not supported with Socks4.\n");
        return -1;
    }

    sd = do_connect(SOCK_STREAM);
    if (sd == -1) {
        loguser("Proxy connection failed: %s.\n", socket_strerror(socket_errno()));
        return sd;
    }
    socket_buffer_init(&stateful_buf, sd);

    if (o.verbose) {
        loguser("Connected to proxy %s:%hu\n", inet_socktop(&targetaddrs->addr),
            inet_port(&targetaddrs->addr));
    }

    /* Fill the socks4_data struct */
    zmem(&socks4msg, sizeof(socks4msg));
    socks4msg.version = SOCKS4_VERSION;
    socks4msg.type = SOCKS_CONNECT;
    socks4msg.port = htons(o.portno);

    if (strlen(username) >= sizeof(socks4msg.data)) {
        loguser("Error: username is too long.\n");
        close(sd);
        return -1;
    }
    strcpy(socks4msg.data, username);
    datalen = strlen(username) + 1;

    if (proxyresolve(o.target, 0, &addr.storage, &sslen, AF_INET)) {
        /* target resolution has failed, possibly because it is disabled */
        if (!(o.proxydns & PROXYDNS_REMOTE)) {
            loguser("Error: Failed to resolve host %s locally.\n", o.target);
            close(sd);
            return -1;
        }
        if (o.verbose)
            loguser("Host %s will be resolved by the proxy.\n", o.target);
        socks4msg.address = inet_addr("0.0.0.1");
        if (datalen + strlen(o.target) >= sizeof(socks4msg.data)) {
            loguser("Error: host name is too long.\n");
            close(sd);
            return -1;
        }
        strcpy(socks4msg.data + datalen, o.target);
        datalen += strlen(o.target) + 1;
    } else {
        /* addr is now populated with sockaddr_in */
        socks4msg.address = addr.in.sin_addr.s_addr;
        if (o.verbose && getaddrfamily(o.target) == -1)
            loguser("Host %s locally resolved to %s.\n", o.target,
                inet_ntoa(addr.in.sin_addr));
    }

    if (send(sd, (char *)&socks4msg, offsetof(struct socks4_data, data) + datalen, 0) < 0) {
        loguser("Error: sending proxy request: %s.\n", socket_strerror(socket_errno()));
        close(sd);
        return -1;
    }

    /* The size of the socks4 response is 8 bytes. So read exactly
       8 bytes from the buffer */
    if (socket_buffer_readcount(&stateful_buf, socksbuf, 8) < 0) {
        loguser("Error: short response from proxy.\n");
        close(sd);
        return -1;
    }

    if (sd != -1 && socksbuf[1] != SOCKS4_CONN_ACC) {
        loguser("Proxy connection failed.\n");
        close(sd);
        return -1;
    }

    return sd;
}

/* SOCKS5 support
 * Return a usable socket descriptor after
 * proxy negotiation, or -1 on any error.
 */
static int do_proxy_socks5(void)
{
    struct socket_buffer stateful_buf;
    struct socks5_connect socks5msg;
    uint16_t proxyport = htons(o.portno);
    char socksbuf[8];
    int sd;
    size_t dstlen, targetlen;
    struct socks5_request socks5msg2;
    struct socks5_auth socks5auth;
    char *uptr, *pptr;
    size_t authlen, ulen, plen;
    union sockaddr_u addr;
    size_t sslen;
    void *addrbuf;
    size_t addrlen;
    char addrstr[INET6_ADDRSTRLEN];

    sd = do_connect(SOCK_STREAM);
    if (sd == -1) {
        loguser("Proxy connection failed: %s.\n", socket_strerror(socket_errno()));
        return sd;
    }

    socket_buffer_init(&stateful_buf, sd);

    if (o.verbose) {
        loguser("Connected to proxy %s:%hu\n", inet_socktop(&targetaddrs->addr),
            inet_port(&targetaddrs->addr));
    }

    zmem(&socks5msg,sizeof(socks5msg));
    socks5msg.ver = SOCKS5_VERSION;
    socks5msg.nmethods = 0;
    socks5msg.methods[socks5msg.nmethods++] = SOCKS5_AUTH_NONE;

    if (o.proxy_auth)
        socks5msg.methods[socks5msg.nmethods++] = SOCKS5_AUTH_USERPASS;

    if (send(sd, (char *)&socks5msg, offsetof(struct socks5_connect, methods) + socks5msg.nmethods, 0) < 0) {
        loguser("Error: proxy request: %s.\n", socket_strerror(socket_errno()));
        close(sd);
        return -1;
    }

    /* first response just two bytes, version and auth method */
    if (socket_buffer_readcount(&stateful_buf, socksbuf, 2) < 0) {
        loguser("Error: malformed first response from proxy.\n");
        close(sd);
        return -1;
    }

    if (socksbuf[0] != SOCKS5_VERSION) {
        loguser("Error: got wrong server version in response.\n");
        close(sd);
        return -1;
    }

    switch((unsigned char)socksbuf[1]) {
        case SOCKS5_AUTH_NONE:
            if (o.verbose)
                loguser("No authentication needed.\n");
            break;

        case SOCKS5_AUTH_USERPASS:
            if (o.verbose)
                loguser("Doing username and password authentication.\n");

            if(!o.proxy_auth){
                /* Proxy must not select a method not offered by the client */
                loguser("Error: proxy selected invalid authentication method.\n");
                close(sd);
                return -1;
            }

            /* Split up the proxy auth argument. */
            uptr = o.proxy_auth;
            pptr = strchr(o.proxy_auth, ':');
            if (pptr == NULL) {
                loguser("Error: invalid username:password combo.\n");
                close(sd);
                return -1;
            }

            ulen = (pptr++) - uptr;
            plen = strlen(pptr);
            if (ulen > SOCKS5_USR_MAXLEN) {
                loguser("Error: username length exceeds %d.\n", SOCKS5_USR_MAXLEN);
                close(sd);
                return -1;
            }
            if (plen > SOCKS5_PWD_MAXLEN) {
                loguser("Error: password length exceeds %d.\n", SOCKS5_PWD_MAXLEN);
                close(sd);
                return -1;
            }

            /*
             * For username/password authentication the client's authentication request is
             * field 1: version number, 1 byte (must be 0x01 -- version of subnegotiation)
             * field 2: username length, 1 byte
             * field 3: username
             * field 4: password length, 1 byte
             * field 5: password
             *
             * Server response for username/password authentication:
             * field 1: version, 1 byte
             * field 2: status code, 1 byte.
             * 0x00 = success
             * any other value = failure, connection must be closed
             */

            socks5auth.ver = 1;
            authlen = 0;
            socks5auth.data[authlen++] = ulen;
            memcpy(socks5auth.data + authlen, uptr, ulen);
            authlen += ulen;

            socks5auth.data[authlen++] = plen;
            memcpy(socks5auth.data + authlen, pptr, plen);
            authlen += plen;

            if (send(sd, (char *) &socks5auth, offsetof(struct socks5_auth, data) + authlen, 0) < 0) {
                loguser("Error: sending proxy authentication.\n");
                close(sd);
                return -1;
            }

            if (socket_buffer_readcount(&stateful_buf, socksbuf, 2) < 0) {
                loguser("Error: malformed proxy authentication response.\n");
                close(sd);
                return -1;
            }

            if (socksbuf[0] != 1 || socksbuf[1] != 0) {
                loguser("Error: authentication failed.\n");
                close(sd);
                return -1;
            }

            break;

        case SOCKS5_AUTH_FAILED:
            loguser("Error: no acceptable authentication method proposed.\n");
            close(sd);
            return -1;

        default:
            /* Proxy must not select a method not offered by the client */
            loguser("Error: proxy selected invalid authentication method.\n");
            close(sd);
            return -1;
    }

    zmem(&socks5msg2,sizeof(socks5msg2));
    socks5msg2.ver = SOCKS5_VERSION;
    socks5msg2.cmd = SOCKS_CONNECT;
    socks5msg2.rsv = 0;

    if (proxyresolve(o.target, 0, &addr.storage, &sslen, o.af)) {
        /* target resolution has failed, possibly because it is disabled */
        if (!(o.proxydns & PROXYDNS_REMOTE)) {
            loguser("Error: Failed to resolve host %s locally.\n", o.target);
            close(sd);
            return -1;
        }
        if (o.verbose)
            loguser("Host %s will be resolved by the proxy.\n", o.target);
        socks5msg2.atyp = SOCKS5_ATYP_NAME;
        targetlen=strlen(o.target);
        if (targetlen > SOCKS5_DST_MAXLEN){
            loguser("Error: hostname length exceeds %d.\n", SOCKS5_DST_MAXLEN);
            close(sd);
            return -1;
        }
        dstlen = 0;
        socks5msg2.dst[dstlen++] = targetlen;
        memcpy(socks5msg2.dst + dstlen, o.target, targetlen);
        dstlen += targetlen;
    } else {
        /* addr is now populated with either sockaddr_in or sockaddr_in6 */
        switch (addr.sockaddr.sa_family) {
            case AF_INET:
                socks5msg2.atyp = SOCKS5_ATYP_IPv4;
                addrbuf = &addr.in.sin_addr;
                addrlen = 4;
                break;
            case AF_INET6:
                socks5msg2.atyp = SOCKS5_ATYP_IPv6;
                addrbuf = &addr.in6.sin6_addr;
                addrlen = 16;
                break;
            default:
                pcat_assert(0);
        }
        memcpy(socks5msg2.dst, addrbuf, addrlen);
        dstlen = addrlen;
        if (o.verbose && getaddrfamily(o.target) == -1)
            loguser("Host %s locally resolved to %s.\n", o.target,
                inet_ntop(addr.sockaddr.sa_family, addrbuf, addrstr, sizeof(addrstr)));
    }

    memcpy(socks5msg2.dst + dstlen, &proxyport, 2);
    dstlen += 2;

    if (send(sd, (char *) &socks5msg2, offsetof(struct socks5_request , dst) + dstlen, 0) < 0) {
        loguser("Error: sending proxy request: %s.\n", socket_strerror(socket_errno()));
        close(sd);
        return -1;
    }

    /* TODO just two bytes for now, need to read more for bind */
    if (socket_buffer_readcount(&stateful_buf, socksbuf, 2) < 0) {
        loguser("Error: malformed second response from proxy.\n");
        close(sd);
        return -1;
    }

    switch(socksbuf[1]) {
        case 0:
            if (o.verbose)
                loguser("connection succeeded.\n");
            break;
        case 1:
            loguser("Error: general SOCKS server failure.\n");
            close(sd);
            return -1;
        case 2:
            loguser("Error: connection not allowed by ruleset.\n");
            close(sd);
            return -1;
        case 3:
            loguser("Error: Network unreachable.\n");
            close(sd);
            return -1;
        case 4:
            loguser("Error: Host unreachable.\n");
            close(sd);
            return -1;
        case 5:
            loguser("Error: Connection refused.\n");
            close(sd);
            return -1;
        case 6:
            loguser("Error: TTL expired.\n");
            close(sd);
            return -1;
        case 7:
            loguser("Error: Command not supported.\n");
            close(sd);
            return -1;
        case 8:
            loguser("Error: Address type not supported.\n");
            close(sd);
            return -1;
        default:
            loguser("Error: unassigned value in the reply.\n");
            close(sd);
            return -1;
    }

    return(sd);
}

static nsock_iod new_iod(nsock_pool mypool) {
   nsock_iod nsi = nsock_iod_new(mypool, NULL);
   if (nsi == NULL)
     bye("Failed to create nsock_iod.");
   if (nsock_iod_set_hostname(nsi, o.sslservername) == -1)
     bye("Failed to set hostname on iod.");

   switch (srcaddr.storage.ss_family) {
     case AF_UNSPEC:
       break;
     case AF_INET:
       nsock_iod_set_localaddr(nsi, &srcaddr.storage,
           sizeof(srcaddr.in));
       break;
#ifdef AF_INET6
     case AF_INET6:
       nsock_iod_set_localaddr(nsi, &srcaddr.storage,
           sizeof(srcaddr.in6));
       break;
#endif
#if HAVE_SYS_UN_H
     case AF_UNIX:
       nsock_iod_set_localaddr(nsi, &srcaddr.storage,
           SUN_LEN((struct sockaddr_un *)&srcaddr.storage));
       break;
#endif
     default:
       nsock_iod_set_localaddr(nsi, &srcaddr.storage,
           sizeof(srcaddr.storage));
       break;
   }

   if (o.numsrcrtes) {
     unsigned char *ipopts = NULL;
     size_t ipoptslen = 0;

     if (o.af != AF_INET)
       bye("Sorry, -g can only currently be used with IPv4.");
     ipopts = buildsrcrte(targetaddrs->addr.in.sin_addr, o.srcrtes, o.numsrcrtes, o.srcrteptr, &ipoptslen);

     nsock_iod_set_ipoptions(nsi, ipopts, ipoptslen);
     free(ipopts); /* Nsock has its own copy */
   }
   return nsi;
}

int pcat_connect(void)
{
    nsock_pool mypool;
    int rc;

    /* Unless explicitly asked not to do so, pcat uses the
     * fallback nsock engine to maximize compatibility between
     * operating systems and the different use cases.
     */
    if (!o.nsock_engine)
        nsock_set_default_engine("select");

    /* Create an nsock pool */
    if ((mypool = nsock_pool_new(NULL)) == NULL)
        bye("Failed to create nsock_pool.");

    if (o.debug >= 6)
        nsock_set_loglevel(NSOCK_LOG_DBG_ALL);
    else if (o.debug >= 3)
        nsock_set_loglevel(NSOCK_LOG_DBG);
    else if (o.debug >= 1)
        nsock_set_loglevel(NSOCK_LOG_INFO);
    else
        nsock_set_loglevel(NSOCK_LOG_ERROR);

    /* Allow connections to broadcast addresses. */
    nsock_pool_set_broadcast(mypool, 1);

#ifdef HAVE_OPENSSL
#ifdef HAVE_DTLS_CLIENT_METHOD
    if(o.proto == IPPROTO_UDP)
        set_ssl_ctx_options((SSL_CTX *) nsock_pool_dtls_init(mypool, 0));
    else
#endif
        set_ssl_ctx_options((SSL_CTX *) nsock_pool_ssl_init(mypool, 0));
#endif

    if (!o.proxytype) {
#if HAVE_SYS_UN_H
        /* For DGRAM UNIX socket we have to use source socket */
        if (o.af == AF_UNIX && o.proto == IPPROTO_UDP)
        {
            if (srcaddr.storage.ss_family != AF_UNIX) {
                char *tmp_name = NULL;
#if HAVE_MKSTEMP
              char *tmpdir = getenv("TMPDIR");
              size_t size=0, offset=0;
              strbuf_sprintf(&tmp_name, &size, &offset, "%s/pcat.XXXXXX",
                  tmpdir ? tmpdir : "/tmp");
              if (mkstemp(tmp_name) == -1) {
                bye("Failed to create name for temporary DGRAM source Unix domain socket (mkstemp).");
              }
              unlink(tmp_name);
#else
                /* If no source socket was specified, we have to create temporary one. */
                if ((tmp_name = tempnam(NULL, "pcat.")) == NULL)
                    bye("Failed to create name for temporary DGRAM source Unix domain socket (tempnam).");
#endif

                srcaddr.un.sun_family = AF_UNIX;
                strncpy(srcaddr.un.sun_path, tmp_name, sizeof(srcaddr.un.sun_path));
                free (tmp_name);
            }

            if (o.verbose)
                loguser("[%s] used as source DGRAM Unix domain socket.\n", srcaddr.un.sun_path);
        }
#endif
        /* A non-proxy connection. Create an iod for a new socket. */
        cs.sock_nsi = new_iod(mypool);

#if HAVE_SYS_UN_H
        if (o.af == AF_UNIX) {
            if (o.proto == IPPROTO_UDP) {
                nsock_connect_unixsock_datagram(mypool, cs.sock_nsi, connect_handler, NULL,
                                                &targetaddrs->addr.sockaddr,
                                                SUN_LEN((struct sockaddr_un *)&targetaddrs->addr.sockaddr));
            } else {
                nsock_connect_unixsock_stream(mypool, cs.sock_nsi, connect_handler, o.conntimeout,
                                              NULL, &targetaddrs->addr.sockaddr,
                                              SUN_LEN((struct sockaddr_un *)&targetaddrs->addr.sockaddr));
            }
        } else
#endif
        {
            /* Add connection to first resolved address. */
            try_nsock_connect(mypool, targetaddrs);
        }
    } else {
        /* A proxy connection. */
        static int connect_socket;

        if (strcmp(o.proxytype, "http") == 0) {
            connect_socket = do_proxy_http();
        } else if (strcmp(o.proxytype, "socks4") == 0) {
            connect_socket = do_proxy_socks4();
        } else if (strcmp(o.proxytype, "socks5") == 0) {
            connect_socket = do_proxy_socks5();
        }

        if (connect_socket == -1)
        {
            nsock_pool_delete(mypool);
            return 1;
        }
        /* Clear out whatever is left in the socket buffer which may be
           already sent by proxy server along with http response headers. */
        //line = socket_buffer_remainder(&stateful_buf, &n);
        /* Write the leftover data to stdout. */
        //Write(STDOUT_FILENO, line, n);

        /* Once the proxy negotiation is done, Nsock takes control of the
           socket. */
        cs.sock_nsi = nsock_iod_new2(mypool, connect_socket, NULL);
        if (nsock_iod_set_hostname(cs.sock_nsi, o.sslservername) == -1)
            bye("Failed to set hostname on iod.");
        if (o.ssl)
        {
            nsock_reconnect_ssl(mypool, cs.sock_nsi, connect_handler, o.conntimeout, NULL, NULL);
        }

        /* Create IOD for nsp->stdin */
        if ((cs.stdin_nsi = nsock_iod_new2(mypool, 0, NULL)) == NULL)
            bye("Failed to create stdin nsiod.");
    }

    /* connect */
    rc = nsock_loop(mypool, -1);

    free_sockaddr_list(targetaddrs);

    if (o.verbose) {
        struct timeval end_time;
        double time;
        gettimeofday(&end_time, NULL);
        time = TIMEVAL_MSEC_SUBTRACT(end_time, start_time) / 1000.0;
        loguser("%lu bytes sent, %lu bytes received in %.2f seconds.\n",
            nsock_iod_get_write_count(cs.sock_nsi),
            nsock_iod_get_read_count(cs.sock_nsi), time);
    }

#if HAVE_SYS_UN_H
    if (o.af == AF_UNIX && o.proto == IPPROTO_UDP) {
        if (o.verbose)
            loguser("Deleting source DGRAM Unix domain socket. [%s]\n", srcaddr.un.sun_path);
        unlink(srcaddr.un.sun_path);
    }
#endif

    nsock_pool_delete(mypool);

    return rc == NSOCK_LOOP_ERROR ? 1 : 0;
}

static void try_nsock_connect(nsock_pool nsp, struct sockaddr_list *conn_addr)
{
#ifdef HAVE_OPENSSL
    if (o.ssl) {
        nsock_connect_ssl(nsp, cs.sock_nsi, connect_handler,
                          o.conntimeout, (void *)conn_addr->next,
                          &conn_addr->addr.sockaddr, conn_addr->addrlen,
                          o.proto, inet_port(&conn_addr->addr),
                          NULL);
    }
    else
#endif
#ifdef HAVE_LINUX_VM_SOCKETS_H
    if (o.af == AF_VSOCK) {
        if (o.proto == IPPROTO_UDP) {
            nsock_connect_vsock_datagram(nsp, cs.sock_nsi, connect_handler,
                    (void *)conn_addr->next, &conn_addr->addr.sockaddr,
                    conn_addr->addrlen, conn_addr->addr.vm.svm_port);
        } else {
            nsock_connect_vsock_stream(nsp, cs.sock_nsi, connect_handler,
                    o.conntimeout, (void *)conn_addr->next,
                    &conn_addr->addr.sockaddr, conn_addr->addrlen,
                    conn_addr->addr.vm.svm_port);
        }
    }
    else
#endif
    if (o.proto == IPPROTO_UDP) {
        nsock_connect_udp(nsp, cs.sock_nsi, connect_handler, (void *)conn_addr->next,
                          &conn_addr->addr.sockaddr, conn_addr->addrlen,
                          inet_port(&conn_addr->addr));
    }
    else if (o.proto == IPPROTO_SCTP) {
        nsock_connect_sctp(nsp, cs.sock_nsi, connect_handler,
                          o.conntimeout, (void *)conn_addr->next,
                          &conn_addr->addr.sockaddr, conn_addr->addrlen,
                          inet_port(&conn_addr->addr));
    }
    else {
        nsock_connect_tcp(nsp, cs.sock_nsi, connect_handler,
                          o.conntimeout, (void *)conn_addr->next,
                          &conn_addr->addr.sockaddr, conn_addr->addrlen,
                          inet_port(&conn_addr->addr));
    }
}

static void send_udp_null(nsock_pool nsp)
{
  char *NULL_PROBE = "\0";
  int length = 1;
  nsock_write(nsp, cs.sock_nsi, write_socket_handler, -1, NULL, NULL_PROBE, length);
}

static void connect_handler(nsock_pool nsp, nsock_event evt, void *data)
{
    enum nse_status status = nse_status(evt);
    enum nse_type type = nse_type(evt);
    struct sockaddr_list *next_addr = (struct sockaddr_list *)data;

    pcat_assert(type == NSE_TYPE_CONNECT || type == NSE_TYPE_CONNECT_SSL);

    if (status == NSE_STATUS_ERROR || status == NSE_STATUS_TIMEOUT) {
        /* If there are more resolved addresses, try connecting to next one */
        if (next_addr != NULL) {
            if (o.verbose) {
                union sockaddr_u peer;
                zmem(&peer, sizeof(peer.storage));
                nsock_iod_get_communication_info(cs.sock_nsi, NULL, NULL, NULL,
                    &peer.sockaddr, sizeof(peer.storage));
                loguser("Connection to %s failed: %s.\n", inet_socktop(&peer),
                    (status == NSE_STATUS_TIMEOUT)
                    ? nse_status2str(status)
                    : socket_strerror(nse_errorcode(evt)));
                loguser("Trying next address...\n");
            }
            /* Delete the old IOD and make a new one for the next address.
             * This also clears SSL session info. */
            nsock_iod_delete(cs.sock_nsi, NSOCK_PENDING_NOTIFY);
            cs.sock_nsi = new_iod(nsp);

            try_nsock_connect(nsp, next_addr);
            return;
        }
        else {
            free_sockaddr_list(targetaddrs);
            if (!o.zerobyte||o.verbose)
              loguser("%s.\n",
                  (status == NSE_STATUS_TIMEOUT)
                  ? nse_status2str(status)
                  : socket_strerror(nse_errorcode(evt)));
            exit(1);
        }
    } else {
        pcat_assert(status == NSE_STATUS_SUCCESS);
    }

#ifdef HAVE_OPENSSL
    if (nsock_iod_check_ssl(cs.sock_nsi)) {
        /* Check the domain name. ssl_post_connect_check prints an
           error message if appropriate. */
        if (!ssl_post_connect_check((SSL *)nsock_iod_get_ssl(cs.sock_nsi), o.sslservername))
            bye("Certificate verification error.");
    }
#endif

    connect_report(cs.sock_nsi);
    if (o.proto != IPPROTO_UDP && o.zerobyte) {
      nsock_loop_quit(nsp);
    }

    /* Create IOD for nsp->stdin */
    if ((cs.stdin_nsi = nsock_iod_new2(nsp, 0, NULL)) == NULL)
        bye("Failed to create stdin nsiod.");

    post_connect(nsp, nse_iod(evt));
}

/* Handle --exec if appropriate, otherwise start the initial read events and set
   the idle timeout. */
static void post_connect(nsock_pool nsp, nsock_iod iod)
{
    /* Command to execute. */
    if (o.cmdexec) {
        struct fdinfo info;

        info.fd = nsock_iod_get_sd(iod);
#ifdef HAVE_OPENSSL
        info.ssl = (SSL *)nsock_iod_get_ssl(iod);
#endif
        /* Convert Nsock's non-blocking socket to an ordinary blocking one. It's
           possible for a program to write fast enough that it will get an
           EAGAIN on write on a non-blocking socket. */
        block_socket(info.fd);
        netexec(&info, o.cmdexec);
    }

    /* Start the initial reads. */

    if (!o.sendonly && !o.zerobyte)
        nsock_read(nsp, cs.sock_nsi, read_socket_handler, -1, NULL);

    if (!o.recvonly && !o.zerobyte)
        nsock_readbytes(nsp, cs.stdin_nsi, read_stdin_handler, -1, NULL, 0);

    if (o.zerobyte && o.proto==IPPROTO_UDP)
      send_udp_null(nsp);

    /* The --idle-timeout option says to exit after a certain period of
       inactivity. We start a timer here and reset it on every read event; see
       refresh_idle_timer. */
    if (o.idletimeout > 0) {
        cs.idle_timer_event_id =
            nsock_timer_create(nsp, idle_timer_handler, o.idletimeout, NULL);
    }

    union sockaddr_u peer;
    zmem(&peer, sizeof(peer.storage));
    nsock_iod_get_communication_info(cs.sock_nsi, NULL, NULL, NULL,
                                     &peer.sockaddr, sizeof(peer.storage));

    /* Set post directory. */
    set_postdir();
}

static void read_stdin_handler(nsock_pool nsp, nsock_event evt, void *data)
{
    enum nse_status status = nse_status(evt);
    enum nse_type type = nse_type(evt);
    char *buf, *tempbuf = NULL;
    int nbytes;
    int pbytes;

    pcat_assert(type == NSE_TYPE_READ);

    if (status == NSE_STATUS_EOF) {
        if (!o.noshutdown)
            shutdown(nsock_iod_get_sd(cs.sock_nsi), SHUT_WR);
        /* In --send-only mode or non-TCP mode, exit after EOF on stdin. */
        if (o.proto != IPPROTO_TCP || (o.proto == IPPROTO_TCP && o.sendonly))
            nsock_loop_quit(nsp);
        return;
    } else if (status == NSE_STATUS_ERROR) {
        loguser("%s.\n", socket_strerror(nse_errorcode(evt)));
        exit(1);
    } else if (status == NSE_STATUS_TIMEOUT) {
        loguser("%s.\n", nse_status2str(status));
        exit(1);
    } else if (status == NSE_STATUS_CANCELLED || status == NSE_STATUS_KILL) {
        return;
    } else {
        pcat_assert(status == NSE_STATUS_SUCCESS);
    }

    /* Read from stdin. */
    buf = nse_readbuf(evt, &nbytes);

    /* Is post command? If so then process it. */
    if ((pbuf = post_input(buf, nbytes, &pout)) != NULL)
        pbytes = strlen(pbuf);

    if (o.linedelay)
        pcat_delay_timer(o.linedelay);

    if (o.crlf) {
        if (pbuf != NULL)
            fix_line_endings(pbuf, &pbytes, &tempbuf, &cs.crlf_state);
        else
            fix_line_endings((char *) buf, &nbytes, &tempbuf, &cs.crlf_state);
    }

    if (tempbuf != NULL) {
        if (pbuf != NULL) {
            nsock_write(nsp, cs.sock_nsi, write_socket_handler, -1, NULL, tempbuf, pbytes);
            pcat_log_send(tempbuf, pbytes);
        } else {
            nsock_write(nsp, cs.sock_nsi, write_socket_handler, -1, NULL, tempbuf, nbytes);
            pcat_log_send(tempbuf, nbytes);
        }
        free(tempbuf);
        tempbuf = NULL;
    } else if (pbuf != NULL) {
        nsock_write(nsp, cs.sock_nsi, write_socket_handler, -1, NULL, pbuf, pbytes);
        pcat_log_send(pbuf, pbytes);
    } else {
        nsock_write(nsp, cs.sock_nsi, write_socket_handler, -1, NULL, buf, nbytes);
        pcat_log_send(buf, nbytes);
    }

    if (pbuf != NULL) {
        free(pbuf);
        pbuf = NULL;
    }
    
    refresh_idle_timer(nsp);
}

static void read_socket_handler(nsock_pool nsp, nsock_event evt, void *data)
{
    enum nse_status status = nse_status(evt);
    enum nse_type type = nse_type(evt);
    char *buf;
    int nbytes;

    pcat_assert(type == NSE_TYPE_READ);

    if (status == NSE_STATUS_EOF) {
#ifdef WIN32
        _close(STDOUT_FILENO);
#else
        Close(STDOUT_FILENO);
#endif
        /* In --recv-only mode or non-TCP mode, exit after EOF on the socket. */
        if (o.proto != IPPROTO_TCP || (o.proto == IPPROTO_TCP && o.recvonly))
            nsock_loop_quit(nsp);
        return;
    } else if (status == NSE_STATUS_ERROR) {
        if (!o.zerobyte||o.verbose)
          loguser("%s.\n", socket_strerror(nse_errorcode(evt)));
        exit(1);
    } else if (status == NSE_STATUS_TIMEOUT) {
        loguser("%s.\n", nse_status2str(status));
        exit(1);
    } else if (status == NSE_STATUS_CANCELLED || status == NSE_STATUS_KILL) {
        return;
    } else {
        pcat_assert(status == NSE_STATUS_SUCCESS);
    }

    buf = nse_readbuf(evt, &nbytes);

    if (o.linedelay)
        pcat_delay_timer(o.linedelay);

    /* Is post output? If so then process it else write socket data to stdout. */
    if (pout) {
        post_output(buf, nbytes, &pbuf, &pout);
    } else {
        if (o.telnet)
            dotelnet(nsock_iod_get_sd(nse_iod(evt)), (unsigned char *) buf, nbytes);

        /* Write socket data to stdout. */
        Write(STDOUT_FILENO, buf, nbytes);
        pcat_log_recv(buf, nbytes);
    }

    nsock_readbytes(nsp, cs.sock_nsi, read_socket_handler, -1, NULL, 0);

    refresh_idle_timer(nsp);
}

static void write_socket_handler(nsock_pool nsp, nsock_event evt, void *data)
{
    enum nse_status status = nse_status(evt);
    enum nse_type type = nse_type(evt);

    pcat_assert(type == NSE_TYPE_WRITE);

    if (status == NSE_STATUS_ERROR) {
        loguser("%s.\n", socket_strerror(nse_errorcode(evt)));
        exit(1);
    } else if (status == NSE_STATUS_TIMEOUT) {
        loguser("%s.\n", nse_status2str(status));
        exit(1);
    } else if (status == NSE_STATUS_CANCELLED || status == NSE_STATUS_KILL) {
        return;
    } else {
        pcat_assert(status == NSE_STATUS_SUCCESS);
    }

    if (o.zerobyte){
      pcat_assert(o.proto == IPPROTO_UDP);
      nsock_read(nsp, cs.sock_nsi, read_socket_handler, -1, NULL);
      return;
    }
    /* The write to the socket was successful. Allow reading more from stdin
       now. */
    nsock_readbytes(nsp, cs.stdin_nsi, read_stdin_handler, -1, NULL, 0);
}

static void idle_timer_handler(nsock_pool nsp, nsock_event evt, void *data)
{
    enum nse_status status = nse_status(evt);
    enum nse_type type = nse_type(evt);

    pcat_assert(type == NSE_TYPE_TIMER);

    if (status == NSE_STATUS_CANCELLED || status == NSE_STATUS_KILL)
        return;

    pcat_assert(status == NSE_STATUS_SUCCESS);

    if (o.zerobyte&&o.proto==IPPROTO_UDP){
      if (o.verbose)
        loguser("UDP packet sent successfully\n");
      nsock_loop_quit(nsp);
      return;
    }

    loguser("Idle timeout expired (%d ms).\n", o.idletimeout);

    exit(1);
}

static void refresh_idle_timer(nsock_pool nsp)
{
    if (o.idletimeout <= 0)
        return;
    nsock_event_cancel(nsp, cs.idle_timer_event_id, 0);
    cs.idle_timer_event_id =
        nsock_timer_create(nsp, idle_timer_handler, o.idletimeout, NULL);
}
