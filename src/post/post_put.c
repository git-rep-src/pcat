#include "../pcat.h"
#include "../base64.h"
#include "../file.h"

/* Read package and build command. */
char *post_put(const char *arg0, const char *arg1)
{
    size_t nbytes;
    char filename[16];
    char *filepath = NULL;
    char *src = NULL;
    char *buf = NULL;
    char *ret = NULL;

    /* Is a valid package?. */
    if ((strcmp(arg0, "tools") == 0) || (strcmp(arg0, "exploits") == 0)) {
        if (strcmp(platform, "windows") == 0)
            sprintf(filename, "%s.zip", arg0);
        else
            sprintf(filename, "%s.tar.gz", arg0);

        filepath = (char *) safe_malloc(strlen(postdir) + strlen(platform) + strlen(filename) + 16);
        sprintf(filepath, "%s/packages/%s/%s", postdir, platform, filename);
        
        /* Read package. */
        if ((src = read_file(filepath, &nbytes)) != NULL) {
            /* Encode package to base64. */
            buf = b64enc((const unsigned char *) src, nbytes);

            /* Build command. */
            ret = (char *) safe_malloc(strlen(buf) + strlen(arg1) + 16);
            sprintf(ret, "post put %s %s\n", buf, arg1);

            free(src);
            free(buf);
        }
    }

    free(filepath);

    return ret;
}
