#include "../pcat.h"
#include "../common.h"
#include "../file.h"
#include "post_cache.h"

#include <libxml/parser.h>

/* Is XML leaf?. */
static int xml_is_leaf(xmlNode *node)
{
    xmlNode *child = node->children;

    while (child) {
        if (child->type == XML_ELEMENT_NODE)
            return 0;
        
        child = child->next;
    } 

    return 1;
}

/* Ident XML content. */
static char *xml_indent_content(xmlNode *node, int maxlen)
{
    int indent = 4;
    int indent_multiline = 4;
    const char *pad = "......................................................................................";
    char *buf = NULL;
    char *token = NULL;
    char *ret = NULL;

    if (xmlStrcmp(node->name, (const xmlChar *) "NONE")) {
        indent = ((maxlen - strlen((char *) node->name)) + 4);
        indent_multiline = (4 + strlen((char *) node->name) + indent);
    }

    token = strtok((char *) xmlNodeGetContent(node), "\n\r");

    while (token != NULL) {
        if (ret == NULL) {
            ret = (char *) safe_malloc(indent + strlen(token) + 1);
            ret[0] = '\0';

            if (!xmlStrcmp(node->name, (const xmlChar *) "NONE"))
                sprintf(ret, "%*c%s", indent, ' ', token);
            else
                sprintf(ret, "%*.*s%s", indent, indent, pad, token);
        } else {
            buf = (char *) safe_malloc(indent_multiline + strlen(token) + 1);
            buf[0] = '\0';
            
            sprintf(buf, "%*c%s", indent_multiline, ' ', token);
            
            ret = (char *) safe_realloc(ret, (strlen(ret) + strlen(buf) + 2));
            
            strcat(ret, "\n");
            strcat(ret, buf);

            free(buf);
            buf = NULL;
        }

        token = strtok(NULL, "\n\r"); 
    }

    return ret;
}

/* Parse XML remote system response (show). */
static void xml_parse(xmlNode *node, char **ret)
{
    static int maxlen = 0;
    char *buf = NULL;
    char *tempbuf = NULL;

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (xml_is_leaf(node)) {
                if ((tempbuf = xml_indent_content(node, maxlen)) != NULL) {
                    if (!xmlStrcmp(node->name, (const xmlChar *) "NONE")) {
                        buf = (char *) safe_malloc(strlen(tempbuf) + 1);
                        sprintf(buf, "%s\n", tempbuf);
                    } else {
                        buf = (char *) safe_malloc(strlen((char *) node->name) + strlen(tempbuf) + 24);
                        sprintf(buf, "%*c%s%s%s%s\n", 4, ' ', "\033[1m", (char *) node->name, "\033[0m", tempbuf);
                    }
                    
                    free(tempbuf);
                    tempbuf = NULL;
                }
            } else {
                if (!xmlStrcmp(node->name, (const xmlChar *) "DATA")) {
                    maxlen = atoi((char *) xmlGetProp(node, (const xmlChar *) "maxlen"));
                } else {
                    buf = (char *) safe_malloc(strlen((char *) node->name) + 24);
                    sprintf(buf, "\n%s%s%s\n", "\033[1m", (char *) node->name, "\033[0m");
                }
            }

            if (buf != NULL) {
                if (*ret == NULL) {
                    *ret = (char *) safe_malloc(strlen(buf) + 1);
                    strcpy(*ret, buf);
                } else {
                    *ret = (char *) safe_realloc(*ret, (strlen(*ret) + strlen(buf) + 1));
                    strcat(*ret, buf);
                }
              
                free(buf);
                buf = NULL;
            }
        }
       
        xml_parse(node->children, ret);
        node = node->next;
    }
}

/* Set remote operating system full name (exploits). */
static int set_remoteos_fullname(char *src, char **remoteos_fullname)
{
    int i = 0;
    
    while (src[i] != '\0') {
        if (src[i] >= 'a' && src[i] <= 'z')
            src[i] = (src[i] - 32);
        ++i;
    }
    
    *remoteos_fullname = (char *) safe_malloc(16);

    if (strstr(src, "FREEBSD") != NULL)
        strcpy(*remoteos_fullname, "FREEBSD");
    else if (strstr(src, "NETBSD") != NULL)
        strcpy(*remoteos_fullname, "NETBSD");
    else if (strstr(src, "OPENBSD") != NULL)
        strcpy(*remoteos_fullname, "OPENBSD");
    else if (strstr(src, "LINUX") != NULL)
        strcpy(*remoteos_fullname, "LINUX");
    else if (strstr(src, "WINDOWS") != NULL)
        strcpy(*remoteos_fullname, "WINDOWS");
    else
        return 0;

    return 1;
}

