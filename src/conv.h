#ifndef CONV_H
#define CONV_H

int utf8_to_unicode(unsigned char *utf8_str, unsigned short *unicode_str, int unicode_str_size);
void unicode_to_utf8(unsigned int *unistr, long slen, char *utf8_str, long utf8_str_size);

#endif
