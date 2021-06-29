#include "../pcat.h"
#include "../base64.h"
#include "../unicode.h"
#include "../file.h"
#include "cmd_cache.h"

/* Script headers. */
int headers[4];

/* Read script headers. */
static void header(const char *src, int nbytes)
{
    char buf[nbytes];
    char *os = NULL; 
    char *raw = NULL; 
    char *one = NULL;
    char *out = NULL;

    memset(headers, 0, (4 * sizeof(headers[0])));
    memset(buf, 0, nbytes);
    
    strcpy(buf, src);

    os = strtok(buf, "\n\r"); 
    raw = strtok(NULL, "\n\r");
    one = strtok(NULL, "\n\r");
    out = strtok(NULL, "\n\r");

    if (strstr(os, "1") != NULL)
        headers[0] = 1;
    else if (strstr(os, "2") != NULL)
        headers[0] = 2;
    if (strstr(raw, "1") != NULL)
        headers[1] = 1;
    if (strstr(one, "1") != NULL)
        headers[2] = 1;
    if (strstr(out, "1") != NULL)
        headers[3] = 1;
}

/* Read script. */
static char *script(const char *filepath)
{
    size_t buflen;
    char *src = NULL;
    unsigned short *buf = NULL;
    char *ret = NULL;

    if ((src = read_file(filepath)) != NULL) {
        if (strstr(filepath, ".2") == NULL)
            header(src, strlen(src));
        /* Is raw? If so then return else encode to base64. */
        if (headers[1]) {
            ret = src;
        } else {
            /* Is Windows remote operating system? If so then convert to unicode. */
            if (strcmp(remoteos, "windows") == 0) {
                buf = (unsigned short *) safe_malloc(strlen(src) * 4);
                buflen = (strlen(src) + utf8_to_unicode((unsigned char *) src, buf, (strlen(src) * 4)));
            } else {
                buf = (unsigned short *) src;
                buflen = strlen(src);
            }
            
            /* Encode to base64. */
            ret = b64enc((const unsigned char *) buf, buflen);
       
            free(src);
            if (strcmp(remoteos, "windows") == 0)
                free(buf);
        }
    }

    return ret;
}

/* Build command. */
static void cmd(const char *buf, const char *arg0, const char *arg1, char **ret)
{
    static size_t size = 0;
    static size_t offset = 0;
    char decoder[16];
    char *a0 = NULL;
    char *a1 = NULL;

    if (strcmp(remoteos, "bsd") == 0)
        strcpy(decoder, "uudecode -mrp");
    else if (strcmp(remoteos, "linux") == 0)
        strcpy(decoder, "base64 -d");

    if (arg0 != NULL) {
        a0 = (char *) arg0;
    } else {
        a0 = (char *) safe_malloc(1);
        a0[0] = '\0';
    }
    if (arg1 != NULL) {
        a1 = (char *) arg1;
    } else {
        a1 = (char *) safe_malloc(1);
        a1[0] = '\0';
    }
    
    /* Build powershell/sh command to decode and run script on remote machine. */
    if (strcmp(remoteos, "windows") == 0)
        strbuf_sprintf(ret, &size, &offset, "powershell.exe -executionpolicy bypass -outputformat Text -nologo -noprofile -command"\
                                            " '%s', '%s' | "\
                                            "powershell.exe -executionpolicy bypass -outputformat Text -nologo -noprofile -encodedcommand"\
                                            " %s\n", a0, a1, buf);
    else 
        strbuf_sprintf(ret, &size, &offset, "echo %s | %s | /bin/sh -s %s %s %s\n", buf, decoder, remoteos, a0, a1);
    
    if (headers[2] /*|| si es la fila .2*/) {
        size = 0;
        offset = 0;
    }

    if (arg0 == NULL)
        free(a0);
    if (arg1 == NULL)
        free(a1);
}

/* Build response. */
static char *response(char *filepath, const char *arg0, const char *arg1)
{
    char *buf = NULL;
    char *ret = NULL;

    for (int i = 0; i < 2; i++) {
        if ((buf = script(filepath)) != NULL) {
            /* Is raw? If so then return else build command. */
            if (headers[1]) {
                ret = buf;
            } else {
                cmd(buf, arg0, arg1, &ret); 
               
                free(buf);
                buf = NULL;
            }
        } else {
            break;
        }
            
        /* Is one file? If so then return else read second file. */
        if (!headers[2] && (i < 1))
            strcat(filepath, ".2");
        else
            break;
    }

    return ret;
}

/* Read script and build command to run it on the remote machine. */
char *cmd_load(const char *opt, const char *arg0, const char *arg1, int *cmdout)
{
    char dir[NAME_MAX];
    char file[NAME_MAX];
    char filepath[PATH_MAX];
    char *ret = NULL;

    strcpy(dir, opt);
    if ((strcmp(opt, "do") == 0) || (strcmp(opt, "show") == 0)) {
        if (strlen(arg0) < NAME_MAX)
            strcpy(file, arg0);
    } else {
        strcpy(file, opt);
    }

    if ((strlen(file) != 0) &&
        is_pathmax("scripts", (strlen(datadir) + strlen(dir) + strlen(file) + 32))) {
        if (strcmp(remoteos, "windows") == 0)
            sprintf(filepath, "%s%s%s%s%s%s", datadir, "/scripts/windows/", dir, "/", file, ".ps1");
        else
            sprintf(filepath, "%s%s%s%s%s%s", datadir, "/scripts/unix/", dir, "/", file, ".sh");
        
        if (has_cache(arg0)) {
            cmd_cache(arg0, NULL, "r");
        } else {
            if ((ret = response(filepath, arg0, arg1)) != NULL) {
                if (((headers[0] == 1) && (strcmp(remoteos, "windows") == 0)) ||
                    ((headers[0] == 2) && (strcmp(remoteos, "windows") != 0))) {
                    loguser("Invalid command for remote operating system.\n");
                    free(ret);
                    ret = NULL;
                } else {
                    *cmdout = headers[3];
                }
            } else {
                loguser("Can't load '%s' script. Try ':help'.\n", file);
            }
        }
    }

    return ret; 
}
