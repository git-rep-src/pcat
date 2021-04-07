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
    "  set  os (bsd|linux|windows)                      Set remote operating system.\n"
    "  show (system|users|process|network|pe|exploits)  Show information.\n"
    "  run  tty                                         Spawn TTY shell.\n"
    "  pull (tools|exploits) <dir>                      Download and install package.\n"
    "  doc  (iptables|ssh|sql|pe)                       Show cheatsheet.\n"
    "  help                                             Show help.\n"
    "\n"
    "  Windows: cmd shell is mandatory.\n";

    if (src != NULL)
        Write(STDOUT_FILENO, src, strlen(src));
    else
        Write(STDOUT_FILENO, help, strlen(help));
}
/*
void print_message(const char *src)
{
    const char help[] = 
    "\n"
    "Usage: post <option> <arguments>\n"
    "\n"
    "  set  <arg> <arg>  set variable\n"
    "                    os bsd|linux|windows\n"
    "  show <arg>        show information\n"
    "                    system|users|process|network|pe|exploits\n"
    "  run  <arg>        run script\n"
    "                    tty\n"
    "  pull <arg> <dir>  install package\n"
    "                    tools|exploits\n"
    "  doc  <arg>        print cheatsheet\n"
    "                    iptables|pe|ssh|sql\n"
    "  help              show help\n"
    "\n"
    "  windows: cmd shell is mandatory\n";

    if (src != NULL)
        Write(STDOUT_FILENO, src, strlen(src));
    else
        Write(STDOUT_FILENO, help, strlen(help));
}
*/
