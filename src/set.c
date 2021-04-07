#include "pcat.h"
#include "common.h"
#include "file.h"

#include <pwd.h>

/* Pre/post: set remote operating system. */
void set_remoteos(const char *remote_os)
{
    if ((strcmp(remote_os, "bsd") == 0) ||
        (strcmp(remote_os, "linux") == 0) ||
        (strcmp(remote_os, "windows") == 0))
        strcpy(remoteos, remote_os);
    else
        print_message("Post: Remote operating system option is not valid. Try 'post help'.\n");
}

/* Pre/post: set data directory. */
void set_datadir()
{
    size_t pathlen;
    struct stat st;

    if ((stat("post", &st) == 0) && S_ISDIR(st.st_mode)) {
        strcpy(datadir, "post");
    } else { 
        pathlen = (strlen(PCAT_DATADIR) + 8);
        
        if (is_maxpath(pathlen)) {
            strcpy(datadir, PCAT_DATADIR);
            strcat(datadir, "/post");
        } else {
            print_message("Pcat: Data directory path is greater than MAX_PATH.\n");
        }
    }
}

/* Pre/post: set cache directory. */
void set_cachedir(const char *remoteaddr)
{
    int has_error = 0;
    size_t pathlen;
    char buf[16];
    char dirname[64];
    char dirpath[4096];
    uid_t uid;
    struct passwd *pw;
    struct stat st;
    time_t rawtime;
    struct tm * timeinfo;

    uid = getuid();
    pw = getpwuid(uid);

    if (pw != NULL) {
        strcpy(dirpath, pw->pw_dir);
        strcat(dirpath,"/.pcat");

        if (!((stat(dirpath, &st) == 0) && S_ISDIR(st.st_mode))) {
            if (mkdir(dirpath, 0700) != 0) {
                print_message("Pcat: Can't create cache directory. Try reinstalling Pcat.\n");
                has_error = 1;
            }
        }

        if (!has_error) {
            time(&rawtime);
            timeinfo = localtime(&rawtime);
            
            sprintf(buf, "-%02d.%02d-%02d:%02d", timeinfo->tm_mday,
                    timeinfo->tm_mon, timeinfo->tm_hour, timeinfo->tm_min);

            strcpy(dirname, remoteaddr);
            strcat(dirname, buf);
            
            pathlen = (strlen(dirpath) + strlen(dirname) + 1);
                
            if (is_maxpath(pathlen)) { 
                strcat(dirpath, "/");
                strcat(dirpath, dirname);

                if (!((stat(dirpath, &st) == 0) && S_ISDIR(st.st_mode))) {
                    if (mkdir(dirpath, 0700) != 0) {
                        print_message("Pcat: Can't create cache directory. Try reinstalling Pcat.\n");
                        has_error = 1;
                    }
                }

                if (!has_error)
                    strcpy(cachedir, dirpath);
            } else {
                print_message("Pcat: Cache directory path is greater than MAX_PATH.\n");
            }
        }
    } 
}
