#ifndef POST_CACHE_H
#define POST_CACHE_H

int post_has_cache(const char *name);
void post_cache(const char *src, const char *name, int is_write);

#endif
