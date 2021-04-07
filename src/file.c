#include "pcat.h"

/* Pre/post: is file path lengh less that maximum allowed?. */
int is_maxpath(size_t pathlen)
{
    if (pathlen > 4096)
        return 0;

    return 1;
}

/* Pre/post: read file from disk. */
char *read_file(char *filepath, int *len)
{
    long nbytes;
    FILE *fp;
    char *ret = NULL;

    if ((fp = fopen(filepath, "r")) != NULL) {
        fseek(fp, 0L, SEEK_END);

        if ((nbytes = ftell(fp)) != -1) {
            fseek(fp, 0L, SEEK_SET);

            ret = (char *) safe_malloc(nbytes + 1);

            if (fread(ret, sizeof(char), nbytes, fp) == nbytes) {
                if (len != NULL)
                    *len = nbytes;
            } else { 
                free(ret);
                ret = NULL;
            }
        }
 
        fclose(fp);
    }
    
    if (ret != NULL)
        ret[nbytes] = '\0';

    return ret;
}

/* Pre/post: write file to disk. */
int write_file(const char *src, const char *filepath)
{
    size_t nbytes;
    FILE *fp;
    
    if ((fp = fopen(filepath, "w")) == NULL)
        return 0;
   
    nbytes = (strlen(src) + 1);

    if (fwrite(src, sizeof(char), nbytes, fp) != nbytes)
        return 0;

    fclose(fp);

    return 1;
}
