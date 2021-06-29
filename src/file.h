#ifndef FILE_H
#define FILE_H

#include <stddef.h>
    
char *read_file(const char *filepath);
int write_file(const char *filepath, const char *src, size_t len);

#endif
