/* Deterministic structured mutation + boundary properties, actual production C. */
#include "../Sources/QTFeedRules.h"
#include "../Sources/QTTemplateScan.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
static uint32_t state=102;
static uint32_t next(void) { state=state*1664525u+1013904223u; return state; }
static void check(const unsigned char *data,size_t n) {
    char names[8][97]={{0}}, again[8][97]={{0}};
    size_t cap=next()%9;
    unsigned kind=QTClassifyElementBytes(data,n);
    assert(!(kind & ~2047u));
    assert(kind==QTClassifyElementBytes(data,n));
    size_t found=QTExtractTemplateNames(data,n,names,cap);
    assert(found<=cap);
    assert(found==QTExtractTemplateNames(data,n,again,cap));
    for (size_t i=0;i<found;i++) {
        size_t len=strlen(names[i]);
        assert(len>=3 && len<=96);
        assert(!strcmp(names[i],again[i]));
        for (size_t j=0;j<len;j++) assert(QTTemplateChar((unsigned char)names[i][j]));
        for (size_t j=0;j<i;j++) assert(strcmp(names[i],names[j]));
    }
}
int main(void) {
    const char *seeds[]={"video_card.eml", "shorts_shelf", "playables_shelf", "promoted_video", "horizontal_shelf \x0a\x0eWatch it again", "?list=RDabc", "https://host/video_card.eml?token=private", "user@video_card.eml", "inline_injection_teaser_12345", "feed_layout portrait_video_card", "banner_ads.eml", "game featured shorts ad title", ""};
    unsigned char data[513],copy[513];
    for (size_t iteration=0;iteration<100000;iteration++) {
        size_t n=next()%sizeof(data);
        for (size_t i=0;i<n;i++) data[i]=(unsigned char)(next()>>24);
        const char *seed=seeds[next()%(sizeof(seeds)/sizeof(seeds[0]))];
        size_t len=strlen(seed);
        if (len<=n) memcpy(data+(next()%(n-len+1)),seed,len);
        if (n && iteration%2) data[next()%n]^=(unsigned char)(1u<<(next()%8));
        memcpy(copy,data,n);
        check(data,n);
        assert(!memcmp(data,copy,n));
    }
    const size_t bounds[]={0,1,2,3,95,96,97,511,512,513,262143,262144,262145};
    unsigned char *large=malloc(262145); assert(large);
    for (size_t i=0;i<sizeof(bounds)/sizeof(bounds[0]);i++) {
        size_t n=bounds[i]; memset(large,'x',n); check(large,n);
        memset(large,0,n); if(n>=14)memcpy(large+n-14,"video_card.eml",14); check(large,n);
    }
    char names[8][97]={{0}};
    assert(QTExtractTemplateNames(NULL,262144,names,8)==0);
    assert(QTExtractTemplateNames(large,262144,NULL,8)==0);
    assert(QTExtractTemplateNames(large,262145,names,8)==0);
    assert(QTClassifyElementBytes(large,262145)==0);
    assert(QTClassifyElementBytes(NULL,262144)==0);
    free(large);
    puts("100000 structured mutation cases + size/null/capacity/immutability/determinism checks passed (ASan/UBSan).");
    return 0;
}
