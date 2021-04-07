#include "post_parse.h"

#include <string.h>

/* Check remote system response type and send it to functions. */
void post_output(const char *src)
{
    /* Is XML?. */
    if (strstr(src, "<DATA") != NULL) {
        post_parse(src);
    }
}
