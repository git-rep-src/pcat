#ifndef CMD_INPUT_H
#define CMD_INPUT_H

int is_cmd(char *src, int nbytes);
void cmd_input(char *src, int nbytes, char **cmdbuf, int *cmdnbytes, int *cmdout);

#endif
