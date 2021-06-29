#include "../pcat.h"
#include "cmd_load.h"
#include "cmd_doc.h"

/* Is a command?. */
int is_cmd(char *src, int nbytes)
{
    src[nbytes] = '\0';
    
    if ((trim_leading(src)[0] == '\n') || (trim_leading(src)[0] != ':'))
        return 0;

    return 1;
}

/* Parse command and send it to functions. */
void cmd_input(char *src, int nbytes, char **cmdbuf, int *cmdnbytes, int *cmdout)
{
    char *opt = NULL;
    char *arg0 = NULL;
    char *arg1 = NULL;

    src[nbytes] = '\0';

    opt = strtok(&trim_leading(src)[1], " \n\r"); 
    arg0 = strtok(NULL, " \n\r");
    arg1 = strtok(NULL, " \n\r");

    if (((opt == NULL) || (arg0 == NULL)) ||
        ((strcmp(opt, "set") == 0) && ((arg0 == NULL) || (arg1 == NULL))) ||
        ((strcmp(opt, "cp") == 0) && ((arg0 == NULL) || (arg1 == NULL))) ||
        ((strcmp(opt, "get") == 0) && ((arg0 == NULL) || (arg1 == NULL)))) {
        loguser_noprefix(cmdhelp);
    } else {
        if ((strcmp(opt, "set") == 0) && (strcmp(arg0, "os") == 0)) {
            set_remoteos(arg1);
        } else if (has_settings("cmd", opt, arg0)) {
            if ((strcmp(opt, "do") == 0) ||
                (strcmp(opt, "show") == 0) ||
                (strcmp(opt, "cp") == 0) || 
                (strcmp(opt, "get") == 0)) {
                *cmdbuf = cmd_load(opt, arg0, arg1, cmdout);
            } else if (strcmp(opt, "doc") == 0) {
                cmd_doc(arg0);
            } else {
                loguser_noprefix(cmdhelp);
            }
        }
    }

    if (*cmdbuf == NULL) {
        *cmdbuf = (char *) safe_malloc(2);
        strcpy(*cmdbuf, "\n");
        *cmdout = 0;
    }

    *cmdnbytes = strlen(*cmdbuf);
}
