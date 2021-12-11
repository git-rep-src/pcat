#include "../pcat.h"
#include "post_pull.h"

/* Process output. */
void post_output(char *src, int nbytes, char **pbuf, int *pout)
{
    static size_t size = 0;
    static size_t offset = 0;

    src[nbytes] = '\0';

    strbuf_append_str(pbuf, &size, &offset, src);
                
    /* Is end of output?. */
    if (strstr(*pbuf, "[PEOF]") != NULL) {
        /* Is pull command? If so then proccess it. */
        if (strstr(*pbuf, "[PULL]") != NULL) { 
            if (!post_pull_output(pbuf))
                loguser_noprefix("Post: Command failed.\n");
        }

        free(*pbuf);
        *pbuf = NULL;
        *pout = 0;

        size = 0;
        offset = 0;
    }
}
