#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static long test_count = 0;
static long success_count = 0;
char **cmdline_split(const char *cmdexec);

int test_cmdline(const char *line, const char **target_args)
{
    char **cmd_args;
    int args_match = 1;

    test_count++;

    cmd_args = cmdline_split(line);

    /*
     * Make sure that all of the target arguments are have been extracted
     * by cmdline_split.
     */
    while (*cmd_args && *target_args) {
        if (strcmp(*cmd_args, *target_args)) {
            args_match = 0;
            break;
        }
        cmd_args++;
        target_args++;
    }
    if ((*cmd_args != NULL) || (*target_args != NULL)) {
        /*
         * One of the argument list had more arguments than the other.
         * Therefore, they do not match
         */
        args_match = 0;
    }

    if (args_match) {
        success_count++;
        printf("PASS '%s'\n", line);
        return 1;
    } else {
        printf("FAIL '%s'\n", line);
        return 0;
    }
}

int test_cmdline_fail(const char *line)
{
    char **cmd_args;

    test_count++;

    cmd_args = cmdline_split(line);

    if (*cmd_args == NULL) {
        success_count++;
        printf("PASS '%s'\n", line);
        return 1;
    } else {
        printf("PASS '%s'\n", line);
        return 0;
    }
}

int main(int argc, char *argv[])
{
    int i;

    struct {
        const char *cmdexec;
        const char *args[10];
    } TEST_CASES[] = {
        {"pcat -l -k", {"pcat", "-l", "-k", NULL}},
        {"pcat localhost 793", {"pcat", "localhost", "793", NULL}},
        {"./pcat scanme.nmap.org 80", {"./pcat", "scanme.nmap.org", "80",
                                       NULL}},
        {"t\\ p\\ s hello world how are you?", {"t p s", "hello", "world", "how", "are",
                                              "you?", NULL}},
        {"t\\ p\\ s hello world how\\ are you?", {"t p s", "hello", "world", "how are",
                                               "you?", NULL}},
        {"pcat\\", {"pcat", NULL}},
        {"a\\nb", {"anb", NULL}},
        {" pcat a ", {"pcat", "a", NULL}},
        {"\\pcat \\a", {"pcat", "a", NULL}},
        {"pcat\\\\ a", {"pcat\\", "a", NULL}},
        {"pcat\\", {"pcat", NULL}},
        {"pcat\\ \\", {"pcat ", NULL}},
    };

    for (i = 0; i < sizeof(TEST_CASES)/sizeof(TEST_CASES[0]); i++) {
        test_cmdline(TEST_CASES[i].cmdexec,
                     TEST_CASES[i].args);
    }

    test_cmdline_fail("");
    printf("%ld / %ld tests passed.\n", success_count, test_count);
    return success_count == test_count ? 0 : 1;
}
