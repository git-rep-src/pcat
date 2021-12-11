#include "../pcat.h"
#include "../base64.h"
#include "../file.h"

/* Build command. */
char *post_pull(const char *arg0, const char *arg1)
{
    char *ret = NULL;
   
    ret = (char *) safe_malloc(strlen(arg0) + strlen(arg1) + 16);
    /* Build command. */
    sprintf(ret, "post pull %s %s\n", arg0, arg1);

    return ret;
}

/* Parse output and write file. */
int post_pull_output(char **pbuf)
{
    size_t len;
    char *filepath = NULL;
    char *src = NULL;
    char *buf = NULL;

    /* Parse path and source file. */
    strtok(*pbuf, "\n\r");
    filepath = strtok(NULL, "\n\r");
    src = strtok(NULL, "\n\r");

    if ((filepath != NULL) && (src != NULL)) {
        /* Decode source from base64. */
        buf = b64dec((const unsigned char *) src, strlen(src), &len);
        /* Write file*/
        if ((buf == NULL) || !write_file(filepath, buf, len))
            return 0;
    } else {
        return 0;
    }

    return 1;
}
