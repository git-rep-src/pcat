#include "../pcat.h"
#include "post_set.h"
#include "post_push.h"
#include "post_pull.h"
#include "post_put.h"

/* Is setted?. */
static int setted = 0;
static const char help_message[] = 
"post set  bsd|linux|windows                      set post on remote system memory\n"
"     show system|users|process|network|pe|cve    show information\n"
"     push FILE FILE                              copy local FILE to remote FILE (windows <= 4MB)\n"
"     pull FILE FILE                              copy remote FILE to local FILE\n"
"     put  tools DIR                              install static binaries package on DIR\n"
"          exploits DIR                           install exploit sources package on DIR\n"
"     help                                        show help\n"
"\n"
"     Windows need a powershell reverse shell.\n";

/* Reset buffer. */
static void reset(char **ret)
{
    *ret = (char *) safe_malloc(1);
    strcpy(*ret, "\n");
}

/* Show help. */
static void help(char **ret)
{
    loguser_noprefix(help_message);
    reset(ret);
}

/* Is post command? If so then process it. */
char *post_input(char *src, int nbytes, int *pout)
{
    char buf[nbytes + 1];
    char *cmd = NULL;
    char *opt = NULL;
    char *arg0 = NULL;
    char *arg1 = NULL;
    char *ret = NULL;

    memset(buf, 0, (nbytes + 1));
    strncpy(buf, src, nbytes);

    if (strlen(buf) > 1) {
        cmd = strtok(buf, " \n\r");
        opt = strtok(NULL, " \n\r");
        arg0 = strtok(NULL, " \n\r");
        arg1 = strtok(NULL, " \n\r");

        if (strcmp(cmd, "post") == 0) {
            if ((opt != NULL) && (arg0 != NULL)) {
                if (strcmp(opt, "set") == 0) {
                    if ((ret = post_set(arg0)) != NULL) {
                        setted = 1;
                        *pout = 1;
                    } else { 
                        help(&ret);
                    }
                } else {
                    if (setted) {
                        if (strcmp(opt, "push") == 0) {
                            if (arg1 != NULL) {
                                if ((ret = post_push(arg0, arg1)) != NULL)
                                    *pout = 1;
                                else
                                    help(&ret);
                            } else {
                                help(&ret);
                            }
                        } else if (strcmp(opt, "pull") == 0) {
                            if (arg1 != NULL) {
                                if ((ret = post_pull(arg0, arg1)) != NULL)
                                    *pout = 1;
                                else
                                    help(&ret);
                            } else {
                                help(&ret);
                            }
                        } else if (strcmp(opt, "put") == 0) {
                            if (arg1 != NULL) {
                                if ((ret = post_put(arg0, arg1)) != NULL)
                                    *pout = 1;
                                else
                                    help(&ret);
                            } else {
                                help(&ret);
                            }
                        }
                    } else {
                        help(&ret);
                    }
                }
            } else {
                help(&ret);
            }
        }
    }

    return ret;
}
