#include "../pcat.h"
#include "../base64.h"
#include "../file.h"

#include <libxml/parser.h>

/* Size of ret on strbuf_sprintf */
static size_t size;
/* Offset of ret on strbuf_sprintf */
static size_t offset;

/* Set remote operating system full name. */
static int set_remoteos_fullname(char *src, char *remoteos_fullname)
{
    int i = 0;
    
    memset(remoteos_fullname, 0, 16);

    while (src[i] != '\0') {
        if (src[i] >= 'a' && src[i] <= 'z')
            src[i] = (src[i] - 32);
        ++i;
    }

    if (strstr(src, "FREEBSD") != NULL)
        strcpy(remoteos_fullname, "FREEBSD");
    else if (strstr(src, "NETBSD") != NULL)
        strcpy(remoteos_fullname, "NETBSD");
    else if (strstr(src, "OPENBSD") != NULL)
        strcpy(remoteos_fullname, "OPENBSD");
    else if (strstr(src, "LINUX") != NULL)
        strcpy(remoteos_fullname, "LINUX");
    else if (strstr(src, "WINDOWS") != NULL)
        strcpy(remoteos_fullname, "WINDOWS");
    else
        return 0;

    return 1;
}

/* Compare kernel versions. */
static int is_vulnerable(char *exploit_versions, const char *remoteos_fullname, const char *remote_version)
{
    int v1 = 0;
    int v2 = 0;
    int first = 1;
    int any = 0;
    int vuln = 1;
    char *exploit_version = NULL;
    char delimiter;

    if (strcmp(remoteos_fullname, "WINDOWS") == 0)
        delimiter = ':';
    else
        delimiter = '.';

    if (strstr(exploit_versions, "-") == NULL) {
        if (strcmp(exploit_versions, remote_version) != 0)
            return 0;
        else 
            return 1;
    } else {
        exploit_version = strtok(exploit_versions, "-");
    }

    while (exploit_version != NULL) {
        for (int i = 0, ii = 0; ((i < strlen(exploit_version)) || (ii < strlen(remote_version)));) {
            while ((i < strlen(exploit_version)) && (exploit_version[i] != delimiter)) {
                if (exploit_version[i] != '*')
                    v1 = ((v1 * 10) + (exploit_version[i] - '0'));
                else
                    any = 1;
                i++;
            }

            while ((ii < strlen(remote_version)) && (remote_version[ii] != delimiter)) {
                v2 = ((v2 * 10) + (remote_version[ii] - '0'));
                ii++;
            }

            if (!any) {
                if (strcmp(remoteos_fullname, "WINDOWS") != 0) {
                    if (first) {
                        if (v1 > v2) {
                            vuln = 0;
                            v1 = 0;
                            v2 = 0;
                            any = 0;
                            break;
                        } else if (v1 < v2) {
                            v1 = 0;
                            v2 = 0;
                            any = 0;
                            break;
                        }
                    } else {
                        if (v1 < v2) {
                            vuln = 0;
                            v1 = 0;
                            v2 = 0;
                            any = 0;
                            break;
                        } else if (v1 > v2) {
                            v1 = 0;
                            v2 = 0;
                            any = 0;
                            break;
                        }
                    }
                } else {
                    if (v1 != v2)
                        vuln = 0;
                }
            }

            v1 = 0;
            v2 = 0;
            any = 0;

            i++;
            ii++;
        }

        if (strcmp(remoteos_fullname, "WINDOWS") == 0) {
            exploit_version = strtok(NULL, "-");
            if (vuln) {
                break;
            } else {
                if (exploit_version != NULL)
                    vuln = 1;
                else 
                    return 0;
            }
        } else {
            exploit_version = strtok(NULL, "\n\r");
            if (!vuln)
                return 0;
            first = 0;
        }
    }

    return 1;
}

/* Indent data. */
static void indent(const char *name, char *src, int namemax, char **ret)
{
    int count = 0;
    int n = 4;
    int nn = 4;
    const char *pad = "......................................................................................";
    char *token = NULL;

    if (strcmp(name, "NONE") != 0) {
        n = ((namemax - strlen(name)) + 4);
        nn = (4 + strlen(name) + n);
    }

    token = strtok(src, "\n\r");

    while (token != NULL) {
        if (count == 0) {
            if (strcmp(name, "NONE") == 0)
                strbuf_sprintf(ret, &size, &offset, "\n%*c%s", n, ' ', trim_leading(token));
            else
                strbuf_sprintf(ret, &size, &offset, "%*.*s%s", n, n, pad, trim_leading(token));
        } else {
            strbuf_sprintf(ret, &size, &offset, "\n%*c%s", nn, ' ', trim_leading(token));
        }

        token = strtok(NULL, "\n\r"); 
        ++count;
    }
}

