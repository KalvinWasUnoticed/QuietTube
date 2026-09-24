#include "../Sources/QTTemplateScan.h"
#include <assert.h>
#include <stdio.h>
int main(void) {
    char names[8][97]={{0}};
    const char *sample="\x01video_card.eml\x00";
    assert(QTExtractTemplateNames((const unsigned char *)sample,strlen(sample),names,8)==1);
    assert(!strcmp(names[0],"video_card.eml"));
    const char *dup="video_card.eml video_card.eml shelf.eml";
    assert(QTExtractTemplateNames((const unsigned char *)dup,strlen(dup),names,8)==2);
    assert(QTExtractTemplateNames((const unsigned char *)dup,strlen(dup),names,1)==1);
    const char *urls="https://example.org/video_card.eml?token=abc user@name.eml /tmp/file.eml";
    assert(QTExtractTemplateNames((const unsigned char *)urls,strlen(urls),names,8)==0);
    const char *plain="A title about shorts, passwords and example.com";
    assert(QTExtractTemplateNames((const unsigned char *)plain,strlen(plain),names,8)==0);
    const unsigned char binary[]={255,0,'a','_','b','.','e','m','l',0,'c','.','e','m','l',255};
    assert(QTExtractTemplateNames(binary,sizeof(binary),names,8)==2);
    assert(QTExtractTemplateNames(NULL,0,names,8)==0);
    assert(QTExtractTemplateNames(binary,262145,names,8)==0);
    assert(QTExtractTemplateNames(binary,sizeof(binary),names,0)==0);
    puts("10 template-scanner assertions passed; lexical tests only");
}
