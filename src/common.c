#include "common.h"
#include "pcat.h"

/* Pre/post: common variables. */
char remoteos[16] = {0};
char datadir[4096] = {0};
char cachedir[4096] = {0};

/* Pre/post: write messages to stdout. */
void print_message(const char *src)
{
    const char help[] = 
    "\n"
    "Usage: post <option> <arguments>\n"
    "\n"
    "  set  os [bsd|linux|windows]                        set remote operating system\n"
    "  show [system|users|process|network|pe|exploits]    show information\n"
    "  run  tty                                           spawn tty shell\n"
    "  pull [tools|exploits] <dir>                        download and install package\n"
    "  doc  [iptables|ssh|sql|pe]                         show cheatsheet\n"
    "  help                                               show help\n"
    "\n"
    "  windows: cmd shell is mandatory\n";

    if (src != NULL)
        Write(STDOUT_FILENO, src, strlen(src));
    else
        Write(STDOUT_FILENO, help, strlen(help));
}