/* Parse XML command output status. */
static void xml_parse_status(xmlNode *node)
{
    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (is_xml_leaf(node)) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "STATUS")) {
                    if (!xmlStrcmp((const xmlChar *) xmlNodeGetContent(node), (const xmlChar *) "FAIL")) {
                        loguser("Command failed.\n");
                        break;
                    }
                }
            } 
        }

        xml_parse_status(node->children);
        node = node->next;
    }
}

/* Parse XML 'show' command output. */
static void xml_parse(xmlNode *node, char **ret)
{
    static int last = 0;
    static int namemax = 0;

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (is_xml_leaf(node)) {
                if (xmlStrcmp(node->name, (const xmlChar *) "NONE"))
                    strbuf_sprintf(ret, &size, &offset, "\n    %s%s%s", "\033[1m", (char *) node->name, "\033[0m");
                indent((const char *) node->name, (char *) xmlNodeGetContent(node), namemax, ret);
                if (node->next == NULL) {
                    if (!last) {
                        strbuf_sprintf(ret, &size, &offset, "\n");
                    } else {
                        strbuf_sprintf(ret, &size, &offset, "\n\n");
                        last = 0;
                    }
                }
            } else {
                if (!xmlStrcmp(node->name, (const xmlChar *) "DATA")) {
                    namemax = atoi((char *) xmlGetProp(node, (const xmlChar *) "namemax"));
                } else {
                    strbuf_sprintf(ret, &size, &offset, "\n%s%s%s", "\033[1m", (char *) node->name, "\033[0m");
                    if (node->next == NULL)
                        last = 1;
                }
            }

        }

        xml_parse(node->children, ret);
        node = node->next;
    }
}

/* Parse XML 'exploits' command output. */
static int xml_parse_exploits(xmlNode *node, char **ret)
{
    static int first = 1;
    static int match = 0;
    static int os_match = 0;
    static int exploit = 0;
    static char remoteos_fullname[16];
    static char *remote_version = NULL;
    static char *remote_config = NULL;
    static char *remote_sysctl = NULL;
    static char *remote_arch = NULL;
    xmlNode *tempnode = NULL;

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (remote_arch == NULL) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "OS")) {
                    if (!set_remoteos_fullname((char *) xmlNodeGetContent(node), remoteos_fullname))
                        return 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "VERSION")) {
                    if ((remote_version = (char *) xmlNodeGetContent(node)) == NULL)
                        return 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "CONFIG")) {
                    if ((remote_config = (char *) xmlNodeGetContent(node)) == NULL)
                        return 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "SYSCTL")) {
                    if ((remote_sysctl = (char *) xmlNodeGetContent(node)) == NULL)
                        return 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "ARCH")) {
                    if ((remote_arch = (char *) xmlNodeGetContent(node)) == NULL)
                        return 0;
                }
            } else {
                if (is_xml_leaf(node)) {
                    if (os_match) {
                        if (!xmlStrcmp(node->name, (const xmlChar *) "CVE")) {
                            tempnode = node->next->next;
                            match = is_vulnerable((char *) xmlNodeGetContent(tempnode), remoteos_fullname, remote_version);
                            tempnode = tempnode->next->next;
                            if (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) "") && match) {
                                if (strstr(remote_config, (char *) xmlNodeGetContent(tempnode)) == NULL)
                                    match = 0;
                            }
                            tempnode = tempnode->next->next;
                            if (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) "") && match) {
                                if (strstr(remote_sysctl, (char *) xmlNodeGetContent(tempnode)) == NULL)
                                    match = 0;
                            }
                            tempnode = tempnode->next->next;
                            if (xmlStrcmp((const xmlChar *) xmlNodeGetContent(tempnode), (const xmlChar *) "") && match) {
                                if (strcmp(remote_arch, (char *) xmlNodeGetContent(tempnode)) != 0)
                                    match = 0;
                            }
                        }

                        if (xmlStrcmp(node->name, (const xmlChar *) "CONFIG") && xmlStrcmp(node->name, (const xmlChar *) "SYSCTL") && 
                            xmlStrcmp(node->name, (const xmlChar *) "ARCH") && match) {
                            if (!xmlStrcmp(node->name, (const xmlChar *) "TXT"))
                                match = 0;
                            if (xmlStrcmp((const xmlChar *) xmlNodeGetContent(node), (const xmlChar *) "")) {
                                if (!xmlStrcmp(node->name, (const xmlChar *) "CVE") && !first)
                                    strbuf_sprintf(ret, &size, &offset, "\n");
                                else
                                    first = 0;
                                strbuf_sprintf(ret, &size, &offset, "\n    %s%s%s", "\033[1m", (char *) node->name, "\033[0m");
                                indent((const char *) node->name, (char *) xmlNodeGetContent(node), 7, ret);
                                exploit = 1;
                            }
                        }
                    }
                } else {
                    if (!os_match) { 
                        if (!xmlStrcmp(node->name, (const xmlChar *) remoteos_fullname)) {
                            strbuf_sprintf(ret, &size, &offset, "\n%s%s%s", "\033[1m", "KERNEL", "\033[0m");
                            os_match = 1;
                        }
                    } else {
                        if (xmlStrcmp(node->name, (const xmlChar *) "KERNEL")) {
                            match = 0;
                            os_match = 0;
               
                            remote_version = NULL;
                            remote_config = NULL;
                            remote_sysctl = NULL;
                            remote_arch = NULL;

                            if (!exploit) {
                                strbuf_sprintf(ret, &size, &offset, "\n    No\n \n");
                            } else {
                                strbuf_sprintf(ret, &size, &offset, "\n \n");
                                exploit = 0;
                                break;
                            }
                        }
                    }
                }
            }
        }
       
        xml_parse_exploits(node->children, ret);
        node = node->next;
    }

    return 1;
}

