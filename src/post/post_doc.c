#include "../pcat.h"
#include "../common.h"
#include "../file.h"

#include <libxml/parser.h>

/* Trim white spaces. */
static char *trim(char *src)
{
    while(isspace(*src))
        src++;

    return src;
}

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
static char *xml_indent_content(xmlNode *node)
{
    char *buf = NULL;
    char *tempbuf = NULL;
    char *token = NULL;
    char *ret = NULL;

    token = strtok((char *) xmlNodeGetContent(node), "\n\r");

    while (token != NULL) {
        if (ret == NULL) {
            tempbuf = trim(token);

            ret = (char *) safe_malloc(strlen(tempbuf) + 8);
            ret[0] = '\0';

            sprintf(ret, "%*c%s\n", 4, ' ', tempbuf);
        } else {
            tempbuf = trim(token);

            if (tempbuf[0] != '\0') {
                buf = (char *) safe_malloc(strlen(tempbuf) + 8);
                buf[0] = '\0';
            
                sprintf(buf, "%*c%s\n", 4, ' ', tempbuf);
            
                ret = (char *) safe_realloc(ret, (strlen(ret) + strlen(buf)));
            
                strcat(ret, buf);

                free(buf);
                buf = NULL;
            }
        }

        token = strtok(NULL, "\n\r"); 
    }

    return ret;
}

/* Parse XML content. */
static void xml_parse(xmlNode *node, char **ret)
{
    static int is_first = 1;
    char *buf = NULL;

    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (xml_is_leaf(node)) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "TITLE")) {
                    buf = (char *) safe_malloc(strlen((char *) xmlNodeGetContent(node)) + 24);

                    if (is_first)
                        sprintf(buf, "%*c%s%s%s\n", 4, ' ', "\033[1m", (char *) xmlNodeGetContent(node), "\033[0m");
                    else
                        sprintf(buf, "\n%*c%s%s%s\n", 4, ' ', "\033[1m", (char *) xmlNodeGetContent(node), "\033[0m");

                    is_first = 0;
                } else if (!xmlStrcmp(node->name, (const xmlChar *) "CONTENT")) {
                    buf = xml_indent_content(node);
                }
            } else {
                if (xmlStrcmp(node->name, (const xmlChar *) "DATA")) {
                    buf = (char *) safe_malloc(strlen((char *) node->name) + 24);
                    sprintf(buf, "\n%s%s%s\n", "\033[1m", (char *) node->name, "\033[0m");

                    is_first = 1;
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

/* Read doc file from disk and write it to stdout. */
void post_doc(const char *name)
{
    size_t pathlen;
    char *filepath = NULL;
    char *ret = NULL;
    xmlDocPtr doc;
    xmlNode *root = NULL;

    pathlen = (strlen(datadir) + strlen(name) + 24);
        
    if (is_maxpath(pathlen)) {
        filepath = (char *) safe_malloc(pathlen);
      
        strcpy(filepath, datadir);
        strcat(filepath, "/docs/");
        strcat(filepath, name);
        strcat(filepath, ".xml");

        if ((doc = xmlReadFile(filepath, NULL, 0)) != NULL) { 
            root = xmlDocGetRootElement(doc);
            
            xml_parse(root, &ret);
            
            xmlFreeDoc(doc);
            xmlCleanupParser();
        } else {
            print_message(NULL);
        }
        
        free(filepath);
    } else {
        print_message("Post: File path is greater than MAX_PATH.\n");
    }
   
    if (ret != NULL) {
        Write(STDOUT_FILENO, ret, strlen(ret));

        free(ret);
    }
}
