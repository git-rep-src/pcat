#include "../pcat.h"
#include "../common.h"
#include "../file.h"

/* Return the script to send and run it on remote machine. */
char *post_run(const char *name)
{
    size_t pathlen;
    char *filepath = NULL;
    char *ret = NULL;

    pathlen = (strlen(datadir) + strlen(name) + 32);
            
    if (is_maxpath(pathlen)) {
        filepath = (char *) safe_malloc(pathlen);
        
        strcpy(filepath, datadir);
        if (strcmp(remoteos, "windows") == 0) {
            strcat(filepath, "/scripts/windows/run/");
            strcat(filepath, name);
            strcat(filepath, ".ps1");
        } else {
            strcat(filepath, "/scripts/unix/run/");
            strcat(filepath, name);
            strcat(filepath, ".sh");
        }

        if (strcmp(name, "tty") == 0) {
            if (strcmp(remoteos, "windows") != 0) {
                if ((ret = read_file(filepath, NULL)) == NULL)
                    print_message(NULL);
            } else {
                print_message("Post: Remote Unix operating systems only option.\n");
            }
        } else {
            print_message(NULL);
        }
        
        free(filepath);
    } else {
        print_message("Post: File path is greater than MAX_PATH.\n");
    }

    return ret; 
}