/* Compare kernel versions (exploits). */
static int is_vulnerable(const char *exploit_versions, const char *remoteos_fullname,
                         const char *remote_version)
{
    int v1 = 0;
    int v2 = 0;
    int is_first = 1;
    int is_any = 0;
    int is_vuln = 1;
    char *buf = strdup(exploit_versions);
    char *exploit_version = NULL;
    char delimiter;

    if (strcmp(remoteos_fullname, "WINDOWS") == 0)
        delimiter = ':';
    else
        delimiter = '.';

    if (strstr(buf, "-") != NULL)
        exploit_version = strtok(buf, "-");
    else
        exploit_version = strtok(buf, "\n\r");

    if (strcmp(exploit_versions, exploit_version) == 0) {
        if (strcmp(exploit_version, remote_version) != 0) {
            free(buf);

            return 0;
        } else { 
            free(buf);

            return 1;
        }
    }

    while (exploit_version != NULL) {
        for (int i = 0, ii = 0; ((i < strlen(exploit_version)) || (ii < strlen(remote_version)));) {
            while ((i < strlen(exploit_version)) && (exploit_version[i] != delimiter)) {
                if (exploit_version[i] != '*')
                    v1 = ((v1 * 10) + (exploit_version[i] - '0'));
                else
                    is_any = 1;
                i++;
            }

            while ((ii < strlen(remote_version)) && (remote_version[ii] != delimiter)) {
                v2 = ((v2 * 10) + (remote_version[ii] - '0'));
                ii++;
            }

            if (!is_any) {
                if (strcmp(remoteos_fullname, "WINDOWS") != 0) {
                    if (is_first) {
                        if (v1 > v2) {
                            is_vuln = 0;
                            v1 = 0;
                            v2 = 0;
                            is_any = 0;

                            break;
                        } else if (v1 < v2) {
                            v1 = 0;
                            v2 = 0;
                            is_any = 0;

                            break;
                        }
                    } else {
                        if (v1 < v2) {
                            is_vuln = 0;
                            v1 = 0;
                            v2 = 0;
                            is_any = 0;

                            break;
                        } else if (v1 > v2) {
                            v1 = 0;
                            v2 = 0;
                            is_any = 0;

                            break;
                        }
                    }
                } else {
                    if (v1 != v2)
                        is_vuln = 0;
                }
            }

            v1 = 0;
            v2 = 0;
            is_any = 0;

            i++;
            ii++;
        }

        if (strcmp(remoteos_fullname, "WINDOWS") == 0) {
            exploit_version = strtok(NULL, "-");
            
            if (is_vuln) {
                break;
            } else {
                if (exploit_version != NULL) {
                    is_vuln = 1;
                } else {
                    free(buf);

                    return 0;
                }
            }
        } else {
            exploit_version = strtok(NULL, "\n\r");
            
            if (!is_vuln) {
                free(buf);

                return 0;
            }

            is_first = 0;
        }
    }

    free(buf);

    return 1;
}