/* Parse XML 'cp' command output. */
static void xml_parse_cp(xmlNode *node)
{
    size_t len;
    static char filepath[PATH_MAX];
    char *ret = NULL; 

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (is_xml_leaf(node)) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "FILEPATH")) {
                    if (is_pathmax("file", strlen((char *) xmlNodeGetContent(node))))
                        strcpy(filepath, (char *) xmlNodeGetContent(node));
                    else
                        break;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "SRC")) {
                    ret = b64dec((const unsigned char *) xmlNodeGetContent(node),
                                 strlen((char *) xmlNodeGetContent(node)), &len);
                    if ((ret == NULL) || !write_file(filepath, ret, len))
                        loguser("Command failed.\n");
                    break;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "STATUS")) {
                    xml_parse_status(node);
                    break;
                }
            } 
        }

        xml_parse_cp(node->children);
        node = node->next;
    }
                    
    if (ret != NULL)
        free(ret);
}

/* Process XML command output. */
char *cmd_parse(const char *src, char *_name)
{
    size = 0;
    offset = 0;
    char type[NAME_MAX];
    char name[NAME_MAX];
    char filepath[PATH_MAX];
    char *buf = NULL;
    char *ret = NULL;
    xmlDocPtr doc;
    xmlNode *root = NULL;

    buf = strstr(src, "<DATA");
        
    if ((doc = xmlReadMemory(buf, strlen(buf), NULL, NULL, 1|32|64)) != NULL) {
        root = xmlDocGetRootElement(doc);

        strcpy(type, (char *) xmlGetProp(root, (const xmlChar *) "type"));
        strcpy(name, (char *) xmlGetProp(root, (const xmlChar *) "name"));
        strcpy(_name, (char *) xmlGetProp(root, (const xmlChar *) "name"));

        if (strcmp(type, "show") == 0) {
            if (strcmp(name, "exploits") == 0) {
                if (xml_parse_exploits(root, NULL)) {
                    if (is_pathmax("exploits", (strlen(datadir) + 24))) {
                        sprintf(filepath, "%s%s", datadir, "/exploits/data.xml");

                        if ((doc = xmlReadFile(filepath, NULL, 0)) != NULL) { 
                            root = xmlDocGetRootElement(doc);
                            xml_parse_exploits(root, &ret);
                        } else {
                            loguser("Can't read exploits XML document.\n");
                        }
                    }
                }
            } else {
                xml_parse(root, &ret);
            }
        } else if (strcmp(type, "cp") == 0) {
            xml_parse_cp(root);
        } else if (strcmp(type, "get") == 0) {
            xml_parse_status(root);
        }

        xmlFreeDoc(doc);
        xmlCleanupParser();
    } else {
        loguser("Can't parse XML command output.\n");
    }

    return ret;
}
