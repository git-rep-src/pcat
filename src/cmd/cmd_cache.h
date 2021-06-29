#ifndef CMD_CACHE_H
#define CMD_CACHE_H

int has_cache(const char *name);
void cmd_cache(const char *name, const char *src, const char *mode);

#endif
