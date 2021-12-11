#include "../pcat.h"
#include "../file.h"

/* Set platform and read script. */
char *post_set(const char *arg0)
{
    char filename[16];
    char *filepath = NULL;
    char *ret = NULL;

    /* Set platform */
    if (set_platform(arg0)) {
        if (strcmp(platform, "windows") == 0)
            strcpy(filename, "post.ps1");
        else
            strcpy(filename, "post.sh");
 
        filepath = (char *) safe_malloc(strlen(postdir) + strlen(platform) + strlen(filename) + 16);
        sprintf(filepath, "%s/scripts/%s/%s", postdir, platform, filename);
   
        /* Read script. */
        ret = read_file(filepath, NULL);

        free(filepath);
    }

    return ret; 
}
