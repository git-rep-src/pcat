#ifndef FILE_H
#define FILE_H

#include <stddef.h>

int is_maxpath(size_t pathlen);
char *read_file(char *filepath, int *len);
int write_file(const char *src, const char *filepath);

#endif
