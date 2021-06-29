#include <stdio.h>
#include <string.h>

/* Take in utf8 and convert to unicode_char. */
static int utf8_to_unicode_char(unsigned char *ch, int *unicode)
{
    unsigned char *p = NULL;
    int e = 0;
    int n = 0;

    p = ch;
    
    if (!p || !unicode)
        return 0;

    if (*p >= 0xfc) {
        /* 6:<11111100> */
        e  = (p[0] & 0x01) << 30;
        e |= (p[1] & 0x3f) << 24;
        e |= (p[2] & 0x3f) << 18;
        e |= (p[3] & 0x3f) << 12;
        e |= (p[4] & 0x3f) << 6;
        e |= (p[5] & 0x3f);
        n = 6;
    } else if (*p >= 0xf8) {
        /* 5:<11111000> */
        e  = (p[0] & 0x03) << 24;
        e |= (p[1] & 0x3f) << 18;
        e |= (p[2] & 0x3f) << 12;
        e |= (p[3] & 0x3f) << 6;
        e |= (p[4] & 0x3f);
        n = 5;
    } else if (*p >= 0xf0) {
        /* 4:<11110000> */
        e  = (p[0] & 0x07) << 18;
        e |= (p[1] & 0x3f) << 12;
        e |= (p[2] & 0x3f) << 6;
        e |= (p[3] & 0x3f);
        n = 4;
    } else if (*p >= 0xe0) {
        /* 3:<11100000> */
        e  = (p[0] & 0x0f) << 12;
        e |= (p[1] & 0x3f) << 6;
        e |= (p[2] & 0x3f);
        n = 3;
    } else if (*p >= 0xc0) {
        /* 2:<11000000> */
        e  = (p[0] & 0x1f) << 6;
        e |= (p[1] & 0x3f);
        n = 2;
    } else {
        e = p[0];
        n = 1;
    }

    *unicode = e;

    /* Return bytes count of this utf-8 character */
    return n;
}

/* Take in utf8 and convert to unicode. */
int utf8_to_unicode(unsigned char *utf8_str, unsigned short *unicode_str, int unicode_str_size)
{
    int unicode = 0;
    int n = 0;
    int count = 0;
    unsigned char *s = NULL;
    unsigned short *e = NULL;

    s = utf8_str;
    e = unicode_str;

    if (!utf8_str || !unicode_str)
        return 0;

    while (*s) {
        if ((n = utf8_to_unicode_char(s, &unicode)) > 0) {
            if (++count  >= unicode_str_size) {
                return count;
            } else {
                *e = (unsigned short) unicode;
                e++;
                *e = 0;

                /* Step to next utf-8 character */
                s += n;
            }
        } else {
            /* Converting error occurs */
            return count;
        }
    }

    return count;
}

/* Take in ucs4 and convert to utf8. */
static int ucs4_to_utf8(unsigned char *ch, unsigned int uc, int n)
{
    int count;

    if (uc < 0x80)
        count = 1;
    else if (uc < 0x800)
        count = 2;
    else if (uc < 0x10000)
        count = 3;
#if 0
    else if (uc < 0x200000)
        count = 4;
    else if (uc < 0x4000000)
        count = 5;
    else if (uc <= 0x7fffffff)
        count = 6;
#else
    else if (uc < 0x110000)
        count = 4;
#endif
    else
        return -1;

    if (n < count)
        return -2;

    switch (count) /* note: code falls through cases! */
    {
#if 0
        case 6: ch[5] = 0x80 | (uc & 0x3f); uc = uc >> 6; uc |= 0x4000000;
        case 5: ch[4] = 0x80 | (uc & 0x3f); uc = uc >> 6; uc |= 0x200000;
#endif
        case 4: ch[3] = 0x80 | (uc & 0x3f); uc = uc >> 6; uc |= 0x10000;
        case 3: ch[2] = 0x80 | (uc & 0x3f); uc = uc >> 6; uc |= 0x800;
        case 2: ch[1] = 0x80 | (uc & 0x3f); uc = uc >> 6; uc |= 0xc0;
        case 1: ch[0] = uc;
    }

    return count;
}

/* Take in unicode and convert to utf8. */
void unicode_to_utf8(unsigned int *unistr, long slen, char *utf8_str, long utf8_str_size)
{
    unsigned short w;
    long count;
    char autf8[8];
    char *p;
    int len;

    utf8_str[0] = 0;
    p = utf8_str;
    count = 0;

    while ((w = *unistr++)) {
        if ((slen != -1) && (++count > slen))
            break;

        len = ucs4_to_utf8((unsigned char *) autf8, w, slen);

        if (((p + len) - utf8_str) >= utf8_str_size )
            break;

        memcpy(p, autf8, len);
        p += len;
    }
}