/* Parse XML remote system response (exploits). */
static int xml_parse_exploits(xmlNode *node, char **ret)
{
    static int is_first = 1;
    static int is_match = 0;
    static int is_os_match = 0;
    static int has_exploit = 0;
    char *buf = NULL;
    char *tempbuf = NULL;
    static char *remoteos_fullname = NULL;
    static char *remote_version = NULL;
    static char *remote_config = NULL;
    static char *remote_sysctl = NULL;
    static char *remote_arch = NULL;
    xmlNode *tempnode = NULL;

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (remote_arch == NULL) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "OS")) {
                    if (!set_remoteos_fullname((char *) xmlNodeGetContent(node), &remoteos_fullname))
                        return 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "VERSION")) {
                    remote_version = (char *) xmlNodeGetContent(node);
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "CONFIG")) {
                    remote_config = (char *) xmlNodeGetContent(node);
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "SYSCTL")) {
                    remote_sysctl = (char *) xmlNodeGetContent(node);
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "ARCH")) {
                    remote_arch = (char *) xmlNodeGetContent(node);
                }
            } else {
                if (xml_is_leaf(node)) {
                    if (is_os_match) {
                        if (!xmlStrcmp(node->name, (const xmlChar *) "CVE")) {
                            tempnode = node->next->next;
                            is_match = is_vulnerable((const char *) xmlNodeGetContent(tempnode),
                                                      remoteos_fullname, remote_version);
                           
                            tempnode = tempnode->next->next;
                            if (is_match && 
                                (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) ""))) {
                                if (strstr(remote_config, (char *) xmlNodeGetContent(tempnode)) == NULL)
                                    is_match = 0;
                            }
                        
                            tempnode = tempnode->next->next;
                            if (is_match && 
                                (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) ""))) {
                                if (strstr(remote_sysctl, (char *) xmlNodeGetContent(tempnode)) == NULL)
                                    is_match = 0;
                            }
                       
                            tempnode = tempnode->next->next;
                            if (is_match && 
                                (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) ""))) {
                                if (strcmp(remote_arch, (char *) xmlNodeGetContent(tempnode)) != 0)
                                    is_match = 0;
                            }
                        }

                        if (is_match && 
                            (xmlStrcmp(node->name, (const xmlChar *) "CONFIG")) &&
                            (xmlStrcmp(node->name, (const xmlChar *) "SYSCTL")) &&
                            (xmlStrcmp(node->name, (const xmlChar *) "ARCH"))) {
                            if (!xmlStrcmp(node->name, (const xmlChar *) "TXT"))
                                is_match = 0;

                            if (xmlStrcmp((const xmlChar *) xmlNodeGetContent(node), (const xmlChar *) "")) {
                                if ((tempbuf = xml_indent_content(node, 7)) != NULL) {
                                    buf = (char *) safe_malloc(strlen((char *) node->name) + strlen(tempbuf) + 24);
                                    
                                    if (!is_first && 
                                        (!xmlStrcmp(node->name, (const xmlChar *) "CVE"))) {
                                        sprintf(buf, "\n%*c%s%s%s%s\n", 4, ' ', "\033[1m", (char *) node->name, "\033[0m", tempbuf);
                                    } else {
                                        sprintf(buf, "%*c%s%s%s%s\n", 4, ' ', "\033[1m", (char *) node->name, "\033[0m", tempbuf);
                                        is_first = 0;
                                    }
                                        
                                    has_exploit = 1;

                                    free(tempbuf);
                                    tempbuf = NULL;
                                }
                            }
                        }
                    }
                } else {
                    if (!is_os_match) { 
                        if (!xmlStrcmp(node->name, (const xmlChar *) remoteos_fullname)) {
                            buf = (char *) safe_malloc(24);
                            sprintf(buf, "\n%s%s%s\n", "\033[1m", "KERNEL", "\033[0m");
                    
                            is_os_match = 1;
                        }
                    } else {
                        if (xmlStrcmp(node->name, (const xmlChar *) "KERNEL")) {
                            is_os_match = 0;
                            is_match = 0;
               
                            free(remoteos_fullname);
                            remoteos_fullname = NULL;
                            remote_version = NULL;
                            remote_config = NULL;
                            remote_sysctl = NULL;
                            remote_arch = NULL;

                            if (!has_exploit) {
                                buf = (char *) safe_malloc(16);
                                sprintf(buf, "%s\n", "    No");
                            } else {
                                has_exploit = 0;
                                break;
                            }
                        }
                    }
                }
            }

            if (buf != NULL) {
                if (*ret == NULL) {
                    *ret = (char *) safe_malloc(strlen(buf) + 1);
                    strcpy(*ret, buf);
                } else {
                    *ret = (char *) safe_realloc(*ret, (strlen(*ret) + strlen(buf) + 1));
                    strcat(*ret, buf);
                }
                
                free(buf);
                buf = NULL;

                if (!is_os_match)
                    break;
            }
        }
       
        xml_parse_exploits(node->children, ret);
        node = node->next;
    }

    return 1;
}

/* Parse XML remote system status response (pull). */
static void xml_parse_status(xmlNode *node)
{
    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (xml_is_leaf(node)) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "STATUS")) {
                    if (!xmlStrcmp((const xmlChar *) xmlNodeGetContent(node), (const xmlChar *) "FAIL")) {
                        print_message("Post: Accion failed.\n");
                        break;
                    }
                }
            } 
        }

        xml_parse_status(node->children);
        node = node->next;
    }
}

/* Parse XML remote system response and write it to stdout. */
void post_parse(const char *src)
{
    size_t pathlen;
    char name[16];
    char *filepath = NULL;
    char *buf = NULL;
    char *ret = NULL;
    xmlDocPtr doc;
    xmlNode *root = NULL;

    buf = strstr(src, "<DATA");
        
    if ((doc = xmlReadMemory(buf, strlen(buf), NULL, NULL, 1|32|64)) != NULL) {
        root = xmlDocGetRootElement(doc);

        strcpy(name, (char *) xmlGetProp(root, (const xmlChar *) "name"));

        if (strcmp(name, "pull") == 0) {
            xml_parse_status(root);
        } else if (strcmp(name, "exploits") == 0) {
            if (xml_parse_exploits(root, NULL)) {
                pathlen = (strlen(datadir) + 24);
            
                if (is_maxpath(pathlen)) {
                    filepath = (char *) safe_malloc(pathlen);
                  
                    strcpy(filepath, datadir);
                    strcat(filepath, "/exploits/data.xml");

                    if ((doc = xmlReadFile(filepath, NULL, 0)) != NULL) { 
                        root = xmlDocGetRootElement(doc);
                        xml_parse_exploits(root, &ret);
                    }

                    free(filepath);
                }
            }
        } else {
            xml_parse(root, &ret);
        }

        xmlFreeDoc(doc);
        xmlCleanupParser();
    }

    if (ret != NULL) {
        Write(STDOUT_FILENO, ret, strlen(ret));

        if (!post_has_cache(name))
            post_cache(ret, name, 1);

        free(ret);
    }
}
