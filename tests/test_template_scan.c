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
    const char *extless="video_lockup_with_attachment portrait_video_card full_width_portrait_image_layout";
    assert(QTExtractTemplateNames((const unsigned char *)extless,strlen(extless),names,8)==3);
    const char *shortext="video_card.e shelf.e";
    assert(QTExtractTemplateNames((const unsigned char *)shortext,strlen(shortext),names,8)==2);
    const char *prose="video shelf portrait games layout and shorts";
    assert(QTExtractTemplateNames((const unsigned char *)prose,strlen(prose),names,8)==0);
    const char *unrelated="access_token account_secret ordinary_name";
    assert(QTExtractTemplateNames((const unsigned char *)unrelated,strlen(unrelated),names,8)==0);
    const char *moreurls="https://host/video_card /video_card user@video_card video_card?token";
    assert(QTExtractTemplateNames((const unsigned char *)moreurls,strlen(moreurls),names,8)==0);
    const char *ids="inline_injection_teaser_1790215880042_0 inline_injection_teaser_1790215880796_1";
    assert(QTExtractTemplateNames((const unsigned char *)ids,strlen(ids),names,8)==1);
    assert(!strcmp(names[0],"inline_injection_teaser"));
    const char *mix="radio_playlist_mix playlist_lockup";
    assert(QTExtractTemplateNames((const unsigned char *)mix,strlen(mix),names,8)==2);
    const char *observed="video_lockup_overlay.eml-fe yt_fill_youtube_shorts_24pt";
    assert(QTExtractTemplateNames((const unsigned char *)observed,strlen(observed),names,8)==2);
    assert(!strcmp(names[0],"video_lockup_overlay.eml-fe"));
    unsigned state=19; unsigned char noise[256];
    for (unsigned round=0;round<5000;round++) {
        size_t length=round%sizeof(noise);
        for(size_t i=0;i<length;i++) { state=state*1664525u+1013904223u; noise[i]=(unsigned char)(state>>24); }
        size_t count=QTExtractTemplateNames(noise,length,names,8);
        assert(count<=8);
        for(size_t i=0;i<count;i++) assert(strlen(names[i])<=96);
    }
    puts("20 scanner fixtures + 5000 random-byte iterations passed; lexical tests only");
}
