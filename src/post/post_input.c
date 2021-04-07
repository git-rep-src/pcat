#include "../pcat.h"
#include "../common.h"
#include "../set.h"
#include "post_show.h"
#include "post_run.h"
#include "post_pull.h"
#include "post_doc.h"

/* Is mandatory variables setted?. */
static int has_settings(const char *opt, const char *arg0)
{
    if (((remoteos[0] == '\0') && ((strcmp(opt, "set") != 0) || (strcmp(arg0, "os") != 0))) &&
        (strcmp(opt, "doc") != 0)) {
        print_message("Post: Remote operating system is not set. Try 'post help'.\n");

        return 0;
    }

    if (datadir[0] == '\0') {
         print_message("Post: Data directory is not set. Try reinstalling Pcat.\n");

         return 0;
    }

    if (cachedir[0] == '\0') {
        if (strcmp(opt, "show") == 0) {
             print_message("Post: Cache directory is not set. Try reinstalling Pcat.\n");

             return 0;
        }
    }

    return 1;
}

/* Parse stdin and send it to functions. */
char *post_input(const char *src, int len, int *is_post)
{
    char buf[len];
    char *name = NULL; 
    char *opt = NULL;
    char *arg0 = NULL;
    char *arg1 = NULL;
    char *ret = NULL;
   
    strncpy(buf, src, len);

    name = strtok(buf, " \n\r"); 
    opt = strtok(NULL, " \n\r");
    arg0 = strtok(NULL, " \n\r");
    arg1 = strtok(NULL, " \n\r");

    if (((strcmp(name, "post") != 0) || (opt == NULL) || (arg0 == NULL)) ||
        ((strcmp(opt, "set") == 0) && ((arg0 == NULL) || (arg1 == NULL))) ||
        ((strcmp(opt, "pull") == 0) && ((arg0 == NULL) || (arg1 == NULL)))) {
        print_message(NULL);
    } else {
        if (has_settings(opt, arg0)) {
            if (strcmp(opt, "set") == 0) {
                if (strcmp(arg0, "os") == 0)
                    set_remoteos(arg1);
            } else if (strcmp(opt, "show") == 0) {
                ret = post_show(arg0, is_post);
            } else if (strcmp(opt, "run") == 0) {
                ret = post_run(arg0);
            } else if (strcmp(opt, "pull") == 0) {
                ret = post_pull(arg0, arg1, is_post);
            } else if (strcmp(opt, "doc") == 0) {
                post_doc(arg0);
            } else {
                print_message(NULL);
            }
        }
    }

    return ret;
}
