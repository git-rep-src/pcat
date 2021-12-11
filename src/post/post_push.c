#include "../pcat.h"
#include "../base64.h"
#include "../file.h"

/* Read file and build command. */
char *post_push(const char *arg0, const char *arg1)
{
    size_t nbytes;
    char *filepath = NULL;
    char *src = NULL;
    char *buf = NULL;
    char *ret = NULL;

    filepath = (char *) safe_malloc(strlen(arg0) + 1);
    sprintf(filepath, "%s", arg0);
    
    /* Read file. */
    if ((src = read_file(filepath, &nbytes)) != NULL) {
        /* Encode file to base64. */
        buf = b64enc((const unsigned char *) src, nbytes);

        /* Build command. */
        ret = (char *) safe_malloc(strlen(buf) + strlen(arg1) + 16);
        sprintf(ret, "post push %s %s\n", buf, arg1);

        free(src);
        free(buf);
    }

    free(filepath);

    return ret;
}
