#ifndef QT_TEMPLATE_SCAN_H
#define QT_TEMPLATE_SCAN_H
#include <stddef.h>
#include <string.h>
/* Diagnostic lexical extractor, not a protobuf/root-template decoder.
 * Capture names only. Never change the caller's payload or filter decision. */
static int QTTemplateChar(unsigned char c) {
    return (c>='a'&&c<='z') || (c>='0'&&c<='9') || c=='_' || c=='.' || c=='-';
}
static int QTIdentifierFamily(const unsigned char *name, size_t n) {
    static const char *families[]={"shelf","video","lockup","inline","portrait",
        "thumbnail","banner","layout","carousel","feed","shorts","promoted",
        "sponsor","ad","ads","display","chips","topic","reel"};
    int structured=0;
    for (size_t i=0;i<n;i++) if (name[i]=='_') structured=1;
    if (!structured) return 0; /* Don't log ordinary words from titles/prose. */
    for (size_t f=0;f<sizeof(families)/sizeof(families[0]);f++) {
        size_t len=strlen(families[f]);
        if (len>n) continue;
        for (size_t i=0;i<=n-len;i++) {
            if (i && name[i-1]!='_' && name[i-1]!='.' && name[i-1]!='-') continue;
            if (memcmp(name+i,families[f],len)) continue;
            if (i+len<n && name[i+len]!='_' && name[i+len]!='.' && name[i+len]!='-') continue;
            return 1;
        }
    }
    return 0;
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
        if (n<3 || n>96 || data[start]<'a' || data[start]>'z') continue;
        int suffix=(n>=5 && !memcmp(data+i-4,".eml",4)) ||
                   (n>=3 && !memcmp(data+i-2,".e",2));
        if (!suffix && !QTIdentifierFamily(data+start,n)) continue;
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
