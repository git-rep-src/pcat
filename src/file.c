#include "pcat.h"

/* Read file from disk. */
char *read_file(const char *filepath, size_t *nbytes)
{
    size_t len = 0;
    FILE *fp;
    char *ret = NULL;

    if ((fp = fopen(filepath, "r")) != NULL) {
        fseek(fp, 0L, SEEK_END);

        if ((len = ftell(fp)) != -1) {
            fseek(fp, 0L, SEEK_SET);

            ret = (char *) safe_malloc(len + 1);
            memset(ret, 0, (len + 1));

            if (fread(ret, sizeof(char), len, fp) != len) {
                free(ret);
                ret = NULL;
            }
        }
 
        fclose(fp);
    }

    if (nbytes != NULL)
        *nbytes = len;

    return ret;
}

/* Write file to disk. */
int write_file(const char *filepath, const char *src, size_t len)
{
    FILE *fp;
    
    if ((fp = fopen(filepath, "w")) == NULL)
        return 0;

    if (fwrite(src, sizeof(char), len, fp) != len)
        return 0;

    fclose(fp);

    return 1;
}
