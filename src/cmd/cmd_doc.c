#include "../pcat.h"

#include <libxml/parser.h>

/* Size of ret on strbuf_sprintf */
static size_t size;
/* Offset of ret on strbuf_sprintf */
static size_t offset;

/* Indent data. */
static void indent(char *src, char **ret)
{
    char *token = NULL;

    token = strtok(src, "\n\r");

    while (token != NULL) {
        strbuf_sprintf(ret, &size, &offset, "    %s\n", trim_leading(token));
        token = strtok(NULL, "\n\r"); 
    }
}

/* Parse XML data. */
static void xml_parse(xmlNode *node, char **ret)
{
    while (node) {
        if (node->type == XML_ELEMENT_NODE) {
            if (is_xml_leaf(node)) {
                if (!xmlStrcmp(node->name, (const xmlChar *) "TITLE"))
                    strbuf_sprintf(ret, &size, &offset, "\n    %s%s%s\n", "\033[1m", (char *) xmlNodeGetContent(node), "\033[0m");
                else if (!xmlStrcmp(node->name, (const xmlChar *) "CONTENT"))
                    indent((char *) xmlNodeGetContent(node), ret);
            } else {
                if (xmlStrcmp(node->name, (const xmlChar *) "DATA")) 
                    strbuf_sprintf(ret, &size, &offset, "\n%s%s%s", "\033[1m", (char *) node->name, "\033[0m");
            }
        }
       
        xml_parse(node->children, ret);
        node = node->next;
    }
}

/* Read document and write it to stdout. */
void cmd_doc(const char *name)
{
    size = 0;
    offset = 0;
    char filepath[PATH_MAX];
    char *ret = NULL;
    xmlDocPtr doc;
    xmlNode *root = NULL;
        
    if (is_pathmax("doc", (strlen(datadir) + strlen(name) + 24))) {
        sprintf(filepath, "%s%s%s%s", datadir, "/docs/", name, ".xml");

        if ((doc = xmlReadFile(filepath, NULL, 0)) != NULL) { 
            root = xmlDocGetRootElement(doc);
            
            xml_parse(root, &ret);

            xmlFreeDoc(doc);
            xmlCleanupParser();
        } else {
            loguser("Can't read '%s' document. Try ':help'.\n", name);
        }
    } 
   
    if (ret != NULL) {
        Write(STDOUT_FILENO, ret, strlen(ret));
        free(ret);
    }
}
