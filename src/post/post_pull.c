#include "../pcat.h"
#include "../base64.h"
#include "../common.h"
#include "../conv.h"
#include "../file.h"

/* Process script. */
static char *build(const char *name, const char *dest, char *filepath)
{
    int buflen;
    char *src = NULL;
    unsigned short *buf = NULL;
    char *tempbuf = NULL;
    char *ret = NULL;

    /* Read script from disk. */
    if ((src = read_file(filepath, NULL)) != NULL) {
        /* Is Windows remote operating system? If so then convert script to unicode. */
        if (strcmp(remoteos, "windows") == 0) {
            buf = (unsigned short*) safe_malloc(strlen(src) * 4);
            buflen = (strlen(src) + utf8_to_unicode((unsigned char *) src, buf, (strlen(src) * 4)));
        } else {
            buf = (unsigned short *) src;
            buflen = strlen(src);
        }
            
        /* Encode script to base64. */
        if ((tempbuf = b64enc((const unsigned char *) buf, buflen)) != NULL) {
            /* Build bash/powershell command to decode and run script on remote machine. */
            ret = (char *) safe_malloc(strlen(tempbuf) + strlen(name) + strlen(dest) + strlen(remoteos) + 200);
                    
            if (strcmp(remoteos, "bsd") == 0) {
                strcpy(ret, "LC_ALL=C echo ");
                strcat(ret, "'begin-base64 644 null\n'' ");
                strcat(ret, tempbuf);
                strcat(ret, "\n'====");
                strcat(ret, " | uudecode -p | /bin/sh -s ");
                strcat(ret, remoteos);
                strcat(ret, " ");
                strcat(ret, name);
                strcat(ret, " ");
                strcat(ret, dest);
                strcat(ret, "\n");
            } else if (strcmp(remoteos, "linux") == 0) {
                strcpy(ret, "LC_ALL=C echo ");
                strcat(ret, tempbuf);
                strcat(ret, " | base64 -d | /bin/sh -s ");
                strcat(ret, remoteos);
                strcat(ret, " ");
                strcat(ret, name);
                strcat(ret, " ");
                strcat(ret, dest);
                strcat(ret, "\n");
            } else {
                strcpy(ret, "powershell.exe -executionpolicy bypass -outputformat Text -nologo -noprofile -command ");
                strcat(ret, "'");
                strcat(ret, name);
                strcat(ret, "'");
                strcat(ret, ", '");
                strcat(ret, dest);
                strcat(ret, "'");
                strcat(ret, " | ");
                strcat(ret, "powershell -executionpolicy bypass -outputformat Text -nologo -noprofile -encodedcommand ");
                strcat(ret, tempbuf);
                strcat(ret, "\n");
            }
               
            free(tempbuf);
        } 
            
        free(src);
        
        if (strcmp(remoteos, "windows") == 0) {
            if (buf != NULL)
                free(buf);
        }
    }

    return ret;
}

/* Return the script to send and run it on remote machine. */
char *post_pull(const char *name, const char *dest, int *is_post)
{
    size_t pathlen;
    char *filepath = NULL;
    char *ret = NULL;

    pathlen = (strlen(datadir) + 32);
            
    if (is_maxpath(pathlen)) {
        filepath = (char *) safe_malloc(pathlen);
        
        strcpy(filepath, datadir);
        if (strcmp(remoteos, "windows") == 0)
            strcat(filepath, "/scripts/windows/pull/pull.ps1");
        else
            strcat(filepath, "/scripts/unix/pull/pull.sh");

        if ((ret = build(name, dest, filepath)) != NULL)
            *is_post = 1;
        else
            print_message(NULL);
        
        free(filepath);
    } else {
        print_message("Post: File path is greater than MAX_PATH.\n");
    }

    return ret; 
}
