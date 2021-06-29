#include "../pcat.h"
#include "cmd_parse.h"
#include "cmd_cache.h"

/* Process command output. */
static void process(const char *src)
{
    char name[NAME_MAX];
    char *ret = NULL;
    
    /* Is XML? If so then parse and write it to stdout. */
    if (is_xml(src)) {
        if ((ret = cmd_parse(src, &name[0])) != NULL) {
            Write(STDOUT_FILENO, ret, strlen(ret));
            if (!has_cache(name))
                cmd_cache(name, ret, "w");
            free(ret);
        }
    }
}

/* Read command output. */
void cmd_output(char *src, int nbytes, char **cmdbuf, int *cmdout)
{
    static size_t size = 0;
    static size_t offset = 0;

    src[nbytes] = '\0';

    strbuf_append_str(cmdbuf, &size, &offset, src);
                
    if (strstr(*cmdbuf, "[CMD-EOF]") != NULL) {
        process(*cmdbuf);
                    
        size = 0;
        offset = 0;
        *cmdout = 0;

        free(*cmdbuf);
        *cmdbuf = NULL;
    }
}
