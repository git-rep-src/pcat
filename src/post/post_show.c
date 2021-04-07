#include "../pcat.h"
#include "../base64.h"
#include "../common.h"
#include "../conv.h"
#include "../file.h"
#include "post_cache.h"

/* Process script. */
static char *build(char *filepath)
{
    int has_error = 0;
    int buflen;
    char *src = NULL;
    unsigned short *buf = NULL;
    char *tempbuf = NULL;
    char *ret = NULL;

    for (int i = 0; i < 2; i++) {
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
                if (ret == NULL) {
                    ret = (char *) safe_malloc(strlen(tempbuf) + strlen(remoteos) + 112);
                    
                    if (strcmp(remoteos, "bsd") == 0) {
                        strcpy(ret, "LC_ALL=C echo ");
                        strcat(ret, "'begin-base64 644 null\n'' ");
                        strcat(ret, tempbuf);
                        strcat(ret, "\n'====");
                        strcat(ret, " | uudecode -p | /bin/sh -s ");
                        strcat(ret, remoteos);
                        strcat(ret, "\n");
                    } else if (strcmp(remoteos, "linux") == 0) {
                        strcpy(ret, "LC_ALL=C echo ");
                        strcat(ret, tempbuf);
                        strcat(ret, " | base64 -d | /bin/sh -s ");
                        strcat(ret, remoteos);
                        strcat(ret, "\n");
                    } else {
                        strcpy(ret, "powershell.exe -executionpolicy bypass -outputformat Text -nologo -noprofile -encodedcommand ");
                        strcat(ret, tempbuf);
                        strcat(ret, "\n");
                    }
                } else {
                    ret = (char *) safe_realloc(ret, (strlen(ret) + strlen(tempbuf) + 112));

                    strcat(ret, " powershell.exe -executionpolicy bypass -outputformat Text -nologo -noprofile -encodedcommand ");
                    strcat(ret, tempbuf);
                    strcat(ret, "\n");
                }
               
                free(tempbuf);
                tempbuf = NULL;
            } else {
                has_error = 1;
                break;
            }
            
            free(src);
            src = NULL;
        } else {
            if ((strcmp(remoteos, "windows") != 0) && (strstr(filepath, ".2") == NULL)) {
                has_error = 1;
                break;
            }
        }
        
        if (strcmp(remoteos, "windows") == 0) {
            if (buf != NULL) {
                free(buf);
                buf = NULL;
            }
            
            if ((i == 0) && (ret != NULL))
                strcat(filepath, ".2");
            else
                break;
        } else {
            break;
        }
    }

    if (has_error) {
        if (src != NULL)
            free(src);
        if (strcmp(remoteos, "windows") == 0) {
            if (buf != NULL)
                free(buf);
        }
        if (ret != NULL) {
            free(ret);
            ret = NULL;
        }
    }

    return ret;
}

/* Return the script to send and run it on remote machine. */
char *post_show(const char *name, int *is_post)
{
    size_t pathlen;
    char *filepath = NULL;
    char *ret = NULL;

    if (post_has_cache(name)) {
        post_cache(NULL, name, 0);
    } else {
        pathlen = (strlen(datadir) + strlen(name) + 32);
            
        if (is_maxpath(pathlen)) {
            filepath = (char *) safe_malloc(pathlen);
        
            strcpy(filepath, datadir);
            if (strcmp(remoteos, "windows") == 0) {
                strcat(filepath, "/scripts/windows/show/");
                strcat(filepath, name);
                strcat(filepath, ".ps1");
            } else {
                strcat(filepath, "/scripts/unix/show/");
                strcat(filepath, name);
                strcat(filepath, ".sh");
            }

            if ((ret = build(filepath)) != NULL)
                *is_post = 1;
            else
                print_message(NULL);
        
            free(filepath);
        } else {
            print_message("Post: File path is greater than MAX_PATH.\n");
        }
    }

    return ret; 
}
