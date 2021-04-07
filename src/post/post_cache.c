#include "post_cache.h"
#include "../pcat.h"
#include "../common.h"
#include "../file.h"

static char cache[16 * 8] = {0};

/* Is script output in cache?. */
int post_has_cache(const char *name)
{
    if (strstr(cache, name) == NULL)
        return 0;

    return 1;
}

/* Read script output from cache and write it to stdout
   or write it to cache directory. */
void post_cache(const char *src, const char *name, int is_write)
{
    size_t pathlen;
    char *filepath = NULL;
    char *buf = NULL;
   
    pathlen = (strlen(cachedir) + strlen(name) + 2);

    if (is_maxpath(pathlen)) {
        filepath = (char *) safe_malloc(pathlen);

        strcpy(filepath, cachedir);
        strcat(filepath, "/");
        strcat(filepath, name);
   
        if (is_write) {
            if (write_file(src, filepath)) {
                if (cache[0] == '\0')
                    strcpy(cache, name);
                else
                    strcat(cache, name);
            }
        } else {
            if ((buf = read_file(filepath, NULL)) != NULL) {
                Write(STDOUT_FILENO, buf, strlen(buf));
                free(buf);
            }
        }
        
        free(filepath);
    }
}
