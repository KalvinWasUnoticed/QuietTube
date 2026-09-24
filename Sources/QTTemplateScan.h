#ifndef QT_TEMPLATE_SCAN_H
#define QT_TEMPLATE_SCAN_H
#include <stddef.h>
#include <string.h>
/* Lexical diagnostic only: a .eml token is NOT proof of a root template.
 * This function neither parses protobuf schemas nor changes/filter payloads. */
static int QTTemplateChar(unsigned char c) {
    return (c>='a'&&c<='z') || (c>='0'&&c<='9') || c=='_' || c=='.' || c=='-';
}
static size_t QTExtractTemplateNames(const unsigned char *data, size_t length,
                                    char names[][97], size_t capacity) {
    if (!data || length>262144 || !names || !capacity) return 0;
    size_t found=0,i=0;
    while (i<length && found<capacity) {
        if (!QTTemplateChar(data[i])) { i++; continue; }
        size_t start=i;
        while (i<length && QTTemplateChar(data[i])) i++;
        size_t n=i-start;
        if (n<5 || n>96 || data[start]<'a' || data[start]>'z') continue;
        if (memcmp(data+i-4,".eml",4)) continue;
        // Do not extract suffixes from obvious URLs, paths, emails or identifiers.
        if (start && ((data[start-1]>='A'&&data[start-1]<='Z') ||
            data[start-1]=='/' || data[start-1]=='@' || data[start-1]==':' || data[start-1]=='=')) continue;
        if (i<length && ((data[i]>='A'&&data[i]<='Z') || data[i]=='/' ||
            data[i]=='?' || data[i]=='=' || data[i]=='@')) continue;
        int duplicate=0;
        for (size_t j=0;j<found;j++)
            if (strlen(names[j])==n && !memcmp(names[j],data+start,n)) { duplicate=1; break; }
        if (duplicate) continue;
        memcpy(names[found],data+start,n);
        names[found][n]=0;
        found++;
    }
    return found;
}
#endif
