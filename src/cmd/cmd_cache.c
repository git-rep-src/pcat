#include "cmd_cache.h"
#include "../pcat.h"
#include "../file.h"

/* Command names in cache. */
static char cache[NAME_MAX * 8];

/* Is command in cache?. */
int has_cache(const char *name)
{
    if ((name == NULL) || (strstr(cache, name) == NULL))
        return 0;

    return 1;
}

/* Write command output to cache or read it from cache and write to stdout. */
void cmd_cache(const char *name, const char *src, const char *mode)
{
    char filepath[PATH_MAX];
    char *buf = NULL;

    if (is_pathmax("cache", (strlen(cachedir) + strlen(name) + 2))) {
        sprintf(filepath, "%s%s%s", cachedir, "/", name);
   
        if (strcmp(mode, "r") == 0) {
            if ((buf = read_file(filepath)) != NULL) {
                Write(STDOUT_FILENO, buf, strlen(buf));
                free(buf);
            } else {
                loguser("Can't read '%s' cache file.\n", name);
            }
        } else {
            if (write_file(filepath, src, strlen(src)))
                strcat(cache, name);
            else 
                loguser("Can't write '%s' cache file.\n", name);
        }
    }
}
