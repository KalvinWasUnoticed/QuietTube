#include "../Sources/QTFeedRules.h"
#include <assert.h>
#include <stdio.h>
static unsigned match(const char *s) { return QTClassifyElementBytes((const unsigned char *)s,strlen(s)); }
int main(void) {
    assert(match("shorts_shelf.eml") == QTFeedShorts);
    assert(match("\x01shorts_video_cell\x00") == QTFeedShorts);
    assert(match("ordinary video about shorts and games") == 0);
    assert(match("not_shorts_shelf") == 0);
    assert(match("shorts_shelf_extra") == 0);
    assert(match("feed_ad_metadata") == QTFeedAd);
    assert(match("playables_shelf.eml") == QTFeedPlayable);
    assert(match("statement_banner.eml") == QTFeedPromo);
    assert(match("My Featured Video") == 0);
    assert(match("A video with a vertical aspect ratio") == 0);
    assert(match("shorts_shelf.eml feed_ad_metadata") == (QTFeedShorts|QTFeedAd));
    const unsigned char binary[] = {0,1,'x',0,'s','h','o','r','t','s','_','s','h','e','l','f',0,255};
    assert(QTClassifyElementBytes(binary,sizeof(binary)) == QTFeedShorts);
    assert(QTClassifyElementBytes(NULL,0) == 0);
    assert(QTClassifyElementBytes((const unsigned char *)"shorts_shelf",262145) == 0);
    assert(match("chips_shelf.eml") == QTFeedTopics);
    assert(match("chip_cloud.eml") == 0);
    assert(match("video_card.eml") == 0);
    assert(match("video_lockup_with_attachment.eml /hqdefault.jpg") == 0);
    assert(match("video_lockup_with_attachment.eml /oardefault.jpg") == QTFeedEdgeVideo);
    assert(match("video_card.eml /oar1.jpg") == QTFeedEdgeVideo);
    assert(match("/oar1.jpg") == 0);
    assert(match("inline_shorts.eml") == QTFeedEdgeVideo);
    assert(match("Explore more topics") == 0); /* title alone in arbitrary bytes is not a rule */
    assert(match("not_chips_shelf") == 0);
    assert(match("video_card.eml /frame0.jpg") == 0); /* common thumbnail excluded */
    assert(match("chips_shelf.eml shorts_shelf.eml") == (QTFeedTopics|QTFeedShorts));
    /* Deterministic malformed-byte smoke test under ASan/UBSan. */
    unsigned state=1234567;
    unsigned char noise[257];
    for (unsigned round=0;round<5000;round++) {
        size_t n=round%sizeof(noise);
        for (size_t k=0;k<n;k++) { state=state*1664525u+1013904223u; noise[k]=(unsigned char)(state>>24); }
        unsigned value=QTClassifyElementBytes(noise,n);
        assert((value & ~63u)==0);
    }
    puts("26 classifier fixtures + 5000 bounded random-byte iterations passed");
    return 0;
}
